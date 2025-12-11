const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 8);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer.data);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day08:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

fn part1(alloc: Allocator, input: []const u8) !u32 {
    return solvePart1(alloc, input, 1000, 1000);
}

fn part2(alloc: Allocator, input: []const u8) !u32 {
    return solvePart2(alloc, input, 1000);
}

const JunctionBox = @Vector(3, u32);

const Pair = struct {
    a: usize,
    b: usize,
    dist: f32,

    fn init(junction_boxes: []JunctionBox, a_index: usize, b_index: usize) Pair {
        const a: @Vector(3, f32) = @floatFromInt(junction_boxes[a_index]);
        const b: @Vector(3, f32) = @floatFromInt(junction_boxes[b_index]);
        const ab = a - b;
        const ab2 = ab * ab;
        const dist = @sqrt(ab2[0] + ab2[1] + ab2[2]);
        return .{
            .a = a_index,
            .b = b_index,
            .dist = dist,
        };
    }

    fn lessThan(_: void, left: Pair, right: Pair) bool {
        return left.dist < right.dist;
    }
};

const Node = struct {
    walked: bool = false,
    links: std.ArrayList(usize),
    fn walkNode(node: *@This(), nodes: []?@This(), size: *u32) void {
        if (node.walked) return;
        node.walked = true;
        size.* += 1;
        for (node.links.items) |link| {
            nodes[link].?.walkNode(nodes, size);
        }
    }
};

fn createJunctionBoxPairs(
    alloc: Allocator,
    input: []const u8,
    num_boxes: comptime_int,
) !struct {
    junction_boxes: []@Vector(3, u32),
    pairs: []Pair,
} {
    var junction_boxes = try alloc.alloc(JunctionBox, num_boxes);
    errdefer alloc.free(junction_boxes);
    var pairs = try alloc.alloc(Pair, num_boxes * (num_boxes - 1) / 2);
    errdefer alloc.free(pairs);

    var index: usize = 0;
    var i: usize = 0;
    while (index < input.len) : (i += 1) {
        const x = readInt(u32, input, &index);
        index += 1;
        const y = readInt(u32, input, &index);
        index += 1;
        const z = readInt(u32, input, &index);
        index += 1;
        junction_boxes[i] = .{ x, y, z };
    }

    i = 0;
    for (0..junction_boxes.len - 1) |a| {
        for (a + 1..junction_boxes.len) |b| {
            pairs[i] = Pair.init(junction_boxes, a, b);
            i += 1;
        }
    }

    std.mem.sortUnstable(Pair, pairs, {}, Pair.lessThan);

    return .{
        .junction_boxes = junction_boxes,
        .pairs = pairs,
    };
}

fn solvePart1(alloc: Allocator, input: []const u8, num_boxes: comptime_int, num_pairs: comptime_int) !u32 {
    const junction_box_pairs = try createJunctionBoxPairs(alloc, input, num_boxes);
    const pairs = junction_box_pairs.pairs;
    const junction_boxes = junction_box_pairs.junction_boxes;
    defer alloc.free(junction_boxes);
    defer alloc.free(pairs);

    var nodes = try alloc.alloc(?Node, 1000);
    defer {
        for (0..nodes.len) |n| {
            if (nodes[n] != null) {
                nodes[n].?.links.deinit(alloc);
            }
        }
        alloc.free(nodes);
    }
    @memset(nodes, null);

    for (pairs[0..num_pairs]) |pair| {
        if (nodes[pair.a] == null) {
            nodes[pair.a] = .{ .links = try std.ArrayList(usize).initCapacity(alloc, 8) };
        }
        try nodes[pair.a].?.links.append(alloc, pair.b);

        if (nodes[pair.b] == null) {
            nodes[pair.b] = .{ .links = try std.ArrayList(usize).initCapacity(alloc, 8) };
        }
        try nodes[pair.b].?.links.append(alloc, pair.a);
    }

    var max: [3]u32 = .{ 0, 0, 0 };

    for (0..nodes.len) |node_i| {
        if (nodes[node_i] != null) {
            var size: u32 = 0;
            nodes[node_i].?.walkNode(nodes, &size);

            if (size >= max[0]) {
                max[2] = max[1];
                max[1] = max[0];
                max[0] = size;
            } else if (size >= max[1]) {
                max[2] = max[1];
                max[1] = size;
            } else if (size > max[2]) {
                max[2] = size;
            }
        }
    }

    return max[0] * max[1] * max[2];
}

fn solvePart2(alloc: Allocator, input: []const u8, num_boxes: comptime_int) !u32 {
    const junction_box_pairs = try createJunctionBoxPairs(alloc, input, num_boxes);
    const junction_boxes = junction_box_pairs.junction_boxes;
    const pairs = junction_box_pairs.pairs;
    defer alloc.free(junction_boxes);
    defer alloc.free(pairs);

    const uX = @Type(std.builtin.Type{ .int = .{ .signedness = .unsigned, .bits = num_boxes } });
    var nodes = try alloc.alloc(uX, num_boxes);
    defer alloc.free(nodes);
    for (nodes, 0..) |*n, j| n.* = @as(uX, 1) << @truncate(j);

    for (pairs) |pair| {
        nodes[pair.a] |= nodes[pair.b];
        nodes[pair.b] = nodes[pair.a];
        for (0..num_boxes) |j| {
            if (nodes[pair.a] >> @truncate(j) & 1 == 1) {
                nodes[j] = nodes[pair.a];
            }
        }
        if (nodes[pair.a] == std.math.maxInt(uX)) {
            return junction_boxes[pair.a][0] * junction_boxes[pair.b][0];
        }
    }
    return 0;
}

test "part1" {
    const alloc = std.testing.allocator;
    const input =
        \\162,817,812
        \\57,618,57
        \\906,360,560
        \\592,479,940
        \\352,342,300
        \\466,668,158
        \\542,29,236
        \\431,825,988
        \\739,650,466
        \\52,470,668
        \\216,146,977
        \\819,987,18
        \\117,168,530
        \\805,96,715
        \\346,949,466
        \\970,615,88
        \\941,993,340
        \\862,61,35
        \\984,92,344
        \\425,690,689
    ;
    const expected = 40;
    const actual = try solvePart1(alloc, input, 20, 10);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const alloc = std.testing.allocator;
    const input =
        \\162,817,812
        \\57,618,57
        \\906,360,560
        \\592,479,940
        \\352,342,300
        \\466,668,158
        \\542,29,236
        \\431,825,988
        \\739,650,466
        \\52,470,668
        \\216,146,977
        \\819,987,18
        \\117,168,530
        \\805,96,715
        \\346,949,466
        \\970,615,88
        \\941,993,340
        \\862,61,35
        \\984,92,344
        \\425,690,689
    ;
    const expected = 25272;
    const actual = try solvePart2(alloc, input, 20);
    try std.testing.expectEqual(expected, actual);
}
