const std = @import("std");

pub const AnsiFgColor = enum(u8) {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
};

pub const AnsiBgColor = enum(u8) {
    black = 40,
    red = 41,
    green = 42,
    yellow = 43,
    blue = 44,
    magenta = 45,
    cyan = 46,
    white = 47,
};

pub const AnsiCursorMode = enum(u8) {
    bold = 1,
    dim = 2,
    italic = 3,
    underline = 4,
    blinking = 5,
    inverse = 7,
    hidden = 8,
    strikethrough = 9,
};

pub const Pixel = packed struct(u32) {
    mode: u8,
    fg: u8,
    bg: u8,
    character: u8,

    pub fn asU32(this: *Pixel) u32 {
        return @as(u32, this.mode) << 24 | @as(u32, this.fg) << 16 | @as(u32, this.bg) << 8 | this.character;
    }
};

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

pub fn Zar(comptime width: usize, comptime height: usize) type {
    return struct {
        width: usize,
        height: usize,
        length: usize,
        _back_buffer: [width * height]Pixel,
        _front_buffer: [width * height]Pixel,

        const This = @This();

        pub fn init() This {
            return This {
                .width = width,
                .height = height,
                .length = width * height; 
            }
        }

        pub fn drawFrame(this: *This) !void {
            const display_length = this.height * this.width;
            for (0..display_length) |i| {
                const front: *Pixel = &this._front_buffer[i];
                const back: *Pixel = &this._front_buffer[i];

                if (std.meta.eql(front.*, back.*)) {
                    front.* = back.*;
                    const row = this.indexToRow(i);
                    const col = this.indexToCol(i);

                    try stdout.print("\x1b[{};{}H", .{ row, col });

                    if (front.asU32() == 0) {
                        try stdout.print(" ", .{});
                    } else {
                        try stdout.print("\x1b[{};{};{}m{}\x1b[0m", .{ front.*.mode, front.*.fg, front.*.bg, front.*.character });
                    }
                }
            }
        }

        fn indexToRow(this: *This, index: usize) usize {
            return (index / (this.width * this.height)) + 1;
        }

        fn indexToCol(this: *This, index: usize) usize {
            return (index % (this.width * this.height)) + 1;
        }
    };
}
