const sys = @import("../root.zig");
const idt = @import("../tables/interruptDescriptorTable.zig");

pub const set_privilege = idt.set_privilege;
pub const mask_irq = undefined;
pub const unmask_irq = undefined;

pub const enable = sys.assembly.flags.clear_interrupt;
pub const disable = sys.assembly.flags.set_interrupt;
