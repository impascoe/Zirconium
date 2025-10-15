const std = @import("std");
const zir = @import("./zir.zig");

const Token = zir.tokens.Token;
const Parser = zir.Parser;

test "init" {
    const token = Token{ .type = .Unknown };
    const token_arr = [1]Token{token};

    const parser = Parser.init(&token_arr);
    try std.testing.expect(parser.tokens.len == 1);
}

test "parse function declaration" {
    const test_tokens = [_]Token{
        Token{ .type = .{ .Identifier = "func" } },
        Token{ .type = .{ .Identifier = "main" } },
        Token{ .type = .LeftParenthesis },
        Token{ .type = .RightParenthesis },
        Token{ .type = .{ .Identifier = "int" } },
        Token{ .type = .LeftBrace },
        Token{ .type = .{ .Identifier = "return" } },
        Token{ .type = .{ .Int = 0 } },
        Token{ .type = .Semicolon },
        Token{ .type = .RightBrace },

        Token{ .type = .{ .Identifier = "func" } },
        Token{ .type = .{ .Identifier = "testfunc" } },
        Token{ .type = .LeftParenthesis },
        Token{ .type = .RightParenthesis },
        Token{ .type = .{ .Identifier = "int" } },
        Token{ .type = .LeftBrace },
        Token{ .type = .{ .Identifier = "return" } },
        Token{ .type = .{ .Int = 15 } },
        Token{ .type = .Semicolon },
        Token{ .type = .RightBrace },
        Token{ .type = .EOF },
    };

    var parser = Parser.init(&test_tokens);
    const prog = try parser.parse();

    try std.testing.expect(prog.func_nodes.len == 2);
    try std.testing.expect(std.mem.eql(u8, prog.func_nodes[0].func_name, "main"));
    try std.testing.expect(std.mem.eql(u8, prog.func_nodes[0].return_type, "int"));
    try std.testing.expect(std.mem.eql(u8, prog.func_nodes[1].func_name, "testfunc"));
    try std.testing.expect(std.mem.eql(u8, prog.func_nodes[1].return_type, "int"));
}

test "parse program missing EOF" {
    // Create tokens WITHOUT EOF at the end
    const test_tokens = [_]Token{
        Token{ .type = .{ .Identifier = "func" } },
        Token{ .type = .{ .Identifier = "main" } },
        Token{ .type = .LeftParenthesis },
        Token{ .type = .RightParenthesis },
        Token{ .type = .LeftBrace },
        Token{ .type = .RightBrace },
        // Notice: NO EOF token here!
    };

    var parser = Parser.init(&test_tokens);

    // Should still work because parser.peek() returns EOF when out of bounds
    const result = try parser.parse();
    try std.testing.expect(result.func_nodes.len == 1);
}
