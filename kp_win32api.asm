; kp_win32api.asm

; Copyright (c) 2026-8086 KUSSA. All rights reserved.

bits    64
default rel

; 声明：
extern ExitProcess




section kw code 

kp_exit_2610:
    jmp ExitProcess

