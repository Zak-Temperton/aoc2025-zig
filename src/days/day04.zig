const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 4);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer.data);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day04:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

fn part1(input: []const u8) u32 {
    var available: u32 = 0;
    const width = std.mem.indexOf(u8, input, &.{'\n'}).?;
    for (0..width) |y| {
        loop: for (0..width) |x| {
            if (input[y * (width + 1) + x] == '@') {
                var neighbours: usize = 0;
                for (x -| 1..@min(x + 2, width)) |xx| {
                    for (y -| 1..@min(y + 2, width)) |yy| {
                        if (input[yy * (width + 1) + xx] == '@') {
                            neighbours += 1;
                            if (neighbours == 5) continue :loop;
                        }
                    }
                }
                if (neighbours <= 4) {
                    available += 1;
                }
            }
        }
    }

    return available;
}

fn part2(alloc: Allocator, input: []const u8) !u32 {
    var removed: u32 = 0;
    const width = std.mem.indexOf(u8, input, &.{'\n'}).?;
    var map = try alloc.alloc(u8, width * width);
    defer alloc.free(map);
    for (0..width) |y| {
        @memcpy(
            map[y * width .. y * width + width],
            input[y * (width + 1) .. y * (width + 1) + width],
        );
    }
    var new_map = try alloc.alloc(u8, width * width);
    defer alloc.free(new_map);

    var changed = true;
    while (changed) {
        changed = false;

        for (0..width) |y| {
            loop: for (0..width) |x| {
                if (map[y * width + x] == '@') {
                    var neighbours: usize = 0;
                    for (x -| 1..@min(x + 2, width)) |xx| {
                        for (y -| 1..@min(y + 2, width)) |yy| {
                            if (map[yy * width + xx] == '@') {
                                neighbours += 1;
                                if (neighbours == 5) {
                                    new_map[y * width + x] = '@';
                                    continue :loop;
                                }
                            }
                        }
                    }
                    if (neighbours <= 4) {
                        new_map[y * width + x] = '.';
                        changed = true;
                        removed += 1;
                    } else {
                        new_map[y * width + x] = '@';
                    }
                } else {
                    new_map[y * width + x] = '.';
                }
            }
        }
        @memcpy(map, new_map);
    }

    return removed;
}

test "part1" {
    const input =
        \\..@@.@@@@.
        \\@@@.@.@.@@
        \\@@@@@.@.@@
        \\@.@@@@..@.
        \\@@.@@@@.@@
        \\.@@@@@@@.@
        \\.@.@.@.@@@
        \\@.@@@.@@@@
        \\.@@@@@@@@.
        \\@.@.@@@.@.
    ;
    const expected = 13;
    const actual = part1(input);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const alloc = std.testing.allocator;
    const input =
        \\..@@.@@@@.
        \\@@@.@.@.@@
        \\@@@@@.@.@@
        \\@.@@@@..@.
        \\@@.@@@@.@@
        \\.@@@@@@@.@
        \\.@.@.@.@@@
        \\@.@@@.@@@@
        \\.@@@@@@@@.
        \\@.@.@@@.@.
    ;
    const expected = 43;
    const actual = try part2(alloc, input);
    try std.testing.expectEqual(expected, actual);
}
