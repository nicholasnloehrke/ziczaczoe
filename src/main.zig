const std = @import("std");
const zar_lib = @import("zar.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("ZAR HAHAHAHA\n", .{});
    try bw.flush();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();

    comptime var zar = zar_lib.Zar(100, 100);

    while (true) {
        try zar.drawFrame();
    }

}