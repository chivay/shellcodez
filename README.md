# shellcodez

making headerless PIEs :cake: for fun and no profit.


Supported shellcodez:
* [execve](src/execve.zig) - spawn /bin/sh
* [revshell](src/revshell.zig) - connect to target and spawn /bin/sh


Output file sizes:

```
124 execve-aarch64.bin
 90 execve-x86_64.bin

256 revshell-aarch64.bin
189 revshell-x86_64.bin
```

Another ~40B can be shaved off by disabling .bss zeroing. Although far from
shortest possible shellcodes, they unlock the ability to use Zig standard library.
