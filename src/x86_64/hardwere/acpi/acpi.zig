const std = @import("std");
const root = @import("root");
const endian = @import("builtin").cpu.arch.endian();

const acpi_tables = @import("tables.zig");
const Rsd = acpi_tables.Rsd;

const debug = root.debug;

const log = std.log.scoped(.acpi);

pub fn init() !void {
    const binfo = root.get_boot_info();
    const rsd_ptr = root.mem.ptrFromPhys(*align(1) Rsd, binfo.rsdp_physical);

    if (!std.mem.eql(u8, &rsd_ptr.signature, "RSD PTR ")) return error.Invalid_RSD_signature;

    const table = rsd_ptr.get_root_table();

    for (0..table.len()) |i| {
        const t = table.get_ptr(i);
        const sig = t.header.signature;
        log.debug("\n{} - rev {} - {s} - checksum {}", .{
            i,
            t.header.revision,
            t.header.signature,
            t.header.do_checksum(),
        });

        if (std.mem.eql(u8, sig[0..4], "APIC")) {
            decode_madt(t);
        } else if (std.mem.eql(u8, sig[0..4], "FACP")) {
            const fadt: *const acpi_tables.Fadt = @ptrCast(@alignCast(t));
            decode_fadt(fadt);
        } else if (std.mem.eql(u8, sig[0..4], "HPET")) {
            // TODO
            //const hpet: *const acpi_tables.Hpet = @ptrCast(t);
            //decode_hpet(hpet);
        } else if (std.mem.eql(u8, sig[0..4], "MCFG")) {
            // TODO
            //const mcfg: *const acpi_tables.Mcfg = @ptrCast(t);
            //decode_mcfg(mcfg);
        } else if (std.mem.eql(u8, sig[0..4], "BGRT")) {
            const bgrt: *const acpi_tables.Bgrt = @ptrCast(@alignCast(t));
            decode_bgrt(bgrt);
        } else log.debug("(Unknown table {s})", .{sig});

        log.debug("", .{});
    }
    log.debug("\nEnd of ACPI table", .{});
}

fn decode_madt(table: *const acpi_tables.Sdt) void {
    const header_size = @sizeOf(acpi_tables.SdtHeader);
    const madt_header_extra = 8;

    const start = header_size + madt_header_extra;
    const len = table.header.length - start;

    const entries = @as([*]const u8, @ptrCast(table))[start..];
    var basei: usize = 0;

    while (basei < len) {
        if (basei + 2 > len) break;

        const entry = entries[basei..];
        const entry_type = entry[0];
        const entry_size = entry[1];

        if (entry_size < 2 or basei + entry_size > len) {
            log.debug("Invalid MADT entry (type={}, size={})", .{ entry_type, entry_size });
            break;
        }
        switch (entry_type) {
            0 => {
                const proc_id = entry[2];
                const apic_id = entry[3];
                const flags = std.mem.readInt(u32, entry[4..8], endian);

                log.debug("\t0 - Processor local APIC:", .{});
                log.debug("\t  proc id:    {}", .{proc_id});
                log.debug("\t  apic id:    {}", .{apic_id});
                log.debug("\t  enabled:    {}", .{flags & 1 != 0});
                log.debug("\t  can enable: {}", .{flags & 1 != 0});
            },

            1 => {
                const io_apic_id = entry[2];
                const io_apic_addr = std.mem.readInt(u32, entry[4..8], endian);
                const int_base = std.mem.readInt(u32, entry[8..12], endian);

                log.debug("\t1 - IO APIC:", .{});
                log.debug("\t  APIC ID:   {}", .{io_apic_id});
                log.debug("\t  APIC ADDR: 0x{x:0>8}", .{io_apic_addr});
                log.debug("\t  GSIB:      0x{x:0>8}", .{int_base});
            },

            2 => {
                const bus_source = entry[2];
                const irq_source = entry[3];
                const global_system_interrupt = std.mem.readInt(u32, entry[4..8], endian);
                const flags = std.mem.readInt(u16, entry[8..10], endian);

                log.debug("\t2 - IO APIC Interrupt Source Override:", .{});
                log.debug("\t  BUS source: 0x{x:0>2}", .{bus_source});
                log.debug("\t  IRQ source: 0x{x:0>2}", .{irq_source});
                log.debug("\t  GSI:        0x{x:0>8}", .{global_system_interrupt});
                log.debug("\t  flags:      0x{x:0>4}", .{flags});
            },

            4 => {
                if (entry_size < 6) break;

                const cpu = entry[2];
                const flags = std.mem.readInt(u16, entry[3..5], endian);
                const lint = entry[5];

                const enabled = (flags & 1) != 0;
                const online_capable = (flags & 2) != 0;

                log.debug("\t4 - Local APIC NMI:", .{});
                log.debug("\t  cpu:   {}", .{cpu});
                log.debug("\t  lint:  {}", .{lint});
                log.debug("\t  flags: 0x{x:0>4}", .{flags});
                log.debug("\t  |  enabled:    {}", .{enabled});
                log.debug("\t  |  can enable: {}", .{online_capable});
            },

            else => log.debug("Unknown MADT entry type {} (size {})", .{ entry_type, entry_size }),
        }

        basei += entry_size;
    }
}

fn decode_fadt(table: *const acpi_tables.Fadt) void {
    log.debug("\tflags: 0x{x}", .{table.flags});
    log.debug("\t|  enabled: {}", .{table.flags & 1 != 0});
    log.debug("\t|  can enable: {}", .{table.flags & 2 != 0});
    log.debug("\tsmi command: 0x{x}", .{table.smi_cmd});
    log.debug("\tsci IRQ: 0x{x}", .{table.sci_int});
    log.debug("\tprefered profile: {s}", .{switch (table.preferred_pm_profile) {
        0 => "Unespecified",
        1 => "Desktop",
        2 => "Mobile",
        3 => "Workstation",
        4 => "Enterprise Server",
        5 => "SOHO Server",
        6 => "Appliance PC",
        7 => "Performance Server",
        else => "Reserved",
    }});
}

//fn decode_hpet(table: *const acpi_tables.Hadt) void {_ = table;}
//fn decode_mcfg(table: *const acpi_tables.Mcfg) void {_ = table;}

fn decode_bgrt(table: *const acpi_tables.Bgrt) void {
    log.debug("\tversion ID: {}", .{table.version_id});
    log.debug("\tstatus:     {}", .{table.status});
    log.debug("\ttype:       {s}", .{if (table.image_type == 0) "bitmap" else "unknown"});
    log.debug("\tpointer:    0x{x:0>16}", .{table.image_address});
    log.debug("\toffset X:   {}", .{table.image_x_offset});
    log.debug("\toffset Y:   {}", .{table.image_y_offset});
}
