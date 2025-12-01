const std = @import("std");

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    var buffer: [512]u8 = undefined;

    for (1..13) |day| {
        const sub_path = try std.fmt.allocPrint(arena, "src/days/day{d:0>2}.zig", .{day});
        std.fs.cwd().access(sub_path, .{}) catch |e| switch (e) {
            error.FileNotFound => {
                const file_content = try std.fmt.allocPrint(arena, example_day, .{ day, day });
                var new_file = try std.fs.cwd().createFile(sub_path, .{});
                defer new_file.close();
                var new_file_writer = new_file.writer(&buffer);
                const file_writer = &new_file_writer.interface;
                try file_writer.writeAll(file_content);
                buffer = undefined;
            },
            else => {},
        };
    }
    for (1..13) |day| {
        const sub_path = try std.fmt.allocPrint(arena, "data/day{d:0>2}.txt", .{day});
        std.fs.cwd().access(sub_path, .{}) catch |e| switch (e) {
            error.FileNotFound => {
                var new_file = try std.fs.cwd().createFile(sub_path, .{});
                defer new_file.close();
            },
            else => {},
        };
    }
}

pub fn readFile(alloc: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer file.close();
    var buffer: [1024]u8 = undefined;
    var filereader = file.reader(&buffer);
    const reader = &filereader.interface;
    var file_writer = std.io.Writer.Allocating.init(alloc);

    _ = try reader.streamRemaining(&file_writer.writer);

    return file_writer.toOwnedSlice();
}

const example_day =
    \\const std = @import("std");
    \\const Allocator = std.mem.Allocator;
    \\
    \\const util = @import("../util.zig");
    \\const Buffers = util.Buffers;
    \\const readInt = util.readInt;
    \\
    \\pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {{
    \\    var buffers = try Buffers.init(alloc, {d});
    \\    defer buffers.deinit(alloc);
    \\
    \\    var timer = try std.time.Timer.start();
    \\    const p1 = try part1(alloc, buffers.a);
    \\    const p1_time = timer.lap();
    \\    const p2 = try part2(alloc, buffers.b);
    \\    const p2_time = timer.read();
    \\    try stdout.print(
    \\        \\Day{d:0>2}:
    \\        \\  part1: {{d}} {{d}}ns
    \\        \\  part2: {{d}} {{d}}ns
    \\        \\
    \\    , .{{
    \\        p1, p1_time,
    \\        p2, p2_time,
    \\    }});
    \\}}
    \\
    \\fn part1(alloc: Allocator, input: []const u8) !u32 {{
    \\    _ = alloc;
    \\    _ = input;
    \\    return 0;
    \\}}
    \\
    \\fn part2(alloc: Allocator, input: []const u8) !u32 {{
    \\    _ = alloc;
    \\    _ = input;
    \\    return 0;
    \\}}
;
