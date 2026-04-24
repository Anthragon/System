const std = @import("std");
const root = @import("root");
const lib = root.lib;
const debug = root.debug;

const log = std.log.scoped(.@"aarch64 PMM");

const paging = @import("paging.zig");

const units = root.utils.units.data;

pub const page_size = 4096;

pub var hhdm_offset: usize = undefined;
var total_memory_bytes: usize = undefined;

pub var kernel_page_start: usize = undefined;
pub var kernel_page_end: usize = undefined;

pub var kernel_virt_start: usize = undefined;
pub var kernel_virt_end: usize = undefined;

pub const atributes_ROX_privileged_fixed = lib.paging.Attributes{
    .privileged = true,

    .read = true,
    .write = true,
    .execute = true,

    .lock = true,
};

pub fn setup() void {
    log.debug("TODO", .{});
}

pub fn lsmemtable() callconv(.c) void {
    log.debug("TODO", .{});
}

/// Allocates and returns a single page
pub fn get_single_page(status: BlockStatus) *anyopaque {
    _ = status;
    log.debug("TODO", .{});
    unreachable;
}
pub fn get_multiple_pages(len: usize, status: BlockStatus) ?*anyopaque {
    _ = len;
    _ = status;
    log.debug("TODO", .{});
    unreachable;
}

pub inline fn virtFromPhys(phys: usize) usize {
    _ = phys;
    log.debug("TODO", .{});
    unreachable;
}
pub inline fn physFromVirt(virt: usize) usize {
    _ = virt;
    log.debug("TODO", .{});
    unreachable;
}
pub inline fn ptrFromPhys(comptime T: type, phys: usize) T {
    return @as(T, @ptrFromInt(virtFromPhys(phys)));
}
pub inline fn physFromPtr(ptr: anytype) usize {
    return physFromVirt(@intFromPtr(ptr));
}

const Block = extern struct {
    // start and length are in pages size
    start: usize,
    length: usize,

    status: BlockStatus,

    previous: ?*Block,
    next: ?*Block,
};

const BlockStatus = lib.paging.MemStatus;
