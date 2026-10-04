;kpstdlib.asm

;KUSSA_LTSC 2026 All rights reserved.

; ============================================================================
; ENGLISH TRANSLATION NOTICE
; ============================================================================
; This file is an English translation of the original Chinese comments.
; Translated by DeepSeek. Some wording and local labels were edited for
; readability by U.S. English readers.
;
; Function names, exported symbols, string constants, and executable behavior
; were not intentionally changed. Local labels may differ from the original
; Chinese source for readability.
;
; This translation is unofficial and provided for convenience only.
; If there is any conflict between this translation and the original Chinese
; source or the KUDOS SOURCE AVAILABLE LICENSE, the original Chinese source
; and the license control.
;
; The KUDOS SOURCE AVAILABLE LICENSE Version 2.5 still applies. This
; translation grants no additional rights. It must not be used to train,
; fine-tune, distill, or evaluate any AI or machine-learning model.
;
; Translation date: 2026-10-04
; ============================================================================

;Legacy notices retained:

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-scancode-kudos-sal-2.5

;KUSSA's standard library
;Source-visible, for free educational research and study only
;I will add comments later

;What is this: a NASM project (obviously)
;What is it for: to write C code
;Why are you looking at it: none of your business
;Can you learn from it: yes, but I haven't finished the comments
;It may not be as exemplary as other online tutorials
;It leans more toward old-style 8086-era writing
;It makes decisions and tradeoffs for the x86-64 instruction set
;It has far fewer restrictions than 8086
;Is this a beginner version: no, I suggest you learn another language first or read another assembly tutorial
;Is this a beginner version: yes, you can encounter most places where beginners easily make mistakes or get confused
;What can you learn from it: a lot, depends on how you study
;Is it standardized: in terms of calling convention it basically follows Microsoft x64 ABI
;But its style may be rather strange
;Don't understand it: don't read it, or ask AI
;Is it completely handwritten: yes, though I may have let AI help check some parameters, e.g. I once typoed GetFileSizeEx as GetFileSizeEX
;I often let AI help me look at compile and link errors, and assist in looking up the Intel SDM PDF
;Is it easy to use: not necessarily, but except for win32api wrappers everything returns NULL on failure
;NULL is a constant equal to zero
;How do I decide what to update: I write whatever I need
;(In fact, a month has passed and I still haven't finished the functions needed for my logging feature
;Can it replace CRT: it can do quite a lot now, but cannot fully replace it yet
;Why wrap system APIs: because it isn't necessarily compatible with windows.h, to help me remember better, to make maintenance and porting easier, and to make writing programs more convenient
;Besides, why should you learn assembly: it lets you better understand how code works, and solve many bizarre bugs
;But learning assembly is not easy for most people
;I'm the exception; I always have problems writing C code and don't know how to fix bugs
;Is its performance better than CRT: no, about the same, maybe some aggressive functions are a tiny bit faster
;In short, you need some programming foundation, and you need patience to understand 8086 instructions or x86 instructions to understand most of it. Comments are not a nanny; they only point out the most important and error-prone things
;Warning: internal functions and unfinished functions must never be exported, and should not be modified; they only exist for code reuse in business services under specific scenarios


;bash:

;nasm -f win64 .\kpstdlib.asm -o .\kpstdlib.obj 
;gcc -o test.exe test.c kpstdlib.obj -nostdlib -lkernel32 -luser32 -mwindows -e main -ffreestanding -fno-stack-protector -fno-asynchronous-unwind-tables -O2

;New notices:

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-KUDOS-Source-Available-2.5
;
; KUSSA's standard library
; This is NOT an open source license. This is a source-available,
; anti-commercial license.
;
; This file is licensed only under KUDOS SOURCE AVAILABLE LICENSE Version 2.5.
; Full terms are in the project root:
; KUDOS SOURCE AVAILABLE LICENSE.txt
;
; Without prior written paper consent from the project owner, it is forbidden to:
; - use commercially, use by for-profit entities, or evaluate/test by for-profit entities;
; - distribute, publish, upload, or share this software or modified versions with any third party;
; - combine, link, or distribute together with commercial-related bundles;
; - use this software to train, fine-tune, distill, or evaluate any AI or machine learning model.
;
; Permitted uses are limited to those explicitly specified by the license:
; - personal private study;
; - internal administrative use of the original unmodified software by non-profit organizations;
; - public free courses on mainstream online platforms;
; - non-commercial research, peer review, and paper publication under Section 1.4.
;
; Configuration files that do not contain source code, scripts, binaries, or executable logic may be shared publicly.

;Code starts below

; %include 'third.inc'
%include 'kmarco.inc'

;The macro expansion is placed here, don't ask me again!
;It's from the macro file at the beginning, written by me
;Don't worry if you see these two lines, it's fine if you don't understand
;Default stack alignment 16 is handled by itself

; %macro adod 0
;     push rbp
;     mov rbp , rsp
;     and rsp , -16
; %endmacro

; %macro pdod 0
;     mov rsp,rbp
;     pop rbp
; %endmacro  

;kmarco.inc

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-scancode-kapivara-sal-1.0

; %macro adod 0
;     push rbp
;     mov rbp , rsp
;     and rsp , -16
; %endmacro

; %macro pdod 0
;     mov rsp,rbp
;     pop rbp
; %endmacro    

; %macro kook 2-*
;     push rbp
;     mov  rbp, rsp
;     and  rsp, -16
;     %if (%0 & 1)
;         push rax
;     %endif
;     %rep %0
;         %rotate (%0 - 1)
;         push %1
;     %endrep
;     sub rsp, 32
; %endmacro

; equivalent to pdod
; %macro kaak 0
;     mov rsp, rbp
;     pop rbp
; %endmacro

bits    64
default rel

;The project inception date is unknown, but it can be confirmed to be on or before August 26, 2026

;Although this is also for teaching, performance doesn't need to be too good, but I still want to pursue perfection a bit
;For easier debugging and writing, use r64 for all registers unless necessary
;Labels are all written carelessly because my English is bad

; bu, date, dlsbur, dust, wasteimm are global static buffers.
; Functions that use these addresses absolutely, absolutely, absolutely must not be called concurrently in multiple threads!

global  bu
; global  realseconds
; global  realminutes
; global  realhours
; global  realdays
; global  realmonth
; global  realyears
global  dlsbur
; This symbol can be customized
; global  kp_prtnum_frmstk_wthrcx_rep_fastcall_win64
global  kp_replace_single_dollar_symbol_wthcnt_fastcall_win64
global  kp_filetime_to_realtime_frmrax_ret_fastcall_win64
global  kp_win32api_get_file_pointer_ex_fastcall_win64
global  kp_win32api_set_file_pointer_ex_fastcall_win64
global  kp_win32api_get_file_size_ex_fastcall_win64
global  kp_win32api_close_handle_fastcall_win64
global  kp_win32api_createfile_w_fastcall_win64
global  kp_win32api_ezutf8t16le_fastcall_win64
global  kp_win32api_write_file_fastcall_win64
global  kp_win32api_read_file_fastcall_win64
global  kp_text_format_divide_fastcall_win64
global  kp_text_utf8t16le_main_fastcall_win64
global  kp_win32api_msgbox_w_fastcall_win64
global  kp_strcpy_enddls_fastcall_win64
global  kp_prtnum_frmrcx_fastcall_win64
global  kp_avx2_strlen_fastcall_win64
global  kp_sse2_strlen_fastcall_win64
global  kp_simd_strlen_fastcall_win64
global  kp_sse_strlen_fastcall_win64
global  kp_hex2ascii_fastcall_win64
global  kp_ascii2hex_fastcall_win64
global  kp_timefmt_fastcall_win64
global  kp_strcpy_fastcall_win64
global  kp_strend_fastcall_win64
global  kp_strled_fastcall_win64
global  kp_strlen_fastcall_win64
global  kp_ermsb_fastcall_win64

;======WIN32API======

extern  ReadFile
extern  WriteFile
extern  CloseHandle
extern  CreateFileW
extern  MessageBoxW
extern  VirtualFree
extern  VirtualAlloc
extern  GetFileSizeEx
extern  SetFilePointerEx
extern  MultiByteToWideChar
extern  WideCharToMultiByte

section .data
    ;Put data here first
    bu:
    times 22  db 0
    date:
    times 256 db 0 ;date text
    date_end:  
    
    datelen equ (date_end - date)
    
    wasteimm dq 0

    orirsi dq 0

    days        dq 0 ;total days
    seconds     dq 0 ;total seconds
    tempyears   dq 0 ;temporary years
    tempdays    dq 0 ;temporary days
    nboffhys    dq 0 ;number of 400-year periods
    nbofohys    dq 0 ;number of 100-year periods
    nboffoys    dq 0 ;number of 4-year periods
    nbofovys    dq 0 ;extra years
    overdays    dq 0 ;extra days
    realyears   dq 0 ;year
    realmonth   dq 0 ;month
    realdays    dq 0 ;days
    realhours   dq 0 ;hours
    realminutes dq 0 ;minutes
    realseconds dq 0 ;seconds
    
    ;Year constant, year 1600
    aoeg        equ 50491123200
    ;Beijing time offset
    UTC8_OFFSET equ 28800
   ;FileTime subtraction value for disabling Beijing time
    unboeg equ UTC8_OFFSET*10000000
    ;Year constant with Beijing time offset added
    boeg   equ aoeg+UTC8_OFFSET
    
    ;placeholder junk
    dust times 128 db 0

    ;month tables
    mthcom             db  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    mthlep             db  31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    ;time constants
    seconds_per_day    equ 86400
    days_per_4_years   equ 1461
    days_per_100_years equ 36524
    days_per_400_years equ 146097
    ;newly added $ replacement buffer
    dlsbur:
        times 8 db 0
    dlsbur_end:
    
    dlsbur_len equ (dlsbur_end-dlsbur)

    align 16
    ;genius hex2ascii table
    hex2ascii_xlatable db '0123456789ABCDEF'

    align 16
    ;genius ascii2hex table
    ascii2hex_xlatable:
    times 48  db 0                       ; 0x00-0x2F invalid area
    db           0,1,2,3,4,5,6,7,8,9     ; 0x30-0x39  '0'-'9'
    times 7   db 0                       ; 0x3A-0x40  between '9' and 'A'
    db           0xA,0xB,0xC,0xD,0xE,0xF ; 0x41-0x46  'A'-'F'
    times 26  db 0                       ; 0x47-0x60  between 'F' and 'a'
    db           0xA,0xB,0xC,0xD,0xE,0xF ; 0x61-0x66  'a'-'f'
    times 153 db 0                       ; 0x67-0xFF invalid area


; mysterious constants, extracted from windows.inc

; ==================== General ====================
; empty content, null pointer
NULL                  equ 0
; true
TRUE                  equ 1
; false
FALSE                 equ 0
; default value for window position, let the system choose
CW_USEDEFAULT         equ 0x80000000
; infinite wait
INFINITE              equ 0xFFFFFFFF

; ==================== Window class styles ====================
; repaint when window changes vertically
CS_VREDRAW            equ 0x0001
; repaint when window changes horizontally
CS_HREDRAW            equ 0x0002

; ==================== Window styles ====================
; overlapped window (default borderless)
WS_OVERLAPPED         equ 0x00000000
; popup window
WS_POPUP              equ 0x80000000
; child window
WS_CHILD              equ 0x40000000
; window visible
WS_VISIBLE            equ 0x10000000
; has title bar
WS_CAPTION            equ 0x00C00000
; has border
WS_BORDER             equ 0x00800000
; has system menu (top-left icon)
WS_SYSMENU            equ 0x00080000
; resizable border
WS_THICKFRAME         equ 0x00040000
; has minimize button
WS_MINIMIZEBOX        equ 0x00020000
; has maximize button
WS_MAXIMIZEBOX        equ 0x00010000
; standard overlapped window: title bar + system menu + resizable + minimize + maximize
WS_OVERLAPPEDWINDOW   equ WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX

; ==================== ShowWindow ====================
; hide window
SW_HIDE               equ 0
; show normally
SW_SHOWNORMAL         equ 1
; show minimized
SW_SHOWMINIMIZED      equ 2
; show maximized
SW_SHOWMAXIMIZED      equ 3
; show according to most recent state
SW_SHOW               equ 5
; restore from minimized/maximized
SW_RESTORE            equ 9

; ==================== Window messages ====================
; window creation
WM_CREATE             equ 0x0001
; window destruction
WM_DESTROY            equ 0x0002
; window size changed
WM_SIZE               equ 0x0005
; needs repaint
WM_PAINT              equ 0x000F
; close request
WM_CLOSE              equ 0x0010
; quit message loop
WM_QUIT               equ 0x0012
; key down
WM_KEYDOWN            equ 0x0100
; key up
WM_KEYUP              equ 0x0101
; character input
WM_CHAR               equ 0x0102
; menu/control command
WM_COMMAND            equ 0x0111
; timer trigger
WM_TIMER              equ 0x0113
; mouse move
WM_MOUSEMOVE          equ 0x0200
; left button down
WM_LBUTTONDOWN        equ 0x0201
; left button up
WM_LBUTTONUP          equ 0x0202
; right button down
WM_RBUTTONDOWN        equ 0x0204
; right button up
WM_RBUTTONUP          equ 0x0205

; ==================== Message box ====================
; only an "OK" button
MB_OK                 equ 0x00000000
; "OK" + "Cancel"
MB_OKCANCEL           equ 0x00000001
; "Yes" + "No"
MB_YESNO              equ 0x00000004
; error icon
MB_ICONERROR          equ 0x00000010
; question icon
MB_ICONQUESTION       equ 0x00000020
; warning icon
MB_ICONWARNING        equ 0x00000030
; information icon
MB_ICONINFORMATION    equ 0x00000040

; ==================== Message box return values ====================
; user clicked "OK"
IDOK                  equ 1
; user clicked "Cancel"
IDCANCEL              equ 2
; user clicked "Yes"
IDYES                 equ 6
; user clicked "No"
IDNO                  equ 7

; ==================== System resources ====================
; standard arrow cursor
IDC_ARROW             equ 32512
; standard application icon
IDI_APPLICATION       equ 32512

; ==================== Colors ====================
; window background color (white)
COLOR_WINDOW          equ 5
; button face color (gray)
COLOR_BTNFACE         equ 15

; ==================== Memory ====================
; commit: allocate physical storage
MEM_COMMIT            equ 0x1000
; reserve: only reserve address space, no physical storage
MEM_RESERVE           equ 0x2000
; decommit, keep address
MEM_DECOMMIT          equ 0x4000
; fully release (address + storage)
MEM_RELEASE           equ 0x8000
; no access
PAGE_NOACCESS         equ 0x01
; readable and writable
PAGE_READWRITE        equ 0x04

; ==================== File ====================
; read access
GENERIC_READ          equ 0x80000000
; write access
GENERIC_WRITE         equ 0x40000000
; create new file, fail if already exists
CREATE_NEW            equ 1
; always create, overwrite if exists
CREATE_ALWAYS         equ 2
; only open existing file
OPEN_EXISTING         equ 3
; open if exists, create if not
OPEN_ALWAYS           equ 4
; open existing and truncate
TRUNCATE_EXISTING     equ 5
; normal file attributes
FILE_ATTRIBUTE_NORMAL equ 0x80
; invalid handle (API failure return value)
INVALID_HANDLE_VALUE  equ -1
; start from beginning of file
FILE_BEGIN            equ 0
; start from current position
FILE_CURRENT          equ 1
; start from end of file
FILE_END              equ 2
; allow other processes to read
FILE_SHARE_READ       equ 1
; allow other processes to write
FILE_SHARE_WRITE      equ 2
; allow other processes to delete
FILE_SHARE_DELETE     equ 4
; standard input handle
STD_INPUT_HANDLE      equ -10
; standard output handle
STD_OUTPUT_HANDLE     equ -11
; standard error handle
STD_ERROR_HANDLE      equ -12


;code section
section .text

;strlen
;First function?
;Very old-fashioned writing; there are 4 SIMD examples later
kp_strlen_fastcall_win64:
;Only one parameter, rcx holds string start, returns rax, unit is bytes    
    xor  rax, rax
    ;rax=0 used to search for \0
    push rdi
    mov  rdi, rcx
    mov  rcx, -1

    cld;clear direction flag

    repne scasb;repeat, continue scanning/comparing al and [rdi] while not equal
    or  rcx, rcx
    ;This is purely an 8086 leftover; if rcx=0 it means not found or exactly landed, but x64 registers are huge, so no special handling
    jz  .not_found
    not rcx      ;invert
    dec rcx      ;minus one
    ;This gives the length, principle is binary properties
    mov rax, rcx
    pop rdi
    ret

.not_found:
    xor rax, rax
.return:
    pop rdi
    ret

;Deprecated, kept here for archival, with stack diagram
;8086-era function, used to batch output number strings, but I found it not good on x64
;!Warning: unfinished function, do not use!
kp_prtnum_frmstk_wthrcx_rep_fastcall_win64:
;Subroutine, default already aligned, and no register parameters
;Currently no RAX parameter passing feature yet
;If rcx is 0 it means no numbers, exit directly
    or   rcx, rcx ;.....[STACK].....
    jz   .exit    ;NUM2       RBP+56
    push rbp      ;NUM1       RBP+48
    mov  rbp, rsp ;SHADOW 4
    push rsi      ;SHADOW 3
    push rcx      ;SHADOW 2
    push rax      ;SHADOW 1
    push rbx      ;RET        RBP+8
    push rdx      ;RBP    0   RBP+0
    push rdi      ;RBP points to original RBP push
;save all used
    ;PREPROCE

    xor rsi, rsi
    xor rdi, rdi

;overall loop conversion output
.stack_number_loop:

    mov rax, [rbp+rsi+48] ;read number from stack
;new negative check
    ; test rax, 0x8000000000000000
    ; well x64 cannot directly write 64-bit imm except mov
    ; jz   .np
;change to shorter writing
    or  rax, rax
    jns .not_negative
;if not negative skip
    mov byte [bu], 45 ;ASCII for negative sign
    inc rdi
;negative to positive
    neg rax
;label: not negative
.not_negative:
    mov  rbx, 10
    push rcx
    xor  rcx, rcx
;division loop, divide by 10 each time to get ones digit
.divide_loop:
    inc  rcx      ;STACK
    xor  rdx, rdx ;ori_rcx,rcx*rdx
    div  rbx
    push rdx
    or   rax, rax
    jz   .prepare_print

    jmp .divide_loop
;prepare to print
.prepare_print:

    lea rbx, [bu]
;print loop (actually writing to memory)
.write_digit_loop:

    pop rdx
    add rdx,       48
    ;convert to ASCII and write
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .write_digit_loop

;here rdx will all be popped, rsp points to ori_rcx

    ; inc rdi
    mov byte [rbx+rdi], 0
    ;append 0 at end

;here it should call output bu, but not done yet

;initialize for next loop

    xor rdi, rdi
    add rsi, 8
    pop rcx

    dec rcx
    jnz .stack_number_loop

    

;rcx=0,rsp points to ori_rdi

    pop rdi
    pop rdx
    pop rbx
    pop rax
    pop rcx
    pop rsi
    pop rbp

;Logically should leave AX as return value, but actually I'm too lazy

.exit:
    ret


;pending agenda, parameters, e.g. RAX can indicate whether signed is enabled, whether address writeback is enabled, if enabled address defaults to starting RBX, I don't know if 64-bit has a special text command that can write across, I remember previously you could directly set direction, interval, then put text
;now no pending, this function is deprecated, now it's x64 not 8086
;once again declare this function deprecated, treat as advertisement (October 3, 2026)

;internal function, C cannot use directly, 8086 code port
;print rax alone, for logging, should not destroy any registers
;destroys RAX return
kp_prtnum_frmrax:
;rax already assigned by default
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;check negative
    jns  .not_negative ;if not negative skip
    mov  byte [bu], 45  ;ASCII for negative sign
    
    inc rdi
    neg rax ;negative to positive

;not negative goes here
.not_negative:
    push rsi
    push rcx
    push rdx
    push rbx
    mov  rbx, 10
    xor  rcx, rcx
;division loop
.divide_loop:
    inc  rcx
    xor  rdx, rdx
    div  rbx
    push rdx
    or   rax, rax
    jz   .prepare_print
    jmp  .divide_loop
;print preparation
.prepare_print:
    lea rbx, [bu]
    ;first print to bu, load address here
;write digits loop
.write_digit_loop:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .write_digit_loop

    ; inc rdi ; this inc cannot be written
    mov byte [rbx+rdi], 0

    lea rax, [bu]
    ;return address

    pop rbx
    pop rdx
    pop rcx
    pop rsi
    pop rdi

    ret

;calculate date, from parameter 3 to parameter 8 return year, month, day, hour, minute, second (why is this here)
;(this line of comment is clearly written at the start of kp_filetime_to_realtime_frmrax_ret_fastcall_win64)
;(actually forgot to delete when moving, treat as easter egg)(October 3, 2026)

;print rcx alone, now C code can use it
;useless function, haha, this is actually the shortest one
kp_prtnum_frmrcx_fastcall_win64:
    mov rax, rcx
    jmp kp_prtnum_frmrax

;text copy, with checks (actually useless checks)
;rcx holds source pointer, rdx holds source length, r8 holds destination pointer, r9 holds destination length, all units bytes
;returns end 0 pointer, rdx negative means auto-calculate
kp_strcpy_fastcall_win64:
    
    or rcx, rcx
    jz .invalid_args
    or r8,  r8
    jz .invalid_args
    ;supposedly null pointers exist

    or   rdx, rdx
    jns  .have_src_len
    push rcx

    call kp_strlen_fastcall_win64 ;first function
    ;doesn't destroy registers so can use directly, but if using later SIMD versions may destroy registers, need to save
    mov  rdx, rax                 ;return value in rax, calling convention

    pop rcx

.have_src_len:

    cmp rdx, r9
    jae .invalid_args
    ;if source is longer than destination exit
    ;no need to check if rcx is 0 because 0 is fine
    ; push rbp
    ; mov  rbp, rsp
    ; stack frame no longer needed now

    cld

    push rsi
    push rdi

    mov rsi, rcx ;source
    mov rdi, r8  ;destination
    cmp rdx, 15  ;branch for different lengths
    ja  .copy_qwords
    mov rcx, rdx
    rep movsb

    mov byte [rdi], 0

    jmp .done

.copy_qwords:
    mov rcx, rdx
    shr rcx, 3
    rep movsq;movsq is faster than movsb on old CPUs, but actually all x64 have SSE2
    mov rcx, rdx
    and rcx, 7
    rep movsb

    mov byte [rdi], 0 ;append 0 at end
    
.done:
    ; sub rdi, r8
    ; mov rax, rdi
    ; commented this returns length, meaningless, equals srclen
    mov rax, rdi
    ;return pointer
    pop rdi
    pop rsi
    ret

.invalid_args:
    xor rax, rax ;0 means failure, or length is 0
    ; mov rsp, rbp
    ; pop rbp
    ret

db 'Shaoyu is awesome' ;this is the signature, the feature, these 4 Chinese characters will be put into the exe unchanged, later to check this function just search the feature in x64dbg and locate here

;input rcx, can use system-provided time GetSystemTimeAsFileTime
;parameters: rcx holds time provided by system, 1 address used to return plain text compact time
;e.g.: 20260905220631_134330908XXXXXXXXX\0
;the remaining 6 addresses are memory pointers for year month day hour minute second
;void(imm64,immmem64ptr,mem64addr*6)
kp_filetime_to_realtime_frmrax_ret_fastcall_win64:
;There was a design problem at the time, only Beijing time was considered, and UTC offset was not made configurable in one go
;and structs were not considered, so it's very messy
;If you pass a null pointer, the program won't crash, just won't return anything; yes, return values weren't considered at first, because they weren't needed, or I never thought how it could fail
;the largest function, I can only say

; ...STACK_TABLE...
; P8 seconds RBP+72
; P7 minutes RBP+64
; P6 hours   RBP+56
; P5 days    RBP+48
; S4         R9
; S3         R8
; S2         RDX
; S1         RCX
; RET        RBP+8
; RBP        RBP
; RBX
; RSI
; RDI

    push rbp
    mov  rbp, rsp ;used later to get parameters
    push rbx
    push rsi
    push rdi
    push r15

    ; xor rsi, rsi
    ; mov rdi, 7
    ; no need for these two lines when expanded

;check null pointers, although expansion is better for performance, fine let's expand
    or  rdx, rdx
    jz  .null_pointer
    or  r8,  r8
    jz  .null_pointer
    or  r9,  r9
    jz  .null_pointer
    mov rax, [rbp+48]
    or  rax, rax
    jz  .null_pointer
    mov rax, [rbp+56]
    or  rax, rax
    jz  .null_pointer
    mov rax, [rbp+64]
    or  rax, rax
    jz  .null_pointer
    mov rax, [rbp+72]
    or  rax, rax
    jz  .null_pointer



    mov [rbp+16], rcx
    mov [rbp+24], rdx
    mov [rbp+32], r8
    mov [rbp+40], r9
    ;all parameters saved, first 4 in shadow space
    mov rax,      rcx

    xor rbx, rbx ;I forgot what this line is for, actually useless (yes useless, kept as easter egg)(October 3, 2026)
    
    ;modified, but behavior basically unchanged
    ;allow correct return when ft=0
    mov r10, unboeg
    add rax, r10

    ;first convert to seconds
    mov rcx, 10000000
    xor rdx, rdx
    div rcx
    mov rcx, aoeg
    add rax, rcx
    xor rdx, rdx
    ;now rax is total seconds
    mov rcx, seconds_per_day
    div rcx
    
    ;rax=days, rdx=remaining seconds
    ;if you don't understand go check SDM
    mov [days],     rax
    mov [seconds],  rdx
    mov rcx,        days_per_400_years ;first calculate how many complete 400 years
    xor rdx,        rdx
    div rcx
    mov [nboffhys], rax
    mov rax,        rdx
    mov rcx,        days_per_100_years ;continue divide by 100 years
    xor rdx,        rdx
    div rcx
    mov [nbofohys], rax
    mov rax,        rdx
    mov rcx,        days_per_4_years   ;calculate how many 4 years
    xor rdx,        rdx
    div rcx
    mov [nboffoys], rax
    mov [tempdays], rdx
    ;remaining days
    
    imul rax,[nboffhys],400
    mov [tempyears], rax
    imul rax,[nbofohys],100
    add [tempyears], rax
    imul rax,[nboffoys],4
    add [tempyears], rax
    ;now everything except the part less than 4 years is calculated

;first compare leap year necessity
    mov rax, [tempdays]
    cmp rax, 1460
    je  .special_1460_days
    ;this label is later
    mov rcx, 365
    xor rdx, rdx
    div rcx

;1460 days directly portal here    
.store_year_remainder:    
    
    ;save remaining years and days
    mov [nbofovys],  rax
    mov [overdays],  rdx
    mov r9,          rax
    inc rax
    add rax,         [tempyears]
    mov [realyears], rax
    ; mov rax,         r9

    ; comments written for AI because AI annoyed me
    ; tempyears = absolute year-1 - ((absolute year-1) mod 4)
    ; = start of current 4-year cycle - 1 (not absolute year!)
    ; example: 2000 -> 1996, 2001 -> 2000, 1900 -> 1896
    ; purpose: compare tempyears and tempyears+4 with /100, /400
    ;   equal -> no crossing; not equal -> crossing, continue checking 400
    ; absolute year = tempyears + 1 + nbofovys (number of complete years already passed in current cycle)

    ;now calculate whether there is a century common year

    lea rbx, [mthlep]
    lea rcx, [mthcom]
    ;Hovering over labels in VS Code shows comments above them (plugin needed)

    ; cmp    rax, 3
    cmp    r9,  3
    cmovne rbx, rcx
    jne    .month_subtract

    ;remaining need to consider leap year
    mov   rax, [tempyears]
    mov   r9,  rax
    ;first copy rax, r9 is original tempyears
    mov   rcx, 100
    xor   rdx, rdx
    div   rcx
    mov   r8,  rax
    ;save first result
    mov   rax, r9
    add   rax, 4
    xor   rdx, rdx
    div   rcx
    cmp   rax, r8
    ;compare with first result
    ;here still leap year table
    je    .month_subtract
    ;not equal means there is a century year
    ;now check whether there is a 400-year leap year
    mov   rcx, 400
    xor   rdx, rdx
    mov   rax, r9
    div   rcx
    mov   r8,  rax
    ;save first result
    xor   rdx, rdx
    mov   rax, r9
    add   rax, 4
    div   rcx
    cmp   rax, r8
    ;compare, equal means not a 400-year, but century common year
    lea   rbx, [mthlep]
    lea   rcx, [mthcom]
    cmove rbx, rcx

;code reuse here
;calculate month subtraction
;expects rax equals extra days, initialized below

.month_subtract:
    mov rax, [overdays]
    xor rcx, rcx
    xor rsi, rsi

.month_loop:
    inc   rcx
    ;does anyone still remember rsi was cleared at the beginning (originally)
    ;ok now changed to clear ahead
    movzx rdx, byte [rbx+rsi]
    inc   rsi
    cmp   rax, rdx
    ; jge   .lepsub
    jb    .month_found
    sub   rax, rdx
    jmp   .month_loop

.month_found:    
    ;rax=remaining days, rcx equals month
    inc rax
    ;this is the day not yet finished, so add
    mov [realdays],  rax
    mov [realmonth], rcx

;year month day calculated, next hour minute second  
    mov rax, [seconds]
    xor rdx, rdx
    mov rcx, 3600
    div rcx

    mov [realhours], rax
    
    ;now remaining seconds in rdx go to rax
    xchg rax, rdx
    xor  rdx, rdx
    mov  rcx, 60
    div  rcx

    mov [realminutes], rax
    mov [realseconds], rdx

;now output return value

    lea rbx, [date] ;currently default output here

    ;rbx ready for output
    
    mov rax, rbx
    mov r9,  datelen
    xor rsi, rsi
    mov rdi, 6
    lea r15, [realyears]
.format_time_loop:
    lea  rcx, [bu]
    mov  rdx, -1
    mov  r8,  rax
    sub  rax, rbx
    mov  r9,  datelen
    sub  r9,  rax
    ;calculate remaining length and put into r9
    mov  rax, [r15+rsi]
    call kp_prtnum_frmrax_intime
    call kp_strcpy_enddls_fastcall_win64
    ;this function returns rax as end address
    add  rsi, 8
    dec  rdi
    jnz  .format_time_loop
    ;8086 era still used to loops to compress code, but now theoretically expansion is better for performance

;now time concatenation complete

    lea rcx, [bu]
    mov rdx, -1
    mov r8,  rax
    sub rax, rbx
    mov r9,  datelen
    sub r9,  rax
    ;calculate remaining length and put into r9

    mov  al,   ('{')
    mov  ah,   0
    mov  [bu], ax
    call kp_strcpy_fastcall_win64
    lea  rcx,  [bu]
    mov  rdx,  -1
    mov  r8,   rax
    sub  rax,  rbx
    mov  r9,   datelen
    sub  r9,   rax
    ;calculate remaining length and put into r9
    mov  rax,  [rbp+16]
    ;now rax is filetime
    call kp_prtnum_frmrax
    call kp_strcpy_enddls_fastcall_win64
    
;newly added rewrite $
    mov rcx, 0x007D3B3A3A5F2D2D
    ;equals ('--_::;}',0)
    ;little endian needs reversed writing
    ;small update, now has } ending

    mov [dlsbur], rcx ;this is parameter for another function

