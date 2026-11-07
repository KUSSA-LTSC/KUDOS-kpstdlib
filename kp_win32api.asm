; kp_win32api.asm

; Copyright (c) 2026-8086 KUSSA. All rights reserved.

bits    64
default rel

; 声明：
extern  ExitProcess
extern  MessageBoxW

%include 'kpstddef.inc'

section .data

    errortitle  db L('Error:'),0,0
    question    db L('Question:'),0,0
    warning     db L('Warning:'),0,0
    information db L('Info:'),0,0

section kw code

kp_exit_2610:
    jmp ExitProcess

; （句柄，内容）
kp_error_2611:

    lea r8, [errortitle]
    mov r9, MB_ICONERROR

    jmp MessageBoxW

kp_quest_2611:

    lea r8, [question]
    mov r9, MB_ICONQUESTION

    jmp MessageBoxW

kp_warn_2611:

    lea r8, [warning]
    mov r9, MB_ICONWARNING

    jmp MessageBoxW

kp_info_2611:

    lea r8, [information]
    mov r9, MB_ICONINFORMATION

    jmp MessageBoxW