const builtin = @import("builtin");
const std = @import("std");
const main = @import("main");

extern var bss_start: u8;
extern var bss_end: u8;

pub export fn _start() linksection(".startup") callconv(.Naked) noreturn {
    asm volatile (switch (builtin.cpu.arch) {
            .x86_64 =>
            \\ xorl %%ebp, %%ebp
            \\ andq $-16, %%rsp
            \\ callq %[entrypoint:P]
            ,
            .aarch64, .aarch64_be =>
            \\ mov fp, #0
            \\ mov lr, #0
            \\ nop
            \\ bl %[entrypoint]
            ,
            else => @compileError("Unsupported arch"),
        }
        :
        : [entrypoint] "X" (&entry),
    );
}

fn zero_bss() void {
    const bss_size = @intFromPtr(&bss_end) - @intFromPtr(&bss_start);
    const bss: [*]u8 = @ptrCast(&bss_start);
    const bss_data: []u8 = bss[0..bss_size];
    @memset(bss_data, 0);
}

fn entry() void {
    // This may sometimes be disabled to save ~ 40B
    zero_bss();

    main.main();
}
