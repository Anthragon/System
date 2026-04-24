const std = @import("std");
const builtin = @import("builtin");
const boot = @import("root").lib.boot;
const limine = @import("limine.zig");
const arch = builtin.cpu.arch;

// limine requests
pub export var base_revision: limine.BaseRevision = .{ .revision = 3 };
pub export var framebuffer_request: limine.FramebufferRequest = .{};
pub export var memory_map_request: limine.MemoryMapRequest = .{};
pub export var kernel_addr_request: limine.KernelAddressRequest = .{};
pub export var hhdm_request: limine.HhdmRequest = .{};
pub export var rsdp_request: limine.RsdpRequest = .{};
pub export var kfile_request: limine.KernelFileRequest = .{};

extern var boot_info: boot.BootInfo;
extern fn main() callconv(.c) noreturn;

pub export fn __boot_entry__() callconv(.c) noreturn {
    asm volatile ("msr daifset, #0xf");

    if (!base_revision.is_supported()) done();
    if (framebuffer_request.response == null) done();
    if (framebuffer_request.response.?.framebuffer_count < 1) done();
    if (memory_map_request.response == null) done();
    if (kernel_addr_request.response == null) done();
    if (hhdm_request.response == null) done();
    if (rsdp_request.response == null) done();
    if (kfile_request.response == null) done();

    const fbuffer = framebuffer_request.response.?.framebuffers_ptr[0];
    const fbuffer_size = fbuffer.pitch * fbuffer.height;

    const mmap = memory_map_request.response.?;
    const addr = kernel_addr_request.response.?;
    const hhdm = hhdm_request.response.?;
    const rsdp = rsdp_request.response.?;
    var stbp: usize = undefined;

    asm volatile ("mov %[out], sp"
        : [out] "=r" (stbp),
    );

    const kfile = kfile_request.response.?.kernel_file;

    var boot_device_tag: boot.BootDeviceTag = undefined;
    const boot_device: boot.BootDevice = b: {
        if (kfile.mbr_disk_id != 0) {
            boot_device_tag = .mbr;
            break :b .{ .mbr = .{
                .disk_id = kfile.mbr_disk_id,
                .partition_index = kfile.partition_index,
            } };
        } else {
            boot_device_tag = .gpt;
            break :b .{ .gpt = .{
                .disk_uuid = @bitCast(kfile.gpt_disk_uuid),
                .part_uuid = @bitCast(kfile.gpt_part_uuid),
            } };
        }
    };

    boot_info = .{
        .kernel_base_physical = addr.physical_base,
        .kernel_base_virtual = addr.virtual_base,
        .kernel_stack_pointer_base = stbp,
        .hhdm_base_offset = hhdm.offset,
        .rsdp_physical = @intFromPtr(rsdp.address),

        .framebuffer = .{
            .framebuffer = fbuffer.address,
            .buffer_length = fbuffer_size,
            .width = fbuffer.width,
            .height = fbuffer.height,
            .pps = fbuffer.pitch,
        },

        .memory_map = mmap.entries_ptr,
        .memory_map_len = mmap.entry_count,

        .boot_device_tag = boot_device_tag,
        .boot_device = boot_device,
    };

    main();
    unreachable;
}

fn done() noreturn {
    while (true) asm volatile ("wfe");
    undefined;
}
