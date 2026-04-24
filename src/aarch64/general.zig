const std = @import("std");

const root = @import("root");
const debug = root.debug;

const log = std.log.scoped(.aarch64);

pub fn pre_init() !void {
    log.err("TODO", .{});
    unreachable;
}

pub fn post_init() !void {
    log.err("TODO", .{});
    unreachable;
}
