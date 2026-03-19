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
        log.debug("{} - rev {} - {s} - checksum {}", .{
            i,
            t.header.revision,
            t.header.signature,
            t.header.do_checksum(),
        });

        if (std.mem.eql(u8, sig[0..4], "APIC")) {
            decode_madt(t);
        } else if (std.mem.eql(u8, sig[0..4], "FACP")) {
            // TODO
            //const fadt: *const acpi_tables.Fadt = @ptrCast(t);
            //decode_fadt(fadt);
        } else if (std.mem.eql(u8, sig[0..4], "HPET")) {
            // TODO
            //const hpet: *const acpi_tables.Hpet = @ptrCast(t);
            //decode_hpet(hpet);
        } else if (std.mem.eql(u8, sig[0..4], "MCFG")) {
            // TODO
            //const mcfg: *const acpi_tables.Mcfg = @ptrCast(t);
            //decode_mcfg(mcfg);
        } else log.debug("(Unknown table {s})", .{sig});
    }
}

fn decode_madt(table: *const acpi_tables.Sdt) void {
    const len = table.header.length - 8;
    const entries: [*]const u8 = @as([*]const u8, @ptrCast(&table.entries))[8..];
    var basei: usize = 0;

    while (basei < len) {
        const entry = entries[basei..];

        const entry_type = entry[0];
        const entry_size = entry[1];
        if (entry_size < 2) break;

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

            else => log.debug("Unhandled entry type {}", .{entry_type}),
        }

        basei += entry_size;
    }
}

//fn decode_fadt(table: *const acpi_tables.Fadt) void {
//    _ = table;
//}

//fn decode_hpet(table: *const acpi_tables.Hadt) void {_ = table;}
//fn decode_mcfg(table: *const acpi_tables.Mcfg) void {_ = table;}