;r9 length must be given yourself
    lea  rcx, [date]
    call kp_strlen_fastcall_win64
    mov  r9, rax

    lea rcx, [dlsbur]
    mov rdx, -1
    lea r8,  [date]

    call kp_replace_single_dollar_symbol_wthcnt_fastcall_win64
    ;I think it won't fail, nothing to check

    mov rcx,   [rbp+24]
    lea rdx,   [date]
    mov [rcx], rdx
    ;text date written back

    xor rsi, rsi
    mov rdi, 6

.write_back_loop:

    mov rcx,   [rbp+rsi+32]
    mov rdx,   [r15+rsi]
    mov [rcx], rdx
    add rsi,   8
    dec rdi
    jnz .write_back_loop

;return process

;null pointer return
.null_pointer:

    pop r15
    pop rdi
    pop rsi
    pop rbx
    pop rbp

    ret

;1460 days special handling label
.special_1460_days:
    mov rax, 3
    mov rdx, 365
    jmp .store_year_remainder

db 'This_is_a_sentence.' ;still a marker

;Damn, finally finished this thing, the date function took me three weeks    
;calculate date, from parameter 3 to parameter 8 return year, month, day, hour, minute, second
;this thing tortured me for three weeks (ended September 13, 2026)

;text copy, with checks (actually useless checks)
;only difference from strcpy is
;ending is '$\0'
;rcx holds source pointer, rdx holds source length, r8 holds destination pointer, r9 holds destination length, all units bytes
;returns end 0 pointer, rdx negative means auto-calculate
kp_strcpy_enddls_fastcall_win64:
    
    or   rcx, rcx
    jz   .invalid_args
    or   r8,  r8
    jz   .invalid_args
    ;supposedly null pointers exist
    or   rdx, rdx
    jns  .have_length
    push rcx
    call kp_strlen_fastcall_win64 ;don't casually replace with another strlen, otherwise you have to save registers
    mov  rdx, rax
    pop  rcx
