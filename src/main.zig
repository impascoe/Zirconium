const std = @import("std");
const tokenizer = @import("tokenizer.zig");
const Parser = @import("parser.zig").Parser;

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: zrc [filename]\n", .{});
        return;
    }

    const file_path = args[1];

    const result = try tokenizer.tokenize(file_path);
    defer tokenizer.freeTokens(result);

    var ast = Parser.init(result);
    const program_ast = try ast.parse();
    std.debug.print("program_ast: {f}\n", .{program_ast});

    // var i: usize = 0;
    // while (i < result.len) : (i += 1) {
    //     const token = result[i];
    //     std.debug.print("{}\n", .{token});
    // }
}
