const std = @import("std");
const Token = @import("tokens.zig").Token;
const TokenType = Token.Type;
const print = std.debug.print;

pub fn tokenize(file_path: []const u8) ![]Token {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    const file_size = try file.getEndPos();
    const input = try std.heap.page_allocator.alloc(u8, file_size);
    defer std.heap.page_allocator.free(input);

    const bytes_read = try file.readAll(input);
    if (bytes_read != file_size) {
        std.heap.page_allocator.free(input);
        return error.IncompleteRead;
    }

    var tokens = std.ArrayList(Token).init(std.heap.page_allocator);
    defer tokens.deinit();
    var position: usize = 0;

    while (position < input.len) {
        const current: u8 = input[position];
        print("current char: {c}\n", .{current});
        if (std.ascii.isAlphabetic(current)) {
            const start_pos: usize = position;
            position += 1;
            while (position < input.len and std.ascii.isAlphanumeric(input[position])) {
                position += 1;
            }
            const identifier_slice = input[start_pos..position];
            const identifier_copy = try std.heap.page_allocator.dupe(u8, identifier_slice);
            print("Parsed identifier: {s}\n", .{identifier_copy});
            try tokens.append(Token{ .type = .{ .Identifier = identifier_copy } });
        } else if (std.ascii.isDigit(current)) {
            var value: u8 = current - '0';
            position += 1;
            while (position < input.len and std.ascii.isDigit(input[position])) {
                value *= 10;
                value += input[position] - '0';
                position += 1;
            }
            print("Parsed integer: {}\n", .{value});
            try tokens.append(Token{ .type = .{ .Int = value } });
        } else if (std.ascii.isWhitespace(current)) {
            position += 1;
            continue;
        } else {
            switch (current) {
                '(' => try tokens.append(Token{ .type = .LeftParenthesis }),
                ')' => try tokens.append(Token{ .type = .RightParenthesis }),
                '{' => try tokens.append(Token{ .type = .LeftBrace }),
                '}' => try tokens.append(Token{ .type = .RightBrace }),
                ';' => try tokens.append(Token{ .type = .Semicolon }),
                else => try tokens.append(Token{ .type = .Unknown }),
            }
            position += 1;
        }
    }
    tokens.append(Token{ .type = .EOF }) catch unreachable;
    return tokens.toOwnedSlice();
}

pub fn freeTokens(tokens: []Token) void {
    for (tokens) |token| {
        switch (token.type) {
            .Identifier => |identifier| {
                std.heap.page_allocator.free(identifier);
            },
            else => {},
        }
    }
    std.heap.page_allocator.free(tokens);
}
