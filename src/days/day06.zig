const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffers = util.Buffers;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffers = try Buffers.init(alloc, 6);
    defer buffers.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffers.a);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffers.b);
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

fn part1(alloc: Allocator, input: []const u8) !u32 {
    _ = alloc;
    _ = input;
    return 0;
}

fn part2(alloc: Allocator, input: []const u8) !u32 {
    _ = alloc;
    _ = input;
    return 0;
}