const std = @import("std");

pub const Token = struct {
    type: Type,
};

pub const Type = union(enum) {
    Int: u8,
    Identifier: []const u8,
    LeftParenthesis,
    RightParenthesis,
    LeftBrace,
    RightBrace,
    Semicolon,
    EOF,
    Unknown,
    Whitespace,

    pub fn format(self: Type, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        switch (self) {
            .Int => |value| {
                try writer.print("type = Int, value = {d}", .{value});
            },
            .Identifier => |value| {
                try writer.print("type = Identifier, value = \"{s}\"", .{value});
            },
            else => {
                try writer.print("type = {s}", .{@tagName(self)});
            },
        }
    }
};
