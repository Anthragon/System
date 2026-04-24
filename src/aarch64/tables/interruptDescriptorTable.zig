const std = @import("std");
const root = @import("root");
const sys = root.system;
const TaskContext = @import("../taskContext.zig").TaskContext;

const debug = root.debug;
const log = std.log.scoped(.@"xaarch64 IDT");
const handler_impl = @extern(
    ?*const fn (*TaskContext) callconv(.c) void,
    .{ .name = "interrupt_handler" },
) orelse @panic("Expected 'interrupt_handler' function implementation");

pub fn install() void {
    undefined;
}
pub fn set_privilege(int: u8, privilege: root.lib.Privilege) void {
    _ = int;
    _ = privilege;
    unreachable;
}

pub fn mask_idt(int: u8) void {
    _ = int;
    unreachable;
}
pub fn unmask_idt(int: u8) void {
    _ = int;
    unreachable;
}

export fn __nternal_interrupt_handler__(fptr: u64) void {
    const int_frame: *TaskContext = @ptrFromInt(fptr);
    handler_impl(int_frame);
    unreachable;
}
