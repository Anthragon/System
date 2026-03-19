const sys = @import("../root.zig");

pub const enable = sys.assembly.flags.clear_interrupt;
pub const disable = sys.assembly.flags.set_interrupt;
