const std = @import("std");

pub const day01 = @import("days/day01.zig");
pub const day02 = @import("days/day02.zig");
pub const day03 = @import("days/day03.zig");
pub const day04 = @import("days/day04.zig");
pub const day05 = @import("days/day05.zig");
pub const day06 = @import("days/day06.zig");
pub const day07 = @import("days/day07.zig");
pub const day08 = @import("days/day08.zig");
pub const day09 = @import("days/day09.zig");
pub const day10 = @import("days/day10.zig");
pub const day11 = @import("days/day11.zig");
pub const day12 = @import("days/day12.zig");

pub const Day = enum {
    day01,
    day02,
    day03,
    day04,
    day05,
    day06,
    day07,
    day08,
    day09,
    day10,
    day11,
    day12,
    all,
};

pub const days = std.StaticStringMap(Day).initComptime(.{
    .{ "day01", .day01 },
    .{ "day02", .day02 },
    .{ "day03", .day03 },
    .{ "day04", .day04 },
    .{ "day05", .day05 },
    .{ "day06", .day06 },
    .{ "day07", .day07 },
    .{ "day08", .day08 },
    .{ "day09", .day09 },
    .{ "day10", .day10 },
    .{ "day11", .day11 },
    .{ "day12", .day12 },
    .{ "all", .all },
});

pub fn selectDay(alloc: std.mem.Allocator, stdout: *std.io.Writer, input_day: []const u8) !void {
    if (days.get(input_day)) |day_enum| {
        switch (day_enum) {
            .day01 => try day01.run(alloc, stdout),
            .day02 => try day02.run(alloc, stdout),
            .day03 => try day03.run(alloc, stdout),
            .day04 => try day04.run(alloc, stdout),
            .day05 => try day05.run(alloc, stdout),
            .day06 => try day06.run(alloc, stdout),
            .day07 => try day07.run(alloc, stdout),
            .day08 => try day08.run(alloc, stdout),
            .day09 => try day09.run(alloc, stdout),
            .day10 => try day10.run(alloc, stdout),
            .day11 => try day11.run(alloc, stdout),
            .day12 => try day12.run(alloc, stdout),
            .all => {
                try day01.run(alloc, stdout);
                try day02.run(alloc, stdout);
                try day03.run(alloc, stdout);
                try day04.run(alloc, stdout);
                try day05.run(alloc, stdout);
                try day06.run(alloc, stdout);
                try day07.run(alloc, stdout);
                try day08.run(alloc, stdout);
                try day09.run(alloc, stdout);
                try day10.run(alloc, stdout);
                try day11.run(alloc, stdout);
                try day12.run(alloc, stdout);
            },
        }
    } else {
        try stdout.print("invalid day\n", .{});
        try stdout.print("Give the day as an argument e.g. zig build run -- day01", .{});
    }
}