.have_length:   
    lea r10, [rdx+1] ;check required size
    cmp r10, r9
    jae .invalid_args
    ;if source is longer than destination exit
    ;no need to check if rcx is 0 because 0 is fine
    ; push rbp
    ; mov  rbp, rsp
    ; no longer needed now

    cld

    push rsi
    push rdi
    ; mov  r9,  r8
    mov  rsi, rcx
    mov  rdi, r8
    cmp  rdx, 15
    ja   .copy_qwords
    mov  rcx, rdx
    rep movsb

    ; mov byte [rdi], 0 ; this is left from strcpy, changed to below
    ; mov ah,    0
    ; mov al,    ('$')
    mov ax,    0x0024
    ;write $\0 at once
    mov [rdi], ax
    inc rdi
    ;now rdi points to \0

    jmp .done

.copy_qwords:
    mov rcx, rdx
    shr rcx, 3
    rep movsq
    mov rcx, rdx
    and rcx, 7
    rep movsb

    ; mov byte [rdi], 0
    mov ah,    0
    mov al,    ('$')
    mov [rdi], ax
    inc rdi

    ; jmp .done
    
.done:
    ; sub rdi, r8
    ; mov rax, rdi
    mov rax, rdi
    ;return pointer
    pop rdi
    pop rsi
    ret
    ; jmp .return
