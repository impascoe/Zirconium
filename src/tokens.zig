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
};
