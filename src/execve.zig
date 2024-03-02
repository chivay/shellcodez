const std = @import("std");
const os = std.os;

const EXECUTABLE = "/bin/sh";

pub fn main() void {
    _ = os.linux.syscall3(.execve, @intFromPtr(EXECUTABLE), 0, 0);
}
