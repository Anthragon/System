const root = @import("../root.zig");
const idt = @import("../tables/interruptDescriptorTable.zig");
const pic = @import("pic.zig");

pub const set_privilege = idt.set_privilege;
pub const mask_irq = pic.pic_disable;
pub const unmask_irq = pic.pic_enable;

pub const enable = root.assembly.flags.set_interrupt;
pub const disable = root.assembly.flags.clear_interrupt;
