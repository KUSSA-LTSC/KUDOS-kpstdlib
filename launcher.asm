;launcher.asm

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-scancode-kudos-sal-2.5

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

    
