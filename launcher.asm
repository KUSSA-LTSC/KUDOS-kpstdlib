;launcher.asm

;bash:

;nasm -f win64 launcher.asm -o yourname.obj

bits    64
default rel

%include 'third.inc'

extern  luck
extern  ExitProcess

global  duck

section .text

duck:

    adod

    sub rsp, 32

    call luck

    pdod

    adod

    sub rsp, 32

    mov rcx,rax

    call ExitProcess

    

