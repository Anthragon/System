const std = @import("std");

var COM1_serial_writer: std.io.Writer = .{
    .buffer = &.{},
    .end = 0,
    .vtable = &serial_writer_vtable,
};
var COM2_serial_writer: std.io.Writer = .{
    .buffer = &.{},
    .end = 0,
    .vtable = &serial_writer_vtable,
};
const serial_writer_vtable: std.io.Writer.VTable = .{ .drain = serial_out };

pub fn init() !void {
    for (0..4) |i| {
        _ = i;
        @panic("Not implemented!");
        //uart_putchar(@truncate(i), '\n');
    }
}

pub fn chardev(dev: u8) *std.io.Writer {
    return switch (dev) {
        1 => &COM1_serial_writer,
        2 => &COM2_serial_writer,

        else => std.debug.panic("No chardev COM{}!", .{dev}),
    };
}

fn serial_out(w: *std.io.Writer, data: []const []const u8, splat: usize) !usize {
    const dev: u8 = b: {
        const wp = @intFromPtr(w);

        if (wp == @intFromPtr(&COM1_serial_writer)) {
            break :b 0;
        } else if (wp == @intFromPtr(&COM2_serial_writer)) {
            break :b 1;
        } else @panic("Invalid chardev!");
    };

    _ = splat;

    var count: usize = 0;
    for (data) |i| {
        uart_puts(dev, i);
        count += i.len;
    }

    return count;
}

inline fn is_buffer_empty(dev: u8) bool {
    _ = dev;
    @panic("Not implemented");
}
pub inline fn uart_putchar(dev: u8, char: u8) void {
    _ = dev;
    _ = char;
    @panic("Not implemented");
}
pub inline fn uart_puts(dev: u8, str: []const u8) void {
    _ = dev;
    _ = str;
    @panic("Not implemented");
}
