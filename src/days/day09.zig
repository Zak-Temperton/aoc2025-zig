const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 9);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer.data);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day09:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

fn Point(comptime T: type) type {
    return @Vector(2, T);
}

fn IDENT(comptime T: type) Point(T) {
    return .{ 1, 1 };
}

fn part1(alloc: Allocator, input: []const u8) !u64 {
    var red_tiles = try std.ArrayList(Point(i64)).initCapacity(alloc, 8);
    defer red_tiles.deinit(alloc);
    var index: usize = 0;
    while (index < input.len) {
        var red_tile: Point(i64) = undefined;
        red_tile[0] = readInt(i64, input, &index);
        index += 1;
        red_tile[1] = readInt(i64, input, &index);
        index += 1;
        try red_tiles.append(alloc, red_tile);
    }
    var max: u64 = 0;
    for (red_tiles.items[0 .. red_tiles.items.len - 1], 1..) |a, i| {
        for (red_tiles.items[i..]) |b| {
            const c = @abs(a - b) + IDENT(u64);
            const area = c[0] * c[1];
            if (area > max) max = area;
        }
    }
    return max;
}

fn intersects(
    rect_a: Point(i64),
    rect_b: Point(i64),
    line_a: Point(i64),
    line_b: Point(i64),
) bool {
    const rxl = @min(rect_a[0], rect_b[0]) + 1;
    const rxr = @max(rect_a[0], rect_b[0]) - 1;
    const ryd = @min(rect_a[1], rect_b[1]) + 1;
    const ryu = @max(rect_a[1], rect_b[1]) - 1;

    const lxl = @min(line_a[0], line_b[0]);
    const lxr = @max(line_a[0], line_b[0]);
    const lyd = @min(line_a[1], line_b[1]);
    const lyu = @max(line_a[1], line_b[1]);

    return rxl < lxr and rxr > lxl and ryu > lyd and ryd < lyu;
}

fn part2(alloc: Allocator, input: []const u8) !u64 {
    var red_tiles = try std.ArrayList(Point(i64)).initCapacity(alloc, 8);
    defer red_tiles.deinit(alloc);
    var index: usize = 0;
    while (index < input.len) {
        var red_tile: Point(i64) = undefined;
        red_tile[0] = readInt(i64, input, &index);
        index += 1;
        red_tile[1] = readInt(i64, input, &index);
        index += 1;
        try red_tiles.append(alloc, red_tile);
    }

    var max: u64 = 0;
    for (red_tiles.items[0 .. red_tiles.items.len - 1], 1..) |a, i| {
        loop: for (red_tiles.items[i..]) |b| {
            for (red_tiles.items[0 .. red_tiles.items.len - 1], red_tiles.items[1..]) |c, d| {
                if (intersects(a, b, c, d)) {
                    continue :loop;
                }
            }
            if (!intersects(a, b, red_tiles.getLast(), red_tiles.items[0])) {
                const ab = @abs(a - b) + IDENT(u64);
                const area = ab[0] * ab[1];
                if (area > max) max = area;
            }
        }
    }

    return max;
}

test "part1" {
    const alloc = std.testing.allocator;
    const input =
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
    ;
    const expected = 50;
    const actual = try part1(alloc, input);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const alloc = std.testing.allocator;
    const input =
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
    ;
    const expected = 24;
    const actual = try part2(alloc, input);
    try std.testing.expectEqual(expected, actual);
}
