const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 5);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer.data);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day05:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

const Range = struct { lower: u64, upper: u64 };

fn sortRange(_: void, left: Range, right: Range) bool {
    return left.lower < right.lower;
}

fn createRanges(alloc: Allocator, input: []const u8, index: *usize) ![]Range {
    var ranges = try std.ArrayList(Range).initCapacity(alloc, 32);
    defer ranges.deinit(alloc);

    while (input[index.*] != '\n') {
        const lower = readInt(u64, input, index);
        index.* += 1;
        const upper = readInt(u64, input, index);
        index.* += 1;
        const new_range = Range{ .lower = lower, .upper = upper };
        try ranges.append(alloc, new_range);
    }

    std.mem.sort(Range, ranges.items, {}, sortRange);
    var new_ranges = try std.ArrayList(Range).initCapacity(alloc, 32);

    for (ranges.items) |new_range| {
        var merged = false;
        for (new_ranges.items) |*range| {
            if (new_range.lower <= range.lower and new_range.upper >= range.lower) {
                range.lower = new_range.lower;
                merged = true;
            }
            if (new_range.upper >= range.upper and new_range.lower <= range.upper) {
                range.upper = new_range.upper;
                merged = true;
            }
            if (new_range.lower >= range.lower and new_range.upper <= range.upper) {
                merged = true;
            }
            if (merged) break;
        }
        if (!merged) {
            try new_ranges.append(alloc, new_range);
        }
    }

    return new_ranges.toOwnedSlice(alloc);
}

fn part1(alloc: Allocator, input: []const u8) !u32 {
    var index: usize = 0;
    const ranges = try createRanges(alloc, input, &index);
    defer alloc.free(ranges);
    var fresh: u32 = 0;
    while (index < input.len) {
        const num = readInt(u64, input, &index);
        index += 1;
        for (ranges) |range| {
            if (num >= range.lower and num <= range.upper) {
                fresh += 1;
                break;
            }
        }
    }
    return fresh;
}

fn part2(alloc: Allocator, input: []const u8) !u64 {
    var index: usize = 0;
    const ranges = try createRanges(alloc, input, &index);
    defer alloc.free(ranges);

    var total: u64 = 0;
    for (ranges) |range| {
        total += range.upper - range.lower + 1;
    }

    return total;
}

test "part1" {
    const alloc = std.testing.allocator;
    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;
    const expected = 3;
    const actual = try part1(alloc, input);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const alloc = std.testing.allocator;
    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;
    const expected = 14;
    const actual = try part2(alloc, input);
    try std.testing.expectEqual(expected, actual);
}