.invalid_args:
    xor rax, rax
.return:
    ; mov rsp, rbp
    ; pop rbp
    ret

;replace all $ with custom ASCII symbols, currently limited to 8
;(source, source length, destination, destination length)
;source ending with 0, source length negative means auto-calculate
;source length is also the number of symbol replacements (equivalent)
;doesn't return pointer, returns bool, non-fixed value
kp_replace_single_dollar_symbol_wthcnt_fastcall_win64:
    push rbp
    mov  rbp, rsp
    push rsi
    push rdi
    
    or r9, r9
    jz .error
    ;destination length 0 then nothing to say

    or   rdx, rdx
    jns  .have_length
    mov  r10, rcx
    ;backup rcx
    call kp_strlen_fastcall_win64
    cmp  rax, dlsbur_len
    ja   .error
    mov  rdx, rax
    mov  rcx, r10
    ;restore rcx

.have_length:
    cmp rdx, 8
    ja  .error
    ;modified, now max 8 replacements, because my buffer is only this big
    ;September 24, 2026
    mov rsi, rcx
    ;now rsi points to source
    mov rdi, r8
    mov rcx, r9
    ;now rcx is length

.replace_loop:    
    mov al, ('$')
    mov ah, [rsi]

    cld
    repne scasb;scan
    jne .exit ;this only executes when rcx=0 or found; if flag is not equal, not found, because length is set, won't overrun

    mov [rdi-1], ah
    inc rsi
    dec rdx

    or  rdx, rdx
    jz  .exit
    or  rcx, rcx
    jnz .replace_loop

