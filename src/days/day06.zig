const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 6);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer.data);
    const p1_time = timer.lap();
    const p2 = part2(buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day06:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

const Operation = enum {
    add,
    mul,
};

fn skipWhitespace(input: []const u8, index: *usize) void {
    while (index.* < input.len and input[index.*] == ' ') {
        index.* += 1;
    }
}

fn part1(alloc: Allocator, input: []const u8) !u64 {
    _ = alloc;
    const line_length = std.mem.indexOf(u8, input, &.{'\n'}).? + 1;
    const lines = (input.len + 1) / line_length;
    const operations_offset = (lines - 1) * line_length;

    var index: usize = 0;
    var total: u64 = 0;

    while (index < line_length - 1) {
        const op: Operation = switch (input[operations_offset + index]) {
            '+' => .add,
            '*' => .mul,
            else => unreachable,
        };
        var result: u64 = blk: {
            var tmp = index;
            skipWhitespace(input, &tmp);
            break :blk readInt(u64, input, &tmp);
        };
        for (1..lines - 1) |l| {
            var tmp = l * line_length + index;
            skipWhitespace(input, &tmp);
            const num = readInt(u64, input, &tmp);
            switch (op) {
                .add => result += num,
                .mul => result *= num,
            }
        }
        index += 1;
        while (index < line_length - 1 and input[operations_offset + index] == ' ') index += 1;

        total += result;
    }
    return total;
}

fn part2(input: []const u8) u64 {
    const line_length = std.mem.indexOf(u8, input, &.{'\n'}).? + 1;
    const lines = (input.len + 1) / line_length;
    const operations_offset = (lines - 1) * line_length;

    var index: usize = 0;
    var total: u64 = 0;

    while (index < line_length - 1) {
        const op: Operation = switch (input[operations_offset + index]) {
            '+' => .add,
            '*' => .mul,
            else => unreachable,
        };
        var result: u64 = 0;
        for (0..lines - 1) |l| {
            const c = input[line_length * l + index];
            if (c != ' ') {
                result *= 10;
                result += c - '0';
            }
        }
        index += 1;
        while (index < line_length - 1 and input[operations_offset + index] == ' ') {
            var num: u64 = 0;
            for (0..lines - 1) |l| {
                const c = input[line_length * l + index];
                if (c != ' ') {
                    num *= 10;
                    num += c - '0';
                }
            }
            if (num != 0) {
                switch (op) {
                    .add => result += num,
                    .mul => result *= num,
                }
            }
            index += 1;
        }
        total += result;
    }
    return total;
}

test "part1" {
    const alloc = std.testing.allocator;
    const input =
        \\123 328  51 64 
        \\ 45 64  387 23 
        \\  6 98  215 314
        \\*   +   *   +  
    ;
    const expected = 4277556;
    const actual = try part1(alloc, input);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const input =
        \\123 328  51 64 
        \\ 45 64  387 23 
        \\  6 98  215 314
        \\*   +   *   +  
    ;
    const expected = 3263827;
    const actual = part2(input);
    try std.testing.expectEqual(expected, actual);
}
