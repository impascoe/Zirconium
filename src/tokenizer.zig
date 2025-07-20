const std = @import("std");

pub fn tokenize(file_path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const input = try std.heap.page_allocator.alloc(u8, file_size);

    const bytes_read = try file.readAll(input);
    if (bytes_read != file_size) {
        std.heap.page_allocator.free(input);
        return error.IncompleteRead;
    }

    var tokens = std.ArrayList(u8).init(std.heap.page_allocator);
    defer tokens.deinit();
    var position: usize = 0;

    while (position < input.len) {
        const current = input[position];

        if (std.ascii.isAlphanumeric(current)) {
            if (std.ascii.isAlphabetic(current)) {}
            std.debug.print("{c}", .{current});
        } else if (std.ascii.isWhitespace(current)) {
            std.debug.print("{c}", .{current});
        } else {
            if (current == '(') {
                std.debug.print("{c}", .{current});
            }
            if (current == ')') {
                std.debug.print("{c}", .{current});
            }
            if (current == '{') {
                std.debug.print("{c}", .{current});
            }
            if (current == '}') {
                std.debug.print("{c}", .{current});
            }
            if (current == ';') {
                std.debug.print("{c}", .{current});
            }
        }
        position += 1;
    }
    return tokens.toOwnedSlice();
}