.exit:

;in short rax success doesn't return null

    pop rdi
    pop rsi
    pop rbp
    
    ret
    
.error:
    xor rax, rax
    jmp .exit


;internal function, only for date feature    
;destroys RAX as return value
kp_prtnum_frmrax_intime:
;rax already assigned by default
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;check negative
    jns  .not_negative  ;if not negative skip
    mov  byte [bu], 45  ;ASCII for negative sign
    inc  rdi
    neg  rax
.not_negative:
    ; push rsi
    push rcx
    push rdx
    push rbx

    mov rbx, 10
    xor rcx, rcx
.divide_loop:
    inc  rcx
    xor  rdx, rdx
    div  rbx
    push rdx
    or   rax, rax
    ; jz   .prepare_print
    ; jmp  .divide_loop
    jnz  .divide_loop
.prepare_print:
    lea rbx, [bu]
    ;first print to bu
.write_digit_loop:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .write_digit_loop

    ; inc rdi
    mov byte [rbx+rdi], 0

;data processing, used by date function for alignment
;if rsi is not 0 keep 2 digits
    ; mov  rsi,   [rbp+32]
    test rsi,   rsi
    jz   .skip_padding
    mov  ax,    [rbx]
    test ah,    ah
    jnz  .skip_padding
    xchg ah,    al
    ;swap one digit and '0'
    mov  al,    ('0')
    mov  [rbx], ax
    xor  rax,   rax

    mov [rbx+2], al
    ;append 0 at end

.skip_padding:

    lea rax, [bu]
    ;return address

    pop rbx
    pop rdx
    pop rcx
    ; pop rsi
    pop rdi
    ret

;append string at end, 4 parameters
;(source, source length, destination start, destination buffer length)
;source length negative means auto-calculate
;returns end \0 pointer, failure returns 0
kp_strend_fastcall_win64:

    ;check null pointers and 0 length
    test rcx, rcx
    jz   .null_or_empty
    test r8,  r8
    jz   .null_or_empty
    test r9,  r9
    jz   .null_or_empty
    test rdx, rdx
    jz   .null_or_empty

    ;main part begins

    mov r10, rcx ; backup source pointer
    mov rcx, r8  ; rcx = dst, for internal strlen
    
    call kp_strlenled_inside
    ; returns: rax = destination end \0 pointer, rcx = current destination length

    sub rcx, r9 ; current length - total capacity
    neg rcx     ; invert, get remaining space
    js  .null_or_empty ; if negative, destination space full, leave directly

    mov r9,  rcx
    mov rcx, r10

;mysterious label
.no_auto_length:   

    ;now can start copying string
    
    mov r8, rax ; r8 = destination end \0 address
    
    call kp_strcpy_fastcall_win64
    
    ret

;null pointer and insufficient length exit
.null_or_empty:
    xor rax, rax
    ret

;string end
;only one parameter, rcx holds string start, returns rax pointing to \0, failure returns 0
kp_strled_fastcall_win64:

    xor  rax, rax
    push rdi
    mov  rdi, rcx
    mov  rcx, -1
    cld

    repne scasb 
    or  rcx, rcx
    jz  .not_found
    ; not rcx
    ; dec rcx
    ; mov rax, rcx
    lea rax, [rdi-1]
    pop rdi
    ret
    ; jmp .return

.not_found:
    xor rax, rax
.return:
    pop rdi
    ret

;internal function, only for internal use
;destroys rax, rcx, returns length and end respectively
kp_strlenled_inside:
;only one parameter, rcx holds string start, returns rax pointing to \0, rcx returns length, failure both return 0
    xor  rax, rax
    push rdi
    mov  rdi, rcx
    mov  rcx, -1
    cld

    repne scasb 
    or  rcx, rcx
    jz  .not_found
    not rcx
    dec rcx
    lea rax, [rdi-1]
    pop rdi
    ret
    ; jmp .return

.not_found:
    xor rax, rax
    xor rcx, rcx
.return:
    pop rdi
    ret

;use system API to quickly convert UTF8 to UTF16le
;int(src,srclen,dst,dstlen) units all bytes
;no checks, directly use API return value *2
;if you pass strlen without \0 you need to append 0 yourself at the end
;I suggest just passing -1 for length
kp_win32api_ezutf8t16le_fastcall_win64:
    
    adod

    shr  r9,  1
    push r9
    push r8
    sub  rsp, 32
    ;shadow space
    mov  r9,  rdx
    mov  r8,  rcx
    mov  rcx, 65001
    xor  rdx, rdx

    call MultiByteToWideChar

    shl rax, 1

    pdod

    ret

;short input version of time function, still no return value considered at first
;void(filetime, fast string address, struct address start, disable Beijing time)
;about disabling Beijing time (if 0 then ignore, if non-zero then give UTC time)
kp_timefmt_fastcall_win64:    

    adod

    test rdx, rdx
    jz   .no_dst_ptr    ;give an unused 8 bytes, prevent crash
.have_dst_ptr:

    push rbx
    push rdi
    push r9
    push rdx
    mov  rbx, rcx

    test r9,  r9     ;check time flag
    jz   .enable_beijing
    mov  r10, unboeg ;roll back UTC time
    sub  rcx, r10
;enable Beijing time jump directly
.enable_beijing:

    or  r8, r8
    jnz .normal
    lea r8, [dust]

.normal:

    adod

    ;parameter passing group
    lea  r10, [r8+40]
    push r10
    lea  r10, [r8+32]
    push r10
    lea  r10, [r8+24]
    push r10
    lea  r10, [r8+16]
    push r10
    lea  r9,  [r8+8]
    
    ;shadow space
    sub rsp, 32
    
    call kp_filetime_to_realtime_frmrax_ret_fastcall_win64

    pdod

;write back filetime

    ;there was a push rdx before
    pop  rdi
    pop  r9
    test r9,  r9
    jz   .no_rewrite
    test rdi, rdi
    jz   .no_rewrite
    ;next rewrite back the real filetime
    mov  rdi, [rdi]
    mov  al,  ('{')
    mov  rcx, -1
    cld
    repne scasb
    jne  .no_rewrite
    mov  rax, rbx
    ;now rax is filetime
    call kp_prtnum_frmrax
    mov  rcx, rax
    mov  rdx, -1
    mov  r8,  rdi
    mov  r9,  datelen
    call kp_strcpy_enddls_fastcall_win64
    mov  dl,  ('}')
    mov  rcx, rdi
    call kp_replace_single_dollar_symbol
    pop  rdi
    pop  rbx
    pdod
    ret

    ;I know this function is a pile of crap
    ;but there is no way, because backward compatibility must be ensured
    ;now I can only write a cramped portal useless function
    ;I'll write the complete version of this thing some other time

