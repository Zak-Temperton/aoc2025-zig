const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 3);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer.data);
    const p1_time = timer.lap();
    const p2 = part2(buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day03:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

fn part1(input: []const u8) u32 {
    var joltage: u32 = 0;
    const width = std.mem.indexOf(u8, input, &.{'\n'}).?;
    var index: usize = 0;
    while (index < input.len) : (index += width + 1) {
        const left_max_i = index + std.mem.indexOfMax(u8, input[index .. index + width - 1]);
        const right_max = std.mem.max(u8, input[left_max_i + 1 .. index + width]);
        joltage += @as(u32, input[left_max_i] - '0') * 10 + @as(u32, right_max - '0');
    }
    return joltage;
}

fn part2(input: []const u8) u64 {
    var joltage_sum: u64 = 0;
    const width = std.mem.indexOf(u8, input, &.{'\n'}).?;
    var index: usize = 0;
    while (index < input.len) : (index += width + 1) {
        var joltage: u64 = 0;
        var left_most = index;
        for (0..12) |i| {
            left_most = left_most + std.mem.indexOfMax(u8, input[left_most .. index + width - (11 - i)]);
            joltage *= 10;
            joltage += @as(u64, input[left_most] - '0');
            left_most += 1;
        }
        joltage_sum += joltage;
    }
    return joltage_sum;
}

test "part1" {
    const input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;
    const expected = 357;
    const actual = part1(input);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;
    const expected = 3121910778619;
    const actual = part2(input);
    try std.testing.expectEqual(expected, actual);
}
