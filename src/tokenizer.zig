const std = @import("std");
const Token = @import("tokens.zig").Token;
const TokenType = Token.Type;

pub fn tokenize(file_path: []const u8) ![]Token {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const input = try std.heap.page_allocator.alloc(u8, file_size);

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

        switch (current) {
            '0'...'9' => {
                try tokens.append(get_token_int(input, &position));
                continue; // position already updated in get_token_int
            },
            ' ' => try tokens.append(Token{ .type = .Whitespace }),
            '\t' => try tokens.append(Token{ .type = .Whitespace }),
            '\n' => try tokens.append(Token{ .type = .Whitespace }),
            '\r' => try tokens.append(Token{ .type = .Whitespace }),
            '(' => try tokens.append(Token{ .type = .LeftParenthesis }),
            ')' => try tokens.append(Token{ .type = .RightParenthesis }),
            '{' => try tokens.append(Token{ .type = .LeftBrace }),
            '}' => try tokens.append(Token{ .type = .RightBrace }),
            ';' => try tokens.append(Token{ .type = .Semicolon }),
            else => try tokens.append(Token{ .type = .Unknown }),
        }
        position += 1;
    }

    tokens.append(Token{ .type = .{ .Identifier = "test" } }) catch unreachable;
    tokens.append(Token{ .type = .EOF }) catch unreachable;
    return tokens.toOwnedSlice();
}

fn get_token_int(input: []const u8, position: *usize) Token {
    var value: usize = 0;
    while (true) {
        const current = input[*position];
        if (!std.ascii.isDigit(current)) break;
        value = value * 10 + (current - '0');
        position.* += 1;
    }
    return Token{ .type = .{ .Int = value } };
}