.no_rewrite:

    pop rdi
    pop rbx
    pdod

    ret

.no_dst_ptr:
    lea rdx, [wasteimm]
    jmp .have_dst_ptr

;replace one $ with custom ASCII symbol
;(destination, character in dl), destroys rax, rcx
;no checks at all, internal function
kp_replace_single_dollar_symbol:
    
    push rdi
    mov  rdi,     rcx
    mov  al,      ('$')
    mov  rcx,     -1
    cld
    repne scasb
    mov  [rdi-1], dl
    pop  rdi
    ret

;test function, SIMD version of strlen
;rcx holds string start
;really driving fast and still need a seatbelt, annoying
kp_simd_strlen_fastcall_win64:
    ;because using movdqu unaligned version, need to keep checking page boundary

    mov r9,  16
    xor rdx, rdx

    pxor xmm1, xmm1

.scan_loop:

    ;check page boundary
    mov r10, rcx
    and r10, 0xFFF ;take high 12 bits
    cmp r10, 4080  ;compare with last page start
    ja  .slow_path
    ;if near page boundary switch to slow branch

    movdqu   xmm0, [rcx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0
    
    or  r8, r8
    jnz .found

    add rdx, r9
    add rcx, r9

    jmp .scan_loop

.found:

    tzcnt r8d, r8d

    lea rax, [rdx+r8]

    ret

.slow_path:

    push rdi
    mov  rdi, rcx
    xor  rax, rax
    neg  r10
    lea  rcx, [r10+4096]
    mov  r11, rcx
    cld
    repne scasb
    jne  .page_boundary_cross
    neg  rcx
    lea  rcx, [r11+rcx-1]
    lea  rax, [rdx+rcx]
    pop  rdi
    ret
    
.page_boundary_cross:
    add rdx, r11
    mov rcx, rdi
    pop rdi
    jmp .scan_loop
    
;SSE version of strlen, rcx=src
;ONE OF the weirdest functions I've written so far
;leave comments for 20,000 years later
;so clever that changing one letter can completely crash it
kp_sse_strlen_fastcall_win64:
;I really don't want to write comments for this, one register used as 4 variables
;no mask merging, only 16 bytes at a time

    push rdi

    cld

    xor rax, rax
    mov r8,  rcx
    mov rdx, rcx
    and rdx, -16
    mov r9,  16
    add rdx, r9

    neg rcx
    add rcx, rdx

    mov rdx, rcx
    mov rdi, r8

    repne scasb

    je .found

    mov rcx, rdi
    
    pop rdi

    pxor xmm1, xmm1

.scan_loop:

    movdqa   xmm0, [rcx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    test r8, r8

    jnz .sse_found

    add rcx, r9
    add rdx, r9

    jmp .scan_loop

.sse_found:

    bsf r8d, r8d

    lea rax, [rdx+r8]
    lea rcx, [rcx+r8]

    ret

.found:

    not rcx

    lea rax, [rdx+rcx]
    lea rcx, [rdi-1]

    pop rdi

    ret

;test function, copy memory with MOVSB
;suggest using on CPUs supporting ERMSB
;(src,srclen,dst,dstlen)
kp_ermsb_fastcall_win64:
;what meaning does this kind of function have, just so C can use it

    cld

    cmp rdx, r9
    ja  .error

    push rsi
    push rdi
    mov  rsi, rcx
    mov  rdi, r8

    mov rcx, rdx
    rep movsb

    mov rax, rdi

    pop rdi
    pop rsi

    ret

.error:    

    xor rax, rax
    ret



;read binary as hexadecimal, and convert to hexadecimal ASCII text
;(source, source length, destination, destination length) units bytes
;return: address of end \0, for chained calls overwrite from that address
;still no null pointer checks, leave comments for tomorrow
kp_hex2ascii_fastcall_win64:

    cld

    lea r10, [rdx*2]
    cmp r10, r9
    jae .invalid_args
    
    test rdx, rdx
    jz   .invalid_args
    
    push rbx
    push rdi
    push rsi

    xchg rcx, rdx

    lea rbx, [hex2ascii_xlatable] ;lookup table
    
    mov rdi, r8
    mov rsi, rdx
    ;rsi points to source
    
;loop
.translate_loop:

    lodsb

    mov r9b, al
    shr al,  4
    
    xlat;lookup table
    stosb;store

    mov al, r9b
    and al, 0xF
    ;0b1111

    xlat
    stosb

    dec rcx
    jnz .translate_loop

    xor al, al

    stosb
    ;append 0 at end

    lea rax, [rdi-1]
    pop rsi
    pop rdi
    pop rbx

    ret

.invalid_args:
    xor rax, rax
    ret

;two ASCII as one byte
;if you write A\0 at the end, table lookup probably won't execute
;(source, source length, destination, destination length) units bytes
;return: address after last data byte, for chained calls continue writing from that address
;but you need to calculate remaining length yourself or use dynamic memory
kp_ascii2hex_fastcall_win64:

    cld

    test rdx, rdx
    jz   .invalid_args

    shl r9,  1
    cmp rdx, r9
    ja  .invalid_args

;main body

    push rbx
    push rdi
    push rsi

    mov rsi, rcx
    mov rdi, r8
    mov rcx, rdx
    shr rcx, 1

    lea rbx, [ascii2hex_xlatable] ;lookup table

.translate_loop:

    lodsb;fetch

    xlat;lookup table

    mov r9b, al ;temporarily store
    
    lodsb;fetch

    xlat;lookup table

    shl r9b, 4   ;write back high bits
    or  al,  r9b ;merge

    stosb;store

    dec rcx
    jnz .translate_loop

    lea rax, [rdi]

    pop rsi
    pop rdi
    pop rbx

    ret

.invalid_args:

    xor rax, rax

    ret

;currently the best strlen
;heavily modified SSE2 version
;rcx=src
kp_sse2_strlen_fastcall_win64:

    mov rdx, rcx
    mov r9,  rcx
    and rdx, -16 ;force align
    sub rcx, rdx

    pxor     xmm1, xmm1
    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    shr r8d, cl ;remove useless mask
    jnz .found  ;if not zero means found

    test rdx, 16
    ;check 32-byte alignment
    jz   .sse_go  ;if fourth bit set, then adding sixteen is directly aligned to 32 bytes
    add rdx, 16 ;otherwise still need to handle 16 bytes separately, then align

    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    test r8d, r8d
    jnz  .go_find

;preparation
.sse_go:
    add rdx, 16
.sse_loop:

    movdqa   xmm0, [rdx]
    movdqa   xmm2, [rdx+16]
    pcmpeqb  xmm0, xmm1
    pcmpeqb  xmm2, xmm1
    pmovmskb r8d,  xmm0
    pmovmskb eax,  xmm2
    
    shl  eax, 16   ;mask high bits
    or   r8d, eax  ;merge mask
    test r8d, r8d
    jnz  .sse_found

    add rdx, 32
    jmp .sse_loop

.go_find:

    tzcnt eax, r8d
    sub   rdx, r9
    add   rax, rdx
    
    ret

.found:

    tzcnt eax, r8d

    ret

.sse_found:

    tzcnt eax, r8d

    sub rdx, r9
    add rax, rdx
    ret

;heavily modified AVX2 version, similar to SSE2 version, too lazy to comment
;rcx=src
kp_avx2_strlen_fastcall_win64:

    mov rdx, rcx
    mov r9,  rcx
    and rdx, -32
    sub rcx, rdx

    vpxor     ymm1,ymm1,ymm1
    vmovdqa   ymm0, [rdx]
    vpcmpeqb  ymm2,ymm0,ymm1
    vpmovmskb r8d,  ymm2

    shr r8d, cl
    jnz .found

    test rdx, 32
    ;check 64-byte alignment
    jz   .avx_go

    add rdx, 32

    vmovdqa   ymm0, [rdx]
    vpcmpeqb  ymm2,ymm0, ymm1
    vpmovmskb r8d,  ymm2

    test r8d, r8d
    jnz  .go_find

.avx_go:
    add rdx, 32
.avx_loop:

    vmovdqa   ymm0, [rdx]
    vmovdqa   ymm2, [rdx+32]
    vpcmpeqb  ymm0,ymm0, ymm1
    vpcmpeqb  ymm2,ymm2, ymm1
    vpmovmskb r8d,  ymm0
    vpmovmskb eax,  ymm2
    
    shl  rax, 32
    or   r8,  rax
    test r8,  r8
    jnz  .avx_found

    add rdx, 64
    jmp .avx_loop

.go_find:

    tzcnt rax, r8
    sub   rdx, r9
    add   rax, rdx
    vzeroupper
    ret

.found:

    tzcnt rax, r8
    vzeroupper
    ret

.avx_found:

    tzcnt rax, r8
    vzeroupper
    sub   rdx, r9
    add   rax, rdx
    ret

;wrap CreateFileW, return value follows API, but failure is 0
;int(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition)
;lpSecurityAttributes passes NULL, hTemplateFile passes NULL
;dwFlagsAndAttributes passes FILE_ATTRIBUTE_NORMAL
;no checks at all
kp_win32api_createfile_w_fastcall_win64:
    
    adod

    push r15 ;junk alignment

    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push r9

    xor r9,  r9
    xor r15, r15

    sub  rsp, 32
    call CreateFileW

    cmp   rax, -1
    cmove rax, r15

    mov r15, [rsp+56] ;restore

    pdod

    ret;yes really this short

;wrap GetFileSizeEx
;int(hFile,lpFileSize)
;same as API, failure returns 0, success non-zero
kp_win32api_get_file_size_ex_fastcall_win64:

    adod

    sub  rsp, 32
    call GetFileSizeEx

    pdod

    ret;probably the shortest one

;wrap ReadFile
;int(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead)
;behavior basically same as API, 5th parameter always NULL
;nNumberOfBytesToRead, how many bytes to read. DWORD, 32-bit.
;lpNumberOfBytesRead, pointer to a DWORD, API writes "how many actually read" into it. This value may be less than requested.
kp_win32api_read_file_fastcall_win64:

    adod

    push NULL ;alignment
    push NULL

    sub  rsp, 32
    call ReadFile

    pdod

    ret

; wrap WriteFile
;(handle, source, source length, actual written pointer)
;(hFile, lpBuffer, nNumberOfBytesToWrite, lpNumberOfBytesWritten)
kp_win32api_write_file_fastcall_win64:

    adod

    push rax     ;placeholder
    push NULL
    sub  rsp, 32

    call WriteFile

    pdod

    ret

;wrap SetFilePointerEx
;(handle, offset, new position pointer, starting position)
;(hFile, liDistanceToMove, lpNewFilePointer, dwMoveMethod)
kp_win32api_set_file_pointer_ex_fastcall_win64:

    adod

    sub rsp, 32

    call SetFilePointerEx

    pdod

    ret;shortest!

;get file pointer
;(handle, 64-bit variable pointer)
kp_win32api_get_file_pointer_ex_fastcall_win64:

    adod

    sub rsp, 32

    mov r8,  rdx
    xor rdx, rdx
    mov r9d, FILE_CURRENT

    call SetFilePointerEx

    pdod

    ret

;wrap CloseHandle
;(handle)
kp_win32api_close_handle_fastcall_win64:

    adod

    sub rsp, 32

    call CloseHandle

    pdod

    ret

;wrap MessageBoxW
kp_win32api_msgbox_w_fastcall_win64:

    adod

    sub rsp, 32

    call MessageBoxW

    pdod

    ret

;wrap WideCharToMultiByte
;(source, source length, destination, destination byte length)
kp_win32api_ezutf16le2utf8_fastcall_win64:

    adod

    push NULL
    push NULL
    push r9
    push r8

    sub rsp, 32

    mov r9,  rdx
    mov r8,  rcx
    xor edx, edx
    mov ecx, 65001

    call WideCharToMultiByte

    pdod

    ret




;wrap VirtualAlloc
;(address, size, allocation type, protection attribute)
;(lpAddress, dwSize, flAllocationType, flProtect)
kp_win32api_virtual_alloc_fastcall_win64:

    adod

    sub rsp, 32

    call VirtualAlloc

    pdod

    ret



;wrap VirtualFree
;(address, size, free type)
;(lpAddress, dwSize, dwFreeType)
kp_win32api_virtual_free_fastcall_win64:

    adod

    sub rsp, 32

    call VirtualFree

    pdod

    ret

;originally first step of char ascii_hex formatting
;text grouping, byte-level processing, only suitable for ascii and utf8
;you can pass a negative parameter 4 to ignore (disable) length check
; you can pass a negative parameter 6 to ignore (disable) newline feature
;default uses space division, newline uses 0x0A0D (little endian) i.e. carriage return line feed
;(source, source length, destination, destination length, bytes per group, groups per line)
;srclen=0 exits directly, failure returns NULL, success returns pointer to destination end \0
kp_text_format_divide_fastcall_win64:
;I declare this kind of comment will be released for at least two months

;check srclen and dstlen

    ;put on a show of taking off pants to fart
    push rbp
    mov  rbp, rsp

;===STACK===
; [rbp+56]  arg 6   groups per line
; [rbp+48]  arg 5   group size
; [rbp+40]  shadow 4
; [rbp+32]  shadow 3
; [rbp+24]  shadow 2
; [rbp+16]  shadow 1
; [rbp+8]   return address
; [rbp+0]   .ori.RBP

    mov r10, [rbp+48]
    mov r11, [rbp+56]

    pop rbp

    push r12
    push r13
    push r14
    push r15

    test r10, r10
    jz   .error
    ;0 bytes per group I can't help either
    test r11, r11
    jz   .error

    ;check rdx
    test rdx, rdx
    jz   .error
    jns  .have_str_len
    push rcx
    push r8
    push r9
    adod
    sub  rsp, 32
    call kp_sse2_strlen_fastcall_win64
    pdod
    pop  r9
    pop  r8
    pop  rcx
    mov  rdx, rax
.have_str_len:
    test rdx, rdx
    jz   .error

    mov r12, r10
    mov r13, r11
    mov r14, rdx

    xor eax, eax

    test r9,  r9
    jns  .r9_ok
    bts  rax, 0  ;disable length check

.r9_ok:
    test r11, r11
    jns  .check_flags
    bts  rax, 1   ;disable newline

.check_flags:

    push rax
    push rdx
    push rbx

    mov rax, rdx
    xor edx, edx
    mov rbx, r10

    div rbx

    mov  r10, rax
    test edx, edx
    jz   .align_groups
    inc  r10      ;fallback for non-aligned
.align_groups:
;next calculate how many lines
    mov rax, r10
    xor edx, edx
    mov rbx, r11

    div rbx

    mov  r11, rax
    test rdx, rdx
    jz   .lines_ok
    inc  r11
.lines_ok:
    pop rbx
    pop rdx
    pop rax

;length calculation
    
;required length=source length+groups-lines+(lines-1)*2+1
;(srclen+groups+lines-1)
    lea rdx, [rdx+r10]
    lea r15, [r11-1]
    add rdx, r15

    bt rax, 0
    jc .main

    cmp rdx, r9
    jbe .main

    jmp .error

;main body, two versions
;respectively with newline and without
;all beings equal main, all beings equal rdx, everything else same except rax's bit 1
.main:

    bt   rax, 1
    jc   .disable_newline
    ;rcx=src,rdx=len,r8=dst,r10=groups,r11=lines,r12=objspergroup,r13=groupsperline
    push rdi
    push rsi
    mov  rsi, rcx
    mov  rdi, r8
    ;big loop=lines-1
    ;portal
    cmp  r11, 1
    je   .last
    lea  rcx, [r11-1]
;big loop, total executes lines-1
.big_loop:
    push rcx
    mov  rax, 0x20
    mov  rcx, r13
    cmp  rcx, 1
    jz   .one_group_per_line
    dec  rcx
    ;middle loop, each time executes groups per line -1
    .mid_loop:
    push rcx
    ;small loop, copies one group and formats each time
    mov  rcx, r12
    rep movsb
    stosb
    pop  rcx
    dec  rcx
    jnz  .mid_loop
    ;when groups per line is 1
    .one_group_per_line:
    mov  rcx, r12
    rep movsb
    mov  rax, 0x0A0D
    stosw
    pop  rcx
    dec  rcx
    jnz  .big_loop
.last:
    lea  rax, [r11-1]
    mov  r15, r13
    imul rax, r15
    neg  rax
    add  rax, r10
    ;now rax is remaining groups
    mov  rcx, rax
    mov  rax, 0x20
    cmp  rcx, 1
    je   .real_last
    dec  rcx
    .last_loop:
    push rcx
    mov  rcx, r12
    rep movsb
    stosb
    pop  rcx
    dec  rcx
    jnz  .last_loop

    .real_last:
    mov  rax,        r10
    dec  rax
    imul rax,        r12
    mov  r15,        r14
    sub  r15,        rax
    mov  rcx,        r15
    rep movsb
    mov  byte [rdi], 0
    
    mov rax, rdi
    pop rsi
    pop rdi
    jmp .normal_exit

.disable_newline:

    push rdi
    push rsi
    mov  rsi, rcx
    mov  rdi, r8
    mov  rcx, r10
    mov  rax, 0x20
    cmp  rcx, 1
    je   .disable_last
    dec  rcx
    .disable_big_loop:
    push rcx
    mov  rcx, r12
    rep movsb
    stosb
    pop  rcx
    dec  rcx
    jnz  .disable_big_loop

.disable_last:
    mov  rax,        r10
    dec  rax
    imul rax,        r12
    mov  r15,        r14
    sub  r15,        rax
    mov  rcx,        r15
    rep movsb
    mov  byte [rdi], 0
    mov  rax,        rdi
    pop  rsi
    pop  rdi

.normal_exit:

    pop r15
    pop r14
    pop r13
    pop r12
    
    ret

.error:

    pop r15
    pop r14
    pop r13
    pop r12

    xor rax, rax

    ret;wasted another whole day writing a pile of crap

;utf8 decode single character function
;rsi is assumed already set
;rax=0 failure, success returns character code point
;destroys rax, rdx
;automatically decreases rcx
kp_text_utf8_single_symbol_decode_inside:

    xor eax,      eax
    xor edx,      edx
    mov [orirsi], rsi

    lodsb

    bt ax, 7
    
    jc  .not_ascii
    ;ASCII character output directly
    dec rcx
    ret

.not_ascii:


    bt  ax, 6
    jnc .broken ;if starts with 10 then it's broken

    bt  ax, 5
    ;if starts with 110 then it's 2 bytes
    jnc .two_byte

    bt  ax, 4
    ;if starts with 1110 then it's 3 bytes
    jnc .three_byte

    ;seems utf8 max only 4 bytes, so directly enter main branch
    jmp .four_byte

;2 bytes
.two_byte:

    ;first process first byte
    mov dl,  al ;110XXXXX
    and dl,  31 ; 0b11111
    shl dx,  6
    lodsb
    bt  ax,  7
    jnc .fail
    bt  ax,  6
    jc  .fail
    and al,  63
    or  ax,  dx
    sub rcx, 2
    jmp .check
    
;3 bytes
.three_byte:

    mov dl,  al
    and dl,  15
    shl edx, 12
    lodsb
    bt  ax,  7
    jnc .fail
    bt  ax,  6
    jc  .fail
    and al,  63
    shl ax,  6
    or  edx, eax
    lodsb
    bt  ax,  7
    jnc .fail
    bt  ax,  6
    jc  .fail
    and ax,  63
    or  eax, edx
    sub rcx, 3
    jmp .check

;4 bytes
.four_byte:

    mov dl,  al
    and dl,  7
    shl edx, 18
    lodsb
    bt  ax,  7
    jnc .fail
    bt  ax,  6
    jc  .fail
    and al,  63
    shl eax, 12
    or  edx, eax
    xor eax, eax
    lodsb
    bt  ax,  7
    jnc .fail
    bt  ax,  6
    jc  .fail
    and al,  63
    shl ax,  6
    or  dx,  ax
    lodsb
    bt  ax,  7
    jnc .fail
    bt  ax,  6
    jc  .fail
    and ax,  63
    or  eax, edx
    sub rcx, 4

.check:
;rax is already decoded

    test rax, rax
    jz   .fail

    cmp rax, 0x10FFFF
    ja  .fail

    cmp rax, 0xD800
    jb  .normal_exit
    cmp rax, 0xE000
    jb  .fail

.normal_exit:
    ret

.fail:
    mov rsi,       [orirsi]
    mov word [r8], 0xFFFF
    xor rax,       rax
    ret

.broken:
    dec rsi
    xor eax, eax
    ret

;utf8t16le main function
;(source, source length, destination, destination length)
;source length negative means auto-calculate, destination length must be at least 2 times source length
;return value: error (null pointer, insufficient length) is 0,
;character error: word pointed to by r8 is FFFF
kp_text_utf8t16le_main_fastcall_win64:

    test rcx, rcx
    jz   .null_pointer
    test r8,  r8
    jz   .null_pointer

    test r9, r9
    jz   .null_pointer

    test rdx, rdx
    jz   .null_pointer
    jns  .have_str_len

    push rcx
    push r8
    push r9

    adod

    sub  rsp, 32
    ;written but not used is wasteful
    call kp_avx2_strlen_fastcall_win64

    pdod

    pop r9
    pop r8
    pop rcx

    mov rdx, rax

.have_str_len:

    lea rax, [rdx+rdx+2]
    cmp rax, r9
    ja  .null_pointer

.prepare:

    push rsi
    push rdi

    mov rsi, rcx
    mov al,  [rsi+rdx]

    mov rdi, r8

    bt  ax, 7
    jnc .check_bom
    bt  ax, 6
    jnc .error

.check_bom:
    cld
    mov  rcx, rdx
    ;rdx should be unused now
    .main:
    ;now rcx equals byte count
    call kp_text_utf8_single_symbol_decode_inside
    test rax, rax
    jz   .error
    cmp  rax, 0xFFFF
    ja   .pair
    stosw
    test rcx, rcx
    jnz  .main

.exit:
    xor eax, eax
    stosw
    mov rax, rdi
    pop rdi
    pop rsi
    ret

;surrogate pair
.pair:
    sub  eax, 0x10000
    mov  edx, eax
    shr  eax, 10
    and  edx, 0x3FF
    add  eax, 0xD800
    add  edx, 0xDC00
    stosw
    mov  eax, edx
    stosw
    test rcx, rcx
    jnz  .main
    jmp  .exit

.error:

    pop rdi
    pop rsi

    xor rax, rax

    ret

;null pointer, empty city strategy, not big enough return
.null_pointer:
    xor rax, rax
    ret







;   Note:  end of code section (I really hate that NASM has no end marker and I keep making mistakes)

WARNING_SIGN:

section kpstdlib

A_UNAVAILABLE_SIGN:

ksignlabel:
;KUSSA(KUSSA_LTSC)
    jmp ksignlabel
    db 'KUSSA_LTSC'

;Content from another project:

    ;"We made a difficult decision":

        ;Starting from September 6, 2026, this teaching demo no longer follows the GPL, and switches to KUDOS
        ;Versions already released under GPL are unaffected
        ;Because closed-source libraries or source-visible libraries need to be used, which does not meet GPL requirements

    ;September 6, 2026

;What you must know:

    ;It is not an open source license, only source-visible
    ;If you are a student and study assembly for hobby purposes unrelated to work, you can freely research and study
    ;This code is free, don't sell it for money
    ;If you paid for it, you were scammed a little money
    ;Free link: https://github.com/KUSSA-LTSC/KUDOS-kpstdlib/

;September 11, 2026

; What you must know:
;
; It is not an open source license, only source-visible.
; This is not an OSI open source license.
;
; This code is free, don't sell it for money.
; If you paid for it, you were scammed.
; Free link: https://github.com/KUSSA-LTSC/KUDOS-kpstdlib/
;
; Individuals may study assembly for hobby, private, non-commercial purposes.
; Students may study, but only for personal private study, or the
; "permitted educational uses" defined by the license: public free courses on mainstream online platforms.
;
; It is forbidden to share the source code, modified versions, binaries with friends, classmates, colleagues,
; students, other departments, subsidiaries, or any third party.
; Research cooperation, peer review, and paper publication follow Section 1.4 of the license.
;
; Configuration files may be public, but must not contain source code, scripts, binaries,
; executable logic, or any material that can reconstruct the software.
;
; Commercial use, use by for-profit entities, evaluation, testing, bundling, AI training,
; all require prior written paper consent from the project owner.
;
;September 12, 2026

; Damn, I'm going to die from exhaustion.

;September 13, 2026

; Is high school hell? Today is the September 18th remembrance day.

;September 18, 2026

; Happy Mid-Autumn Festival.
; Happy my ass, struggling through homework together.
; That bloated filetime_to_realtime I will rewrite sooner or later.

; I'm really exhausted.
; This bloated thing still has a bunch unfinished.
; Even a bunch of instruction sets.

; Technically there is a bunch of technical debt.
; Functionally there is a bunch unfinished.
; Comments are also still missing a huge amount; AI-written comments are crap, not like human-written.

; Still, Kikuri Hiroi is my favorite one.

;September 24, 2026

; Getting old really makes me useless; today I only wrote 02 functions.
; The last day of September.
; How can homework be used as a stool?

;September 30, 2026

; Today is October 01, National Day.

; On this happy day, I sincerely wish our motherland a happy birthday.
; On this happy day, I sincerely wish our motherland a happy birthday.

; I wrote a lot today, such as the AVX2 version of strlen.

; The code has passed 2000 lines, but most of it is comments, haha~

;October 1, 2026

; I hate string formatting.
; I'm really done with this annoying thing.
; Homework, I can't finish it.

;October 2, 2026

; Added some comments, and because I feel unwell I don't want to do homework.

;October 3, 2026

;That's the bottom, that's all~