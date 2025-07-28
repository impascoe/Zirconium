const std = @import("std");

pub const ProgNode = struct {
    func_nodes: []FuncNode,

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("Program (\n{s}\n)", .{self.func_nodes});
    }
};

pub const FuncNode = struct {
    func_name: []const u8,
    return_type: []const u8,
    body: BlockNode,

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("\tFunction (\n\tname=\"{s}\",\n\treturn type={s}\n", .{ self.func_name, self.return_type });
        try writer.print("\tbody={s}\n\t)\n", .{self.body});
    }
};

pub const BlockNode = struct {
    statements: []StmtNode, // Array of statements (can be empty)

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("Block (\n", .{});
        for (self.statements) |stmt| {
            try stmt.format(fmt, options, writer); // Call the statement's format method
        }
        try writer.print("\t)", .{});
    }
};

pub const StmtNode = union(enum) {
    Expression: ExprNode,
    Return: ?ExprNode, // Return with optional expression
    Empty, // Explicit empty statement

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        switch (self) {
            .Expression => |expr| {
                try writer.print("\t\tStatement (\n\t\ttype=Expression\n", .{});
                try writer.print("\t\t\t", .{});
                try expr.format(fmt, options, writer);
                try writer.print("\n\t\t)\n", .{});
            },
            .Return => |maybe_expr| {
                try writer.print("\t\tStatement (\n\t\ttype=Return\n", .{});
                if (maybe_expr) |expr| {
                    try writer.print("\t\t\t", .{});
                    try expr.format(fmt, options, writer);
                } else {
                    try writer.print("\t\t\tvoid return", .{});
                }
                try writer.print("\n\t\t)\n", .{});
            },
            .Empty => try writer.print("\t\tStatement (\n\t\ttype=Empty\n\t\t)\n", .{}),
        }
    }
};

pub const ExprNode = struct {
    value: usize,

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("Expression (\n\t\t\t\tvalue={d}\n\t\t\t)", .{self.value});
    }
};
