const std = @import("std");

pub const ProgNode = struct {
    func_nodes: []FuncNode,

    pub fn format(self: @This(), writer: anytype) !void {
        try writer.print("Program:\n", .{});
        for (self.func_nodes) |func| {
            try func.format(writer, .{});
        }
    }
};

pub const FuncNode = struct {
    func_name: []const u8,
    return_type: []const u8,
    body: BlockNode,

    pub fn format(
        self: @This(),
        writer: anytype,
        fmt: std.fmt.FormatOptions,
    ) !void {
        try writer.print("\tFunction (\n\tname=\"{s}\",\n\treturn type={s}\n", .{
            self.func_name, self.return_type,
        });
        try writer.print("\tbody=", .{});
        try self.body.format(writer, fmt);
        try writer.print("\n\t)\n", .{});
    }
};

pub const BlockNode = struct {
    statements: []StmtNode,

    pub fn format(
        self: @This(),
        writer: anytype,
        fmt: std.fmt.FormatOptions,
    ) !void {
        try writer.print("Block (\n", .{});
        for (self.statements) |stmt| {
            try stmt.format(writer, fmt);
        }
        try writer.print("\t)", .{});
    }
};

pub const StmtNode = union(enum) {
    Expression: ExprNode,
    Return: ?ExprNode,
    Empty,

    pub fn format(
        self: @This(),
        writer: anytype,
        fmt: std.fmt.FormatOptions,
    ) !void {
        switch (self) {
            .Expression => |expr| {
                try writer.print("\t\tStatement (\n\t\ttype=Expression\n", .{});
                try writer.print("\t\t\t", .{});
                try expr.format(writer, fmt);
                try writer.print("\n\t\t)\n", .{});
            },
            .Return => |maybe_expr| {
                try writer.print("\t\tStatement (\n\t\ttype=Return\n", .{});
                if (maybe_expr) |expr| {
                    try writer.print("\t\t\t", .{});
                    try expr.format(writer, fmt);
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
        writer: anytype,
        _: std.fmt.FormatOptions,
    ) !void {
        try writer.print("Expression (\n\t\t\t\tvalue={d}\n\t\t\t)", .{self.value});
    }
};
