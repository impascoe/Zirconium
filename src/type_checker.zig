const std = @import("std");
const ast = @import("ast.zig");

pub const TypeChecker = struct {
    pub fn check(prog: ast.ProgNode) !void {
        // Placeholder for type checking logic
        std.debug.print("Type checking program with {d} functions\n", .{prog.func_nodes.len});

        // if (!containsMain(prog)) {
        //     return error.MissingMainFunction;
        // }

        if (try hasDuplicateDecls(prog.func_nodes, std.heap.page_allocator)) {
            return error.DuplicateFunctionNames;
        }

        for (prog.func_nodes) |func| {
            std.debug.print("Function: {s}\n", .{func.func_name});
        }
    }
};

// Deciding whether to enforce having a main function later
// fn containsMain(prog: ast.ProgNode) bool {
//     for (prog.func_nodes) |func| {
//         if (std.mem.eql(u8, func.func_name, "main")) {
//             return true;
//         }
//     }
//     return false;
// }

fn hasDuplicateDecls(functions: []ast.FuncNode, allocator: std.mem.Allocator) !bool {
    var seen = std.StringHashMap([]const u8).init(allocator);
    defer seen.deinit();

    for (functions) |func| {
        if (seen.get(func.func_name) != null) {
            return true; // Duplicate found
        }
        try seen.put(func.func_name, func.func_name);
    }
    return false; // No duplicates
}
