pub const flags = @import("flags.zig");

pub inline fn halt() noreturn {
    flags.set_interrupt();
    asm volatile ("wfi");
    while (true) {}
}
