// TODO implement level-5 page mapping (99% unecessary)
const std = @import("std");
const root = @import("root");
const lib = root.lib;
const debug = root.debug;
const pmm = @import("pmm.zig");
const assemlby = @import("../asm/asm.zig");

const log = std.log.scoped(.@"aarch64 paging");

const Attributes = lib.paging.Attributes;
const MMapError = lib.paging.MMapErrorInterop;

pub fn enumerate_paging_features() void {
    log.err("TODO", .{});
    unreachable;
}

// Returns the cached active memory map
pub fn get_current_map() MapPtr {
    log.err("TODO", .{});
    unreachable;
}

// Loads the currently active memory map
pub fn load_commited_map() MapPtr {
    log.err("TODO", .{});
    unreachable;
}
// Active the currently loaded memory map
pub fn commit_map(map: MapPtr) void {
    _ = map;
    log.err("TODO", .{});
    unreachable;
}

// Creates a new empty memory map
pub fn create_new_map() MapPtr {
    log.err("TODO", .{});
    unreachable;
}

// Debug prints the selected memory map (lots of logs)
pub fn lsmemmap(map: MapPtr) void {
    _ = map;
    log.err("TODO", .{});
}

pub fn map_single_page(map: MapPtr, phys_base: usize, virt_base: usize, comptime size: usize, attributes: Attributes) !void {
    _ = map;
    _ = phys_base;
    _ = virt_base;
    _ = size;
    _ = attributes;
    log.err("TODO", .{});
}
pub fn map_range(map: MapPtr, phys_base: usize, virt_base: usize, length: usize, attributes: Attributes) !void {
    log.debug("mapping range ${X}..${X} -> ${X}..${X} ({s}{s}{s}{s}{s}{s})", .{
        phys_base,
        phys_base + length,
        virt_base,
        virt_base + length,
        if (attributes.read) "R" else "-",
        if (attributes.write) "W" else "-",
        if (attributes.execute) "X" else "-",
        if (attributes.privileged) "P" else "-",
        if (attributes.disable_cache) "-" else "C",
        if (attributes.lock) "L" else "-",
    });

    _ = map;
    log.err("TODO", .{});
}

pub fn unmap_single_page(map: MapPtr, virt_base: usize) !void {
    _ = map;
    _ = virt_base;
}
pub fn unmap_range(map: MapPtr, virt_base: usize, length: usize) !void {
    _ = map;
    _ = virt_base;
    _ = length;
}

pub fn phys_from_ptr(map: MapPtr, ptr: anytype) ?usize {
    return phys_from_virt(map, @intFromPtr(ptr));
}
pub fn phys_from_virt(map: MapPtr, vaddr: usize) ?usize {
    _ = map;
    _ = vaddr;
    log.err("TODO", .{});
}

inline fn Table(Entry: type) type {
    return *[512]Entry;
}

pub const MapPtr = *usize;
