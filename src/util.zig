const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Buffers = struct {
    a: []const u8,
    b: []const u8,

    const Self = @This();

    pub fn init(alloc: Allocator, day: comptime_int) !Self {
        const filename_a = std.fmt.comptimePrint("data/day{d:0>2}a.txt", .{day});
        const filename_b = std.fmt.comptimePrint("data/day{d:0>2}b.txt", .{day});
        return .{
            .a = try readFile(alloc, filename_a),
            .b = try readFile(alloc, filename_b),
        };
    }

    pub fn deinit(self: *Self, alloc: Allocator) void {
        alloc.free(self.a);
        alloc.free(self.b);
    }
};

pub fn readFile(alloc: Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer file.close();
    var buffer: [1024]u8 = undefined;
    var filereader = file.reader(&buffer);
    const reader = &filereader.interface;
    var file_writer = std.io.Writer.Allocating.init(alloc);

    _ = try reader.streamRemaining(&file_writer.writer);

    return file_writer.toOwnedSlice();
}

pub fn readInt(comptime T: type, input: []const u8, i: *usize) T {
    var output: T = 0;
    const sign = input[i.*] == '-';
    if (@typeInfo(T).int.signedness == .signed and sign) i.* += 1;
    while (i.* < input.len) : (i.* += 1) {
        switch (input[i.*]) {
            '0'...'9' => {
                output *= 10;
                output += input[i.*] - '0';
            },
            else => break,
        }
    }
    return if (@typeInfo(T).int.signedness == .signed and sign) -output else output;
}
