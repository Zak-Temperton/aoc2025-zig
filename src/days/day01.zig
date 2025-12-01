const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 1);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer.data);
    const p1_time = timer.lap();
    const p2 = part2(buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day01:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

fn part1(input: []const u8) u32 {
    var index: usize = 0;
    var dial: u32 = 50;
    var count: u32 = 0;
    while (index < input.len) {
        const dir = input[index];
        index += 1;
        const amount = readInt(u32, input, &index) % 100;
        index += 1;
        switch (dir) {
            'L' => dial = (dial + 100 - amount) % 100,
            'R' => dial = (dial + amount) % 100,
            else => unreachable,
        }
        if (dial == 0) count += 1;
    }
    return count;
}

fn part2(input: []const u8) u32 {
    var index: usize = 0;
    var dial: u32 = 50;
    var count: u32 = 0;
    while (index < input.len) {
        const dir = input[index];
        index += 1;
        var amount = readInt(u32, input, &index);
        index += 1;

        count += amount / 100;

        amount %= 100;
        switch (dir) {
            'L' => {
                if (dial != 0 and dial <= amount) count += 1;
                dial = (dial + 100 - amount) % 100;
            },
            'R' => {
                if (dial != 0 and 100 - amount <= dial) count += 1;
                dial = (dial + amount) % 100;
            },
            else => unreachable,
        }
    }
    return count;
}

test "part1" {
    const input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    const expected = 3;
    const actual = part1(input);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    const expected = 6;
    const actual = part2(input);
    try std.testing.expectEqual(expected, actual);
}

test "part2b" {
    const input =
        \\R1000
    ;
    const expected = 10;
    const actual = part2(input);
    try std.testing.expectEqual(expected, actual);
}
