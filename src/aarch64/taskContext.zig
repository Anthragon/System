const std = @import("std");
const root = @import("root");

pub const TaskContext = extern struct {
    intnum: usize,

    pub inline fn set_instruction_ptr(s: *@This(), value: usize) void {
        _ = s;
        _ = value;
        unreachable;
    }
    pub inline fn get_instruction_ptr(s: *@This()) usize {
        _ = s;
        unreachable;
    }

    pub inline fn set_stack_ptr(s: *@This(), value: usize) void {
        _ = s;
        _ = value;
        unreachable;
    }
    pub inline fn get_stack_ptr(s: *@This()) usize {
        _ = s;
        unreachable;
    }

    pub inline fn set_frame_base(s: *@This(), value: usize) void {
        _ = s;
        _ = value;
        unreachable;
    }
    pub inline fn get_frame_base(s: *@This()) usize {
        _ = s;
        unreachable;
    }

    pub fn set_arg(s: *@This(), value: usize, arg: usize) void {
        _ = s;
        _ = value;
        _ = arg;
        unreachable;
    }
    pub fn get_arg(s: *@This(), arg: usize) usize {
        _ = s;
        _ = arg;
        unreachable;
    }

    pub fn set_ret(s: @This(), value: usize) void {
        _ = s;
        _ = value;
        unreachable;
    }
    pub fn get_ret(s: @This()) usize {
        _ = s;
        unreachable;
    }

    pub fn get_syscall_vector(s: *@This()) usize {
        _ = s;
        unreachable;
    }

    pub inline fn get_return(s: *@This()) usize {
        _ = s;
        unreachable;
    }

    pub fn set_flags(s: *@This(), flags: root.lib.common.TaskGeneralFlags) void {
        _ = s;
        _ = flags;
        unreachable;
    }
    pub fn get_flags(s: *@This()) root.system.TaskGeneralFlags {
        _ = s;
        unreachable;
    }
    pub fn set_privilege(s: *@This(), p: root.lib.Privilege) void {
        _ = s;
        _ = p;
        unreachable;
    }

    pub fn format(self: *const @This(), fmt: anytype) !void {
        _ = self;
        _ = fmt;
        unreachable;
    }
};
