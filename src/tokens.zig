const std = @import("std");

pub const Token = struct {
    type: Type,

    pub fn format(self: @This(), writer: anytype) !void {
        try writer.print("{f}", .{self.type});
    }
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
    None,

    pub fn format(self: @This(), writer: anytype) !void {
        switch (self) {
            .Int => |value| {
                try writer.print("type: Int, value: {d}", .{value});
            },
            .Identifier => |value| {
                try writer.print("type: Identifier, value: \"{s}\"", .{value});
            },
            else => {
                try writer.print("type: {s}", .{@tagName(self)});
            },
        }
    }
};
