const std = @import("std");
const Writer = std.io.Writer;

var serial_ports: [2]Writer = .{
    .{ .buffer = &.{}, .end = 0, .vtable = &serial_writer_vtable },
    .{ .buffer = &.{}, .end = 0, .vtable = &serial_writer_vtable },
};
const serial_writer_vtable: Writer.VTable = .{ .drain = serial_out };

pub fn init() !void {
    uart_putchar(0, "UART initialised");
}

pub fn get_writer(port: u8) *Writer {
    if (port > serial_ports.len) std.debug.panic("No UART port {}!", .{port});
    return &serial_ports[port];
}

fn serial_out(w: *Writer, data: []const []const u8, splat: usize) !usize {
    const dev: u8 = brk: {
        const base = @intFromPtr(&serial_ports[0]);
        const end = @intFromPtr(&serial_ports[0]) + @sizeOf(Writer) * serial_ports.len;
        const ptr = @intFromPtr(w);
        if (ptr < base or ptr >= end) @panic("Invalid writer!");
        break :brk @intCast((ptr - base) / @sizeOf(Writer));
    };

    _ = splat;

    var count: usize = 0;
    for (data) |i| {
        uart_puts(dev, i);
        count += i.len;
    }

    return count;
}

inline fn is_buffer_empty(dev: u9) bool {
    const base = uart_base(dev);
    return (uartfr(base).* & (1 << 5)) == 0;
}
pub inline fn uart_putchar(dev: u9, char: u8) void {
    const base = uart_base(dev);
    while ((uartfr(base).* & (1 << 5)) != 0) {}
    uartdr(base).* = char;
}
pub inline fn uart_puts(dev: u9, str: []const u8) void {
    for (str) |c| uart_putchar(dev, c);
}

inline fn uart_base(dev: u9) usize {
    return switch (dev) {
        0 => 0x09000000,
        1 => 0x09010000,
        else => @panic("UART inválida"),
    };
}
inline fn uartdr(base: usize) *volatile u32 {
    return @ptrFromInt(base + 0x00);
}

inline fn uartfr(base: usize) *volatile u32 {
    return @ptrFromInt(base + 0x18);
}
