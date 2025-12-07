const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 7);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer.data);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day07:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

fn part1(alloc: Allocator, input: []const u8) !u32 {
    const start = std.mem.indexOf(u8, input, &.{'S'}).?;
    const width = std.mem.indexOf(u8, input, &.{'\n'}).? + 1;
    var beams: []usize = try alloc.alloc(usize, 1);
    defer alloc.free(beams);
    beams[0] = start;
    var new_beams: std.ArrayList(usize) = undefined;
    errdefer new_beams.deinit(alloc);
    var splits: u32 = 0;
    //for (1..9) |i| {
    for (1..(input.len - width) / (width * 2) + 1) |i| {
        new_beams = try std.ArrayList(usize).initCapacity(alloc, beams.len * 2);

        for (beams) |beam| {
            if (input[i * width * 2 + beam] == '^') {
                if (new_beams.items.len == 0 or new_beams.getLast() != beam - 1)
                    new_beams.appendAssumeCapacity(beam - 1);
                new_beams.appendAssumeCapacity(beam + 1);
                splits += 1;
            } else {
                if (new_beams.items.len == 0 or new_beams.getLast() != beam)
                    new_beams.appendAssumeCapacity(beam);
            }
        }
        alloc.free(beams);
        beams = try new_beams.toOwnedSlice(alloc);
    }

    return splits;
}

fn part2(alloc: Allocator, input: []const u8) !u64 {
    const Beam = struct { loc: usize, timelines: u64 };
    const start = std.mem.indexOf(u8, input, &.{'S'}).?;
    const width = std.mem.indexOf(u8, input, &.{'\n'}).? + 1;
    var beams: []Beam = try alloc.alloc(Beam, 1);
    defer alloc.free(beams);
    beams[0] = .{ .loc = start, .timelines = 1 };
    var new_beams: std.ArrayList(Beam) = undefined;
    errdefer new_beams.deinit(alloc);
    for (1..(input.len - width) / (width * 2) + 1) |i| {
        new_beams = try std.ArrayList(Beam).initCapacity(alloc, beams.len * 2);
        for (beams) |beam| {
            if (input[i * width * 2 + beam.loc] == '^') {
                if (new_beams.items.len == 0 or new_beams.getLast().loc != beam.loc - 1) {
                    new_beams.appendAssumeCapacity(.{
                        .loc = beam.loc - 1,
                        .timelines = beam.timelines,
                    });
                } else {
                    new_beams.items[new_beams.items.len - 1].timelines += beam.timelines;
                }
                new_beams.appendAssumeCapacity(.{
                    .loc = beam.loc + 1,
                    .timelines = beam.timelines,
                });
            } else {
                if (new_beams.items.len == 0 or new_beams.getLast().loc != beam.loc) {
                    new_beams.appendAssumeCapacity(beam);
                } else {
                    new_beams.items[new_beams.items.len - 1].timelines += beam.timelines;
                }
            }
        }
        alloc.free(beams);
        beams = try new_beams.toOwnedSlice(alloc);
    }

    var timelines: u64 = 0;
    for (beams) |beam| {
        timelines += beam.timelines;
    }

    return timelines;
}

test "part1" {
    const alloc = std.testing.allocator;
    const input =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
    ;
    const expected = 21;
    const actual = try part1(alloc, input);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const alloc = std.testing.allocator;
    const input =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
    ;
    const expected = 40;
    const actual = try part2(alloc, input);
    try std.testing.expectEqual(expected, actual);
}
