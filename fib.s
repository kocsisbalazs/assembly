# fib.s — GAS/AT&T syntax
# build:   gcc -no-pie fib.s -o fib
# or:      gcc fib.s -o fib            (if your toolchain defaults to PIE, keep -no-pie)

        .text
        .globl  main
        .type   main, @function

main:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $32, %rsp            # keep 16B stack alignment for calls

.L_outer:
        movl    $0, -4(%rbp)         # int x = 0
        movl    $1, -8(%rbp)         # int y = 1
.L_do:
        # printf("%d\n", x);
        movl    -4(%rbp), %esi       # 2nd arg: x  (in %esi)
        leaq    fmt(%rip), %rdi      # 1st arg: pointer to "%d\n"
        xorl    %eax, %eax           # clear %eax for varargs call ABI
        call    printf@PLT

        # z = x + y;
        movl    -4(%rbp), %edx
        addl    -8(%rbp), %edx
        movl    %edx, -12(%rbp)      # z

        # x = y;  y = z;
        movl    -8(%rbp), %eax
        movl    %eax, -4(%rbp)       # x = y
        movl    -12(%rbp), %eax
        movl    %eax, -8(%rbp)       # y = z

        # while (x < 255) ...
        cmpl    $255, -4(%rbp)
        jl      .L_do

        jmp     .L_outer             # while(1)

        # (never reached)
        movl    $0, %eax
        leave
        ret

        .section .rodata
fmt:    .string "%d\n"
