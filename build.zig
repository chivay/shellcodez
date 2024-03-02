const std = @import("std");

const targets: []const std.Target.Query = &.{
    .{ .cpu_arch = .aarch64, .os_tag = .linux },
    .{ .cpu_arch = .x86_64, .os_tag = .linux },
};

pub fn buildShellcode(b: *std.Build, query: std.Target.Query, name: []const u8, path: std.Build.LazyPath) void {
    const optimize = std.builtin.OptimizeMode.ReleaseSmall;
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = "src/start.zig" },
        .target = b.resolveTargetQuery(query),
        .optimize = optimize,
        .single_threaded = true,
    });
    exe.link_eh_frame_hdr = false;
    exe.link_emit_relocs = false;
    exe.use_llvm = true;
    exe.pie = true;
    exe.setLinkerScript(.{ .path = "src/linker.ld" });

    const sc = b.createModule(.{
        .root_source_file = path,
        .pic = true,
        .single_threaded = true,
        .optimize = optimize,
        .target = b.resolveTargetQuery(query),
    });
    exe.root_module.addImport("main", sc);

    const copied = b.addObjCopy(exe.getEmittedBin(), .{ .format = .bin, .only_section = ".text" });

    const install_step = b.addInstallBinFile(
        copied.getOutput(),
        std.fmt.allocPrint(b.allocator, "{s}.bin", .{name}) catch unreachable,
    );
    b.getInstallStep().dependOn(&install_step.step);
    b.installArtifact(exe);
}

pub fn build(b: *std.Build) void {
    for (targets) |t| {
        buildShellcode(
            b,
            t,
            std.fmt.allocPrint(b.allocator, "{s}-{s}", .{ "execve", @tagName(t.cpu_arch.?) }) catch unreachable,
            .{ .path = "src/main.zig" },
        );
        buildShellcode(
            b,
            t,
            std.fmt.allocPrint(b.allocator, "{s}-{s}", .{ "revshell", @tagName(t.cpu_arch.?) }) catch unreachable,
            .{ .path = "src/revshell.zig" },
        );
    }
}
