const std = @import("std");
const Allocator = std.mem.Allocator;

const util = @import("../util.zig");
const Buffer = util.Buffer;
const readInt = util.readInt;

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    var buffer = try Buffer.init(alloc, 2);
    defer buffer.deinit(alloc);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer.data);
    const p1_time = timer.lap();
    const p2 = part2(buffer.data);
    const p2_time = timer.read();
    try stdout.print(
        \\Day02:
        \\  part1: {d} {d}ns
        \\  part2: {d} {d}ns
        \\
    , .{
        p1, p1_time,
        p2, p2_time,
    });
}

fn part1(input: []const u8) u64 {
    var id_sum: u64 = 0;
    var index: usize = 0;
    while (index < input.len) {
        var start = readInt(u64, input, &index);
        index += 1;
        const end = readInt(u64, input, &index);
        index += 1;
        while (start <= end) : (start += 1) {
            const log10 = std.math.log10_int(start) + 1;
            if (log10 & 1 == 1) continue;
            const identity = std.math.pow(u64, 10, log10 / 2) + 1;
            if ((start / identity) * (identity) == start) {
                id_sum += start;
            }
        }
    }

    return id_sum;
}

fn part2(input: []const u8) u64 {
    var id_sum: u64 = 0;
    var index: usize = 0;
    while (index < input.len) {
        var id = readInt(u64, input, &index);
        index += 1;
        const end = readInt(u64, input, &index);
        index += 1;
        while (id <= end) : (id += 1) {
            const log10 = std.math.log10_int(id) + 1;
            for (0..log10 - 1) |i| {
                const j = log10 - i;
                if ((log10 / j) * j != log10) continue;
                var identity: u64 = 0;
                for (0..j) |t| {
                    identity += std.math.pow(u64, 10, t * log10 / j);
                }
                if ((id / identity) * (identity) == id) {
                    id_sum += id;
                    break;
                }
            }
        }
    }

    return id_sum;
}

test "part1" {
    const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
    const expected = 1227775554;
    const actual = part1(input);

    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
    const expected = 4174379265;
    const actual = part2(input);

    try std.testing.expectEqual(expected, actual);
}
