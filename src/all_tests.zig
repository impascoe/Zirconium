// comptime forces the import to happen at compile time,
// forcing zig to run the tests in parser_test.zig
// source: https://stackoverflow.com/questions/75762207/how-to-test-multiple-files-in-zig

comptime {
    _ = @import("parser_test.zig");
}
