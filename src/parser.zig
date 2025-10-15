const std = @import("std");
const ast = @import("ast.zig");

const Token = @import("tokens.zig").Token;
const TokenType = @import("tokens.zig").Type;

pub const Parser = struct {
    tokens: []const Token,
    current: usize,
    previous: usize,

    pub fn init(tokens: []const Token) Parser {
        return Parser{
            .tokens = tokens,
            .current = 0,
            .previous = 0,
        };
    }

    pub fn peek(self: *const Parser) Token {
        if (self.current >= self.tokens.len) {
            return Token{ .type = .EOF };
        }
        return self.tokens[self.current];
    }

    pub fn advance(self: *Parser) Token {
        if (self.current >= self.tokens.len) {
            return Token{ .type = .EOF };
        }
        self.previous = self.current;
        self.current += 1;
        return self.tokens[self.previous];
    }

    pub fn previousToken(self: *const Parser) Token {
        if (self.previous >= self.tokens.len) {
            return Token{ .type = .EOF };
        }
        return self.tokens[self.previous];
    }

    pub fn isAtEnd(self: *const Parser) bool {
        return self.peek().type == .EOF;
    }

    pub fn parse(self: *Parser) !ast.ProgNode {
        return self.parseProgram();
    }

    fn parseProgram(self: *Parser) !ast.ProgNode {
        var functions = std.ArrayList(ast.FuncNode).empty;
        defer functions.deinit(std.heap.page_allocator);
        while (self.peek().type != TokenType.EOF) {
            const function = try self.parseFunction();
            try functions.append(std.heap.page_allocator, function);
        }
        return ast.ProgNode{
            .func_nodes = try functions.toOwnedSlice(std.heap.page_allocator),
        };
    }

    fn parseFunction(self: *Parser) !ast.FuncNode {
        if (self.isKeyword("func")) {
            _ = self.advance(); // consume "func"

            var func_name: []const u8 = "";
            if (self.getCurrentIdentifier()) |name| {
                std.debug.print("Found function: {s}\n", .{name});
                func_name = name;
                _ = self.advance(); // consume function name
            }

            if (self.isToken(.LeftParenthesis)) {
                _ = self.advance(); // consume "("
            }

            if (self.isToken(.RightParenthesis)) {
                _ = self.advance(); // consume ")"
            }
            std.debug.print("token found: ({f})\n", .{self.peek()});
            // consume return type value
            var return_type: []const u8 = "";
            if (self.getCurrentIdentifier()) |ret_type| {
                std.debug.print("Found return type: {s}\n", .{ret_type});
                return_type = ret_type;
                _ = self.advance(); // consume function name
            }

            const body = try self.parseBlock();

            std.debug.print("token found: ({f})\n", .{self.peek()});

            // Continue parsing...
            return ast.FuncNode{
                .func_name = func_name,
                .func_params = "", // Placeholder for parameters
                .return_type = return_type,
                .body = body,
            };
        } else {
            std.debug.print("Unexpected token found: ({f})\n", .{self.peek()});
            return error.UnexpectedToken;
        }
    }

    fn parseBlock(self: *Parser) !ast.BlockNode {
        var statements = std.ArrayList(ast.StmtNode).empty;
        defer statements.deinit(std.heap.page_allocator);

        // Expect opening brace
        if (self.isToken(.LeftBrace)) {
            _ = self.advance();
        }

        // Parse statements until closing brace
        while (!self.isToken(.RightBrace) and !self.isAtEnd()) {
            const stmt = try self.parseStatement();
            try statements.append(std.heap.page_allocator, stmt);
        }

        // Expect closing brace
        if (self.isToken(.RightBrace)) {
            _ = self.advance();
        }

        return ast.BlockNode{
            .statements = try statements.toOwnedSlice(std.heap.page_allocator),
        };
    }

    // TODO: create different statement types e.g.
    // return statement, for future proofing,
    // just use switch as seen in parseExpression
    fn parseStatement(self: *Parser) !ast.StmtNode {
        // Handle empty statement (just a semicolon)
        if (self.isToken(.Semicolon)) {
            _ = self.advance();
            std.debug.print("empty statement", .{});
            return ast.StmtNode.Empty;
        }

        // Handle return statement
        if (self.isKeyword("return")) {
            return try self.parseReturnStatement();
        }

        // Handle expression statement
        const expr = try self.parseExpression();

        // Expect semicolon after expression
        if (self.isToken(.Semicolon)) {
            _ = self.advance();
        }

        return ast.StmtNode{ .Expression = expr };
    }

    fn parseReturnStatement(self: *Parser) !ast.StmtNode {
        _ = self.advance(); // consume "return"

        // Check if it's an empty return (void function)
        if (self.isToken(.Semicolon)) {
            _ = self.advance(); // consume semicolon
            return ast.StmtNode{ .Return = null }; // Empty return
        }

        // Parse return expression
        const expr = try self.parseExpression();

        if (self.isToken(.Semicolon)) {
            _ = self.advance();
        }

        return ast.StmtNode{ .Return = expr };
    }

    fn parseExpression(self: *Parser) !ast.ExprNode {
        const token = self.advance();
        return switch (token.type) {
            .Int => |value| {
                return ast.ExprNode{ .value = value };
            },
            else => {
                return error.UnexpectedToken;
            },
        };
    }

    fn isToken(self: *Parser, token_type: std.meta.Tag(TokenType)) bool {
        return std.meta.activeTag(self.peek().type) == token_type;
    }

    fn isKeyword(self: *Parser, keyword: []const u8) bool {
        return switch (self.peek().type) {
            .Identifier => |id| std.mem.eql(u8, id, keyword),
            else => false,
        };
    }

    fn getCurrentIdentifier(self: *Parser) ?[]const u8 {
        return switch (self.peek().type) {
            .Identifier => |id| id,
            else => null,
        };
    }
};
