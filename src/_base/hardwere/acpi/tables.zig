const std = @import("std");
const root = @import("root");
const builtin = @import("builtin");

const mem = root.mem;
const endian = builtin.cpu.arch.endian();

const debug = root.debug;

pub const Rsd = extern struct {
    signature: [8]u8,
    checksum: u8,
    oem_id: [6]u8,
    revision: u8,
    rsdt_addr: u32, // deprecated since version 2.0

    length: u32,
    xsdt_addr: u64,
    ext_checksum: u8,
    _reserved_0: [3]u8,

    pub fn get_root_table(s: @This()) *Rsdt {
        const phys: usize = if (s.revision >= 2) s.xsdt_addr else @as(usize, @intCast(s.rsdt_addr));

        return mem.ptrFromPhys(*Rsdt, phys);
    }
};

pub const SdtHeader = extern struct {
    signature: [4]u8,
    length: u32,
    revision: u8,
    checksum: u8,
    oem_id: [6]u8,
    oem_table_id: [8]u8,
    oem_revision: u32,
    creator_id: u32,
    creator_revision: u32,

    pub fn do_checksum(tableHeader: *const @This()) bool {
        const ptr = @as([*]u8, @ptrCast(@alignCast(@constCast(tableHeader))));
        const len = tableHeader.length;

        var sum: u8 = 0;
        for (0..len) |i| {
            sum +%= ptr[i];
        }
        return sum == 0;
    }
};
const GenericAddrStructure = extern struct {
    addr_space: u8,
    bit_width: u8,
    bit_offset: u8,
    access_size: u8,
    base: u64,
};

// Bruh for some reason the root uses a diferent logic
// fuck intel
pub const Sdt = struct {
    header: SdtHeader,
    entries: [0]u8,

    pub fn len(s: *@This()) usize {
        const b = s.header.length - @sizeOf(SdtHeader);
        return b / @as(usize, if (s.header.revision >= 2) 8 else 4);
    }

    pub fn get_ptr(s: *@This(), index: usize) *const Sdt {
        if (index >= s.len()) @panic("Out of bounds");

        const ptr: [*]const u8 = @ptrCast(&s.entries);

        const v: usize = if (s.header.revision >= 2)
            std.mem.readInt(u64, ptr[index * 8 ..][0..8], endian)
        else
            @intCast(std.mem.readInt(u32, ptr[index * 4 ..][0..4], endian));

        return mem.ptrFromPhys(*Sdt, v);
    }

    pub fn find_acpi_table(sdt: *const Sdt, sig: [4]u8) ?*const Sdt {
        const count = sdt.len();
        for (0..count) |i| {
            const table = sdt.get_ptr(i);
            if (table.header.signature == sig) return table;
        }
        return null;
    }
};
pub const Rsdt = struct {
    header: SdtHeader,
    entries: [0]u8,

    pub fn len(s: *@This()) usize {
        const b = s.header.length - @sizeOf(SdtHeader);
        return b / @as(usize, if (std.mem.eql(u8, &s.header.signature, "XSDT")) 8 else 4);
    }

    pub fn get_ptr(s: *@This(), index: usize) *const Sdt {
        if (index >= s.len()) @panic("Out of bounds");

        const ptr: [*]const u8 = @ptrCast(&s.entries);

        const v: usize = if (std.mem.eql(u8, &s.header.signature, "XSDT"))
            std.mem.readInt(u64, ptr[index * 8 ..][0..8], endian)
        else
            @intCast(std.mem.readInt(u32, ptr[index * 4 ..][0..4], endian));

        return mem.ptrFromPhys(*Sdt, v);
    }

    pub fn find_acpi_table(sdt: *const @This(), sig: [4]u8) ?*const Sdt {
        const count = sdt.len();
        for (0..count) |i| {
            const table = sdt.get_ptr(i);
            if (table.header.signature == sig) return table;
        }
        return null;
    }
};
pub const Fadt = extern struct {
    header: SdtHeader,

    firmware_ctrl: u32,
    dsdt: u32,

    reserved: u8,

    preferred_pm_profile: u8,
    sci_int: u16,
    smi_cmd: u32,
    acpi_enable: u8,
    acpi_disable: u8,
    s4bios_req: u8,
    pstate_control: u8,

    pm1a_event_block: u32,
    pm1b_event_block: u32,
    pm1a_control_block: u32,
    pm1b_control_block: u32,
    pm2_control_block: u32,
    pm_timer_block: u32,
    gpe0_block: u32,
    gpe1_block: u32,

    pm1_event_length: u8,
    pm1_control_length: u8,
    pm2_control_length: u8,
    pm_timer_length: u8,
    gpe0_length: u8,
    gpe1_length: u8,
    gpe1_base: u8,
    cstate_control: u8,

    worst_c2_latency: u16,
    worst_c3_latency: u16,
    flush_size: u16,
    flush_stride: u16,

    duty_offset: u8,
    duty_width: u8,
    day_alarm: u8,
    month_alarm: u8,
    century: u8,

    boot_architecture_flags: u16,
    reserved2: u8,
    flags: u32,

    reset_reg: GenericAddrStructure,
    reset_value: u8,
    reserved3: [3]u8,

    x_firmware_ctrl: u64,
    x_dsdt: u64,

    x_pm1a_event_block: GenericAddrStructure,
    x_pm1b_event_block: GenericAddrStructure,
    x_pm1a_control_block: GenericAddrStructure,
    x_pm1b_control_block: GenericAddrStructure,
    x_pm2_control_block: GenericAddrStructure,
    x_pm_timer_block: GenericAddrStructure,
    x_gpe0_block: GenericAddrStructure,
    x_gpe1_block: GenericAddrStructure,
};
pub const Bgrt = extern struct {
    header: SdtHeader,
    version_id: u16,
    status: u8,
    image_type: u8,
    image_address: u64,
    image_x_offset: u32,
    image_y_offset: u32,
};
