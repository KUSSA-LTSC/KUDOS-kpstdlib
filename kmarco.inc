;kmarco.inc

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-scancode-kudos-sal-2.5

%macro adod 0
    push rbp
    mov rbp , rsp
    and rsp , -16
%endmacro

%macro pdod 0
    mov rsp,rbp
    pop rbp
%endmacro    

%macro kook 2-*
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    %if (%0 & 1)
        push rax
    %endif
    %rep %0
        %rotate (%0 - 1)
        push %1
    %endrep
    sub rsp, 32
%endmacro

;等价于pdod
%macro kaak 0
    mov rsp, rbp
    pop rbp
%endmacro