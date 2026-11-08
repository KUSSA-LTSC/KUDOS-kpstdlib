;launcher.asm

;Copyright (c) 2026-8086 KUSSA. All rights reserved.

;bash:

;nasm -f win64 launcher.asm -o yourname.obj

bits    64
default rel

%include 'kpstddef.inc'

extern  luck
extern  ExitProcess
extern  kpicinit

global  duck

section .text

duck:

    adod

    sub rsp, 32

    xor ecx, ecx

    call kpicinit

    pdod

    adod

    sub rsp, 32

    call luck

    pdod

    adod

    sub rsp, 32

    mov rcx, rax

    call ExitProcess

    
