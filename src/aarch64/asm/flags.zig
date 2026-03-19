pub inline fn set_interrupt() void {
    asm volatile ("msr daifclr, #2");
}
pub inline fn clear_interrupt() void {
    asm volatile ("msr daifset, #2");
}
