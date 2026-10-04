;kpstdlib.asm

;KUSSA_LTSC 2026 All rights reserved

;Old declaration retained:

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-scancode-kudos-sal-2.5

;KUSSA's standard library
;Source-visible, for free educational research and study only
;I'll add comments later

;What is this: a NASM project (obviously)
;What is it for: to write C code
;Why are you looking at it: none of my business
;Can you learn something from it: yes, but I haven't finished the comments
;It may not be as exemplary as other online tutorials
;It leans more toward the old-style 8086-era way of writing
;It makes decisions and trade-offs regarding the x86-64 instruction set
;It has far fewer restrictions than 8086
;Is this a beginner version: no, I suggest you learn another language first or read other assembly tutorials first
;Is this a beginner version: yes, here you can encounter most places where beginners easily make mistakes and get confused
;What can you learn from it: a lot, depends on how you learn
;Is it standardized: in terms of calling convention, it basically conforms to the Microsoft x64 ABI
;But its style may be rather bizarre
;What if you can't understand it: don't read it, or go ask AI
;Is it completely handwritten: yes, though I may have had AI help check some parameters, for example I once typoed GetFileSizeEx as GetFileSizeEX
;I often have AI look at compile and link errors for me, and help me look up the Intel SDM PDF
;Is it easy to use: not necessarily, but except for the Win32 API wrappers, everything returns NULL to indicate failure
;NULL is a constant, equal to zero
;How do I decide what to update: I write whatever I need
;(In fact, a month has passed and I still haven't finished the functions needed for my logging feature
;Can it replace the CRT: it can do quite a lot now, but it cannot fully replace it yet
;Why wrap system APIs: because they are not necessarily compatible with windows.h, to help me remember better, to make maintenance and porting easier, and to make writing programs more convenient
;Besides, why should you learn assembly: it lets you better understand how code works and solve many bizarre bugs
;But learning assembly is not easy for most people
;I am the exception; instead, I always have problems writing C code and don't know how to fix bugs
;Will its performance be better than the CRT: no, about the same; maybe some aggressive functions are a tiny bit faster
;In short, you need some programming foundation, and you need to be patient enough to understand 8086 instructions or x86 instructions to understand most of it. Comments are not a babysitter; they only point out the most important and easily mistaken things
;Warning: internal functions and unfinished functions must never be exported, and should not be modified. They exist only to facilitate code reuse for business services in specific scenarios

;bash:

;nasm -f win64 .\kpstdlib.asm -o .\kpstdlib.obj 
;gcc -o test.exe test.c kpstdlib.obj -nostdlib -lkernel32 -luser32 -mwindows -e main -ffreestanding -fno-stack-protector -fno-asynchronous-unwind-tables -O2

;New declaration:

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-KUDOS-Source-Available-2.5
;
; KUSSA's standard library
; This is NOT an open source license. This is a source-available,
; anti-commercial license.
;
; This file is licensed only under the KUDOS SOURCE AVAILABLE LICENSE Version 2.5.
; See the project root for full terms:
; KUDOS SOURCE AVAILABLE LICENSE.txt
;
; Without the prior written consent on paper of the project owner, the following are prohibited:
; - Commercial use, use by for-profit entities, evaluation or testing by for-profit entities;
; - Distributing, publishing, uploading, or sharing this software or modified versions with any third party;
; - Combining, linking, or distributing together with commercially related bundles;
; - Using this software to train, fine-tune, distill, or evaluate any AI or machine learning model.
;
; Permitted uses are limited to those explicitly specified in the license:
; - Personal private study;
; - Internal administrative use of the original unmodified software by non-profit organizations;
; - Public free courses on mainstream online platforms;
; - Non-commercial research, peer review, and paper publication under Section 1.4.
;
; Configuration files may be shared publicly if they do not contain source code, scripts, binaries, or executable logic.

;About the license:

; This is a license leaning toward education and rejecting commercialization
; It is not an open source license, but it can relatively well facilitate my future use of other people's closed-source libraries
; Of course, if there is a chance later, and it can independently implement all functions except system functions, the library license will likely revert to GPLv3

; Of course, it is hard to implement all functions without relying on third-party or closed-source libraries; I cannot learn everything

;...Code below...

; %include 'third.inc'
%include 'kmarco.inc'

;Macro expansion is placed here, stop asking me!
;It's from the macro file at the beginning, written by me
;Don't worry about these two lines; it's fine if you don't understand them
;Default stack alignment to 16 is handled automatically

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
; SPDX-License-Identifier: LicenseRef-scancode-kudos-sal-2.5

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

; Equivalent to pdod
; %macro kaak 0
;     mov rsp, rbp
;     pop rbp
; %endmacro

bits    64
default rel

;The project start date is unknown, but it can be confirmed to be on or before August 26, 2026

;Although it's also for teaching and performance doesn't need to be too good, I still want to pursue some perfection
;For ease of debugging and writing, use r64 for all registers unless unnecessary
;Labels are written carelessly because my English is not good

; bu, date, dlsbur, dust, wasteimm are global static buffers.
; Functions that use these addresses absolutely, absolutely, absolutely must not be called concurrently in multiple threads!

global  bu
; global  realseconds
; global  realminutes
; global  realhours
; global  realdays
; global  realmonth
; global  realyears
; This dlsbur can customize symbols, limited to 8 ASCII characters
global  dlsbur
; global  kp_prtnum_frmstk_wthrcx_rep_fastcall_win64
global  kp_replace_single_dollar_symbol_wthcnt_fastcall_win64
global  kp_improved_filetime_to_realtime_calc_fastcall_win64
global  kp_filetime_to_realtime_frmrax_ret_fastcall_win64
global  kp_win32api_get_file_pointer_ex_fastcall_win64
global  kp_win32api_set_file_pointer_ex_fastcall_win64
global  kp_win32api_get_file_size_ex_fastcall_win64
global  kp_win32api_ezutf16le2utf8_fastcall_win64
global  kp_win32api_virtual_alloc_fastcall_win64
global  kp_win32api_virtual_free_fastcall_win64
global  kp_win32api_close_handle_fastcall_win64
global  kp_win32api_createfile_w_fastcall_win64
global  kp_win32api_ezutf8t16le_fastcall_win64
global  kp_win32api_write_file_fastcall_win64
global  kp_text_utf8t16le_main_fastcall_win64
global  kp_win32api_read_file_fastcall_win64
global  kp_text_format_divide_fastcall_win64
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
    ;Dump data here first
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
    realdays    dq 0 ;day
    realhours   dq 0 ;hour
    realminutes dq 0 ;minute
    realseconds dq 0 ;second
    
    ;Year constant, year 1600
    aoeg        equ 50491123200
    ;Beijing time offset
    UTC8_OFFSET equ 28800
   ;FileTime subtraction value to disable Beijing time
    unboeg equ UTC8_OFFSET*10000000
    ;Year constant with Beijing time offset added
    boeg   equ aoeg+UTC8_OFFSET
    
    ;placeholder garbage
    dust times 128 db 0

    ;month table
    mthcom             db  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    mthlep             db  31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    ;time constants
    seconds_per_day    equ 86400
    days_per_4_years   equ 1461
    days_per_100_years equ 36524
    days_per_400_years equ 146097
    ;new $ replacement buffer
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


; Mysterious constants, extracted from windows.inc

; ==================== General ====================
; empty content, null pointer
NULL                  equ 0
; true
TRUE                  equ 1
; false
FALSE                 equ 0
; default window position, let the system choose
CW_USEDEFAULT         equ 0x80000000
; infinite wait
INFINITE              equ 0xFFFFFFFF

; ==================== Window class styles ====================
; redraw when window changes vertically
CS_VREDRAW            equ 0x0001
; redraw when window changes horizontally
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
; has system menu (icon at upper left)
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
; normal display
SW_SHOWNORMAL         equ 1
; minimized display
SW_SHOWMINIMIZED      equ 2
; maximized display
SW_SHOWMAXIMIZED      equ 3
; display according to most recent state
SW_SHOW               equ 5
; restore from minimized/maximized
SW_RESTORE            equ 9

; ==================== Window messages ====================
; window created
WM_CREATE             equ 0x0001
; window destroyed
WM_DESTROY            equ 0x0002
; window size changed
WM_SIZE               equ 0x0005
; needs repaint
WM_PAINT              equ 0x000F
; close request
WM_CLOSE              equ 0x0010
; exit message loop
WM_QUIT               equ 0x0012
; key down
WM_KEYDOWN            equ 0x0100
; key up
WM_KEYUP              equ 0x0101
; character input
WM_CHAR               equ 0x0102
; menu/control command
WM_COMMAND            equ 0x0111
; timer triggered
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

; ==================== MessageBox ====================
; only an OK button
MB_OK                 equ 0x00000000
; OK + Cancel
MB_OKCANCEL           equ 0x00000001
; Yes + No
MB_YESNO              equ 0x00000004
; error icon
MB_ICONERROR          equ 0x00000010
; question icon
MB_ICONQUESTION       equ 0x00000020
; warning icon
MB_ICONWARNING        equ 0x00000030
; information icon
MB_ICONINFORMATION    equ 0x00000040

; ==================== MessageBox return values ====================
; user clicked OK
IDOK                  equ 1
; user clicked Cancel
IDCANCEL              equ 2
; user clicked Yes
IDYES                 equ 6
; user clicked No
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
; reserve: only occupy address space, do not allocate physical storage
MEM_RESERVE           equ 0x2000
; decommit, keep address
MEM_DECOMMIT          equ 0x4000
; fully release (address + storage)
MEM_RELEASE           equ 0x8000
; no access
PAGE_NOACCESS         equ 0x01
; read/write
PAGE_READWRITE        equ 0x04

; ==================== Files ====================
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
; from beginning of file
FILE_BEGIN            equ 0
; from current position
FILE_CURRENT          equ 1
; from end of file
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
;A very old-fashioned way of writing, there are 4 SIMD examples later
kp_strlen_fastcall_win64:
;Only one parameter, rcx holds string start, returns rax, unit is bytes    
    xor  rax, rax
    ;rax=0 is used to search for \0
    push rdi
    mov  rdi, rcx
    mov  rcx, -1

    cld;clear direction flag

    repne scasb;repeat; while not equal, continue scanning and comparing al with [rdi]
    or  rcx, rcx
    ;This is purely an 8086 aftereffect. If rcx=0 it means not found or exactly landed, but x64 registers are very large, so there is no special handling
    jz  .nofind
    not rcx      ;invert
    dec rcx      ;decrement by one
    ;This way we get the length; the principle is due to binary properties
    mov rax, rcx
    pop rdi
    ret

.nofind:
    xor rax, rax
.ret:
    pop rdi
    ret

;Already deprecated, kept here purely for archival, with stack diagram attached
;8086-era function, used at the time to output numeric strings in batches, but I found it not easy to use on x64
;! Warning: unfinished function, absolutely do not use!
kp_prtnum_frmstk_wthrcx_rep_fastcall_win64:
;Subroutine, assumed already aligned, and no register-passed parameters
;Currently the function of passing parameters via RAX has not been implemented
;If rcx is 0, it means there is no number, exit directly
    or   rcx, rcx ;.....[STACK].....
    jz   .exit    ;NUM2       RBP+56
    push rbp      ;NUM1       RBP+48
    mov  rbp, rsp ;SHADOW 4
    push rsi      ;SHADOW 3
    push rcx      ;SHADOW 2
    push rax      ;SHADOW 1
    push rbx      ;RET        RBP+8
    push rdx      ;RBP    0   RBP+0
    push rdi      ;RBP points to the original RBP PUSH
;save all used registers
    ;PREPROCE

    xor rsi, rsi
    xor rdi, rdi

;overall loop conversion output
.lb_tltp:

    mov rax, [rbp+rsi+48] ;read number from stack
;added negative check
    ; test rax, 0x8000000000000000
    ; Well, x64 cannot directly write a 64-bit imm except with mov
    ; jz   .np
;changed to a shorter way
    or  rax, rax
    jns .isnotnegative
;if not negative, skip
    mov byte [bu], 45 ;ASCII for negative sign
    inc rdi
;convert negative to positive
    neg rax
;label: not negative
.isnotnegative:
    mov  rbx, 10
    push rcx
    xor  rcx, rcx
;division loop, divide by 10 each time to get the ones digit
.divlop:
    inc  rcx      ;STACK
    xor  rdx, rdx ;ori_rcx,rcx*rdx
    div  rbx
    push rdx
    or   rax, rax
    jz   .preprt

    jmp .divlop
;prepare to print
.preprt:

    lea rbx, [bu]
;print loop (actually writing to memory)
.lre:

    pop rdx
    add rdx,       48
    ;convert to ASCII and write
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .lre

;Here rdx will all be popped, rsp points to ori_rcx

    ; inc rdi
    mov byte [rbx+rdi], 0
    ;append 0 at the end

;Here it should call output bu, but that's not done yet

;initialize for next loop

    xor rdi, rdi
    add rsi, 8
    pop rcx

    dec rcx
    jnz .lb_tltp

    

;rcx=0,rsp points to ori_rdi

    pop rdi
    pop rdx
    pop rbx
    pop rax
    pop rcx
    pop rsi
    pop rbp

;Logically AX should be reserved for the return value, but actually I'm too lazy

.exit:
    ret


;Pending agenda, parameters, for example RAX could indicate whether signed is enabled, whether address write-back is enabled; if enabled, address defaults to starting at RBX. I don't know whether 64-bit has a special text command for strided writing. I remember before you could directly set direction, interval, then put text
;Now there is no pending item; this function is deprecated. It is x64 now, not 8086
;Once again, this function is deprecated. Just treat it as an advertisement (October 3, 2026)

;Internal function, C cannot use it directly, 8086 code port
;Print rax separately, for logging; should not corrupt any registers
;Corrupts RAX return
kp_prtnum_frmrax:
;Assumes rax has already been assigned
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;check for negative
    jns  .isnotnegative ;if not negative, skip
    mov  byte [bu], 45  ;ASCII for negative sign
    
    inc rdi
    neg rax ;convert negative to positive

;go here if not negative
.isnotnegative:
    push rsi
    push rcx
    push rdx
    push rbx
    mov  rbx, 10
    xor  rcx, rcx
;division loop
.divlop:
    inc  rcx
    xor  rdx, rdx
    div  rbx
    push rdx
    or   rax, rax
    jz   .preprt
    jmp  .divlop
;print preparation
.preprt:
    lea rbx, [bu]
    ;print to bu first, load address here
;write digits loop
.loopofrewrite:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .loopofrewrite

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

;Calculate date; from parameters 3 to 8 return year, month, day, hour, minute, second (why is this here)
;(This line of comment is clearly written at the beginning of kp_filetime_to_realtime_frmrax_ret_fastcall_win64)
;(Actually I forgot to delete it when moving; treat it as an easter egg) (October 3, 2026)

;Print rcx separately; now C code can use it
;Trivial trampoline function, haha, this is the shortest one
kp_prtnum_frmrcx_fastcall_win64:
    mov rax, rcx
    jmp kp_prtnum_frmrax

;Text copy, with checks (actually useless checks)
;rcx holds source pointer, rdx holds source length, r8 holds destination pointer, r9 holds destination length, all units in bytes
;Returns pointer to trailing 0; if rdx is negative, calculate automatically
kp_strcpy_fastcall_win64:
    
    or rcx, rcx
    jz .mgd
    or r8,  r8
    jz .mgd
    ;They say there are null pointers

    or   rdx, rdx
    jns  .havesrclen
    push rcx

    call kp_strlen_fastcall_win64 ;First function
    ;It does not corrupt registers so it can be used directly, but if using the later SIMD version it may corrupt registers, so save them
    mov  rdx, rax                 ;return value in rax, calling convention

    pop rcx

.havesrclen:

    cmp rdx, r9
    jae .mgd
    ;if source is longer than destination, exit
    ;No longer check whether rcx is 0 because 0 is fine
    ; push rbp
    ; mov  rbp, rsp
    ; stack frame is no longer needed now

    cld

    push rsi
    push rdi

    mov rsi, rcx ;source
    mov rdi, r8  ;destination
    cmp rdx, 15  ;branch for different lengths
    ja  .msq
    mov rcx, rdx
    rep movsb

    mov byte [rdi], 0

    jmp .normal

.msq:
    mov rcx, rdx
    shr rcx, 3
    rep movsq;movsq is faster than movsb on old CPUs, but actually all x64 have SSE2
    mov rcx, rdx
    and rcx, 7
    rep movsb

    mov byte [rdi], 0 ;append 0 at the end
    
.normal:
    ; sub rdi, r8
    ; mov rax, rdi
    ; Commenting this way is returning length, meaningless, equals srclen
    mov rax, rdi
    ;return pointer
    pop rdi
    pop rsi
    ret

.mgd:
    xor rax, rax ;0 represents failure, or length is 0
    ; mov rsp, rbp
    ; pop rbp
    ret

db '少羽牛逼' ;This is the signature, i.e. the feature. These 4 characters will be placed unchanged into the exe. Later, to check this function, just search for the signature in x64dbg and you can locate here

;Input rcx, can use system-provided time GetSystemTimeAsFileTime
;Parameters: rcx holds time provided by system, 1 address used to return compact plain-text time
;For example: 20260905220631_134330908XXXXXXXXX\0
;The remaining 6 addresses are memory pointers for year, month, day, hour, minute, second respectively
;void(imm64,immmem64ptr,mem64addr*6)
kp_filetime_to_realtime_frmrax_ret_fastcall_win64:
;There were design problems at the time; I only considered Beijing time and didn't consider making it a UTC offset all at once
;And I didn't consider structs at the time either, so it's very messy
;If you pass a null pointer, the program won't crash, it just won't return anything. Yes, I didn't consider return values at the time because they weren't needed, or rather I never thought it could fail
;The function of the biggest project, I can only say

; ...STACK_TABLE...
; P8 second   RBP+72
; P7 minute   RBP+64
; P6 hour     RBP+56
; P5 day      RBP+48
; S4      R9
; S3      R8
; S2      RDX
; S1      RCX
; RET     RBP+8
; RBP     RBP
; RBX
; RSI
; RDI

    push rbp
    mov  rbp, rsp ;will be used to get parameters later
    push rbx
    push rsi
    push rdi
    push r15

    ; xor rsi, rsi
    ; mov rdi, 7
    ; if expanded, these two lines are unnecessary

;Check null pointers; although expansion has better performance, fine, let's expand it
    or  rdx, rdx
    jz  .nulptr
    or  r8,  r8
    jz  .nulptr
    or  r9,  r9
    jz  .nulptr
    mov rax, [rbp+48]
    or  rax, rax
    jz  .nulptr
    mov rax, [rbp+56]
    or  rax, rax
    jz  .nulptr
    mov rax, [rbp+64]
    or  rax, rax
    jz  .nulptr
    mov rax, [rbp+72]
    or  rax, rax
    jz  .nulptr



    mov [rbp+16], rcx
    mov [rbp+24], rdx
    mov [rbp+32], r8
    mov [rbp+40], r9
    ;all parameters saved, first 4 in shadow space
    mov rax,      rcx

    xor rbx, rbx ;I forgot what this line is for too; it's actually useless (yes, useless, kept as an easter egg) (October 3, 2026)
    
    ;modified, but behavior is basically unchanged
    ;so that ft=0 can also return correctly
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
    ;if you can't understand, go check the SDM
    mov [days],     rax
    mov [seconds],  rdx
    mov rcx,        days_per_400_years ;first calculate how many complete 400-year periods
    xor rdx,        rdx
    div rcx
    mov [nboffhys], rax
    mov rax,        rdx
    mov rcx,        days_per_100_years ;continue dividing by 100 years
    xor rdx,        rdx
    div rcx
    mov [nbofohys], rax
    mov rax,        rdx
    mov rcx,        days_per_4_years   ;calculate how many 4-year periods
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
    ;now all parts except less than 4 years have been calculated

;first compare whether leap year handling is necessary
    mov rax, [tempdays]
    cmp rax, 1460
    je  .skipdivy
    ;this label is later
    mov rcx, 365
    xor rdx, rdx
    div rcx

;1460 days directly teleports here    
.skipdivn:    
    
    ;save remaining years and days
    mov [nbofovys],  rax
    mov [overdays],  rdx
    mov r9,          rax
    inc rax
    add rax,         [tempyears]
    mov [realyears], rax
    ; mov rax,         r9

    ; Comments written for AI after being angered to death by AI
    ; tempyears = absolute year-1 - ((absolute year-1) mod 4)
    ; = current 4-year period start - 1 (not absolute year!)
    ; Example: 2000 -> 1996, 2001 -> 2000, 1900 -> 1896
    ; Purpose: compare tempyears with tempyears+4 /100, /400
    ;   equal -> no crossing; not equal -> crossed, continue checking 400
    ; Absolute year = tempyears + 1 + nbofovys (complete years already passed in current period)

    ;now check whether there is a century common year

    lea rbx, [mthlep]
    lea rcx, [mthcom]
    ;In VS Code, hovering the cursor over it shows the comment above the label (plugin required)

    ; cmp    rax, 3
    cmp    r9,  3
    cmovne rbx, rcx
    jne    .lepsub

    ;next we need to consider leap years
    mov   rax, [tempyears]
    mov   r9,  rax
    ;copy rax first; r9 is the original tempyears of rax
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
    ;here it is still the leap year table
    je    .lepsub
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
    ;compare; equal means it is not a 400-year leap, but a century common year
    lea   rbx, [mthlep]
    lea   rcx, [mthcom]
    cmove rbx, rcx

;code reuse here
;subtraction for calculating month
;this expects rax to equal the extra days, already initialized below

.lepsub:
    mov rax, [overdays]
    xor rcx, rcx
    xor rsi, rsi

.leplop:
    inc   rcx
    ;Does anyone really remember that rsi has been zeroed? (Originally at the beginning)
    ;OK now changed to zero it in advance
    movzx rdx, byte [rbx+rsi]
    inc   rsi
    cmp   rax, rdx
    ; jge   .lepsub
    jb    .edlepsub
    sub   rax, rdx
    jmp   .leplop

.edlepsub:    
    ;rax=remaining days, rcx equals month
    inc rax
    ;this is the unfinished day, so add it
    mov [realdays],  rax
    mov [realmonth], rcx

;At this point year, month, day are calculated; next are hour, minute, second  
    mov rax, [seconds]
    xor rdx, rdx
    mov rcx, 3600
    div rcx

    mov [realhours], rax
    
    ;now give the remaining seconds in rdx to rax
    xchg rax, rdx
    xor  rdx, rdx
    mov  rcx, 60
    div  rcx

    mov [realminutes], rax
    mov [realseconds], rdx

;now output return values

    lea rbx, [date] ;currently default output goes here

    ;rbx is ready for output
    
    mov rax, rbx
    mov r9,  datelen
    xor rsi, rsi
    mov rdi, 6
    lea r15, [realyears]
.reprtlop:
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
    ;this function returns rax as the end address
    add  rsi, 8
    dec  rdi
    jnz  .reprtlop
    ;In the 8086 era I was still used to loops to compress code, but now theoretically unrolling gives better performance

;now the time has been concatenated

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
    
;newly added $ rewriting
    mov rcx, 0x007D3B3A3A5F2D2D
    ;equals ('--_::;}',0)
    ;little-endian must be written reversed
    ;small update, now has } ending

    mov [dlsbur], rcx ;this is a parameter for another function's matter

;r9 length must be provided yourself
    lea  rcx, [date]
    call kp_strlen_fastcall_win64
    mov  r9, rax

    lea rcx, [dlsbur]
    mov rdx, -1
    lea r8,  [date]

    call kp_replace_single_dollar_symbol_wthcnt_fastcall_win64
    ;I think it won't fail, and there's nothing worth checking

    mov rcx,   [rbp+24]
    lea rdx,   [date]
    mov [rcx], rdx
    ;text date has been written back

    xor rsi, rsi
    mov rdi, 6

.reback:

    mov rcx,   [rbp+rsi+32]
    mov rdx,   [r15+rsi]
    mov [rcx], rdx
    add rsi,   8
    dec rdi
    jnz .reback

;return process

;null pointer return
.nulptr:

    pop r15
    pop rdi
    pop rsi
    pop rbx
    pop rbp

    ret

;1460-day special handling label
.skipdivy:
    mov rax, 3
    mov rdx, 365
    jmp .skipdivn

db 'This_is_a_sentence.' ;still a marker

;Damn, I finally finished this thing; the date function took me three weeks    
;Calculate date; from parameters 3 to 8 return year, month, day, hour, minute, second
;This thing tortured me for three weeks (ended September 13, 2026)

;Text copy, with checks (actually useless checks)
;The only difference from strcpy is
;ending is '$\0'
;rcx holds source pointer, rdx holds source length, r8 holds destination pointer, r9 holds destination length, all units in bytes
;Returns pointer to trailing 0; if rdx is negative, calculate automatically
kp_strcpy_enddls_fastcall_win64:
    
    or   rcx, rcx
    jz   .mgd
    or   r8,  r8
    jz   .mgd
    ;They say there are null pointers
    or   rdx, rdx
    jns  .busu
    push rcx
    call kp_strlen_fastcall_win64 ;Don't casually replace with another strlen, otherwise you have to save registers
    mov  rdx, rax
    pop  rcx
.busu:   
    lea r10, [rdx+1] ;check required size
    cmp r10, r9
    jae .mgd
    ;if source is longer than destination, exit
    ;No longer check whether rcx is 0 because 0 is fine
    ; push rbp
    ; mov  rbp, rsp
    ; not needed now

    cld

    push rsi
    push rdi
    ; mov  r9,  r8
    mov  rsi, rcx
    mov  rdi, r8
    cmp  rdx, 15
    ja   .msq
    mov  rcx, rdx
    rep movsb

    ; mov byte [rdi], 0 ; this is left over from strcpy, changed to the following
    ; mov ah,    0
    ; mov al,    ('$')
    mov ax,    0x0024
    ;write $\0 at once
    mov [rdi], ax
    inc rdi
    ;now rdi points to \0

    jmp .normal

.msq:
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

    ; jmp .normal
    
.normal:
    ; sub rdi, r8
    ; mov rax, rdi
    mov rax, rdi
    ;return pointer
    pop rdi
    pop rsi
    ret
    ; jmp .exit
.mgd:
    xor rax, rax
.exit:
    ; mov rsp, rbp
    ; pop rbp
    ret

;Replace all $ with custom ASCII symbols, currently limited to 8
;(source, source length, destination, destination length)
;source ending with 0; if source length is negative, calculate automatically
;source length is also the number of symbol replacements (equivalent to)
;does not return pointer, returns as bool, non-fixed value
kp_replace_single_dollar_symbol_wthcnt_fastcall_win64:
    push rbp
    mov  rbp, rsp
    push rsi
    push rdi
    
    or r9, r9
    jz .error
    ;if destination length is 0, what else is there to say

    or   rdx, rdx
    jns  .havelen
    mov  r10, rcx
    ;backup rcx
    call kp_strlen_fastcall_win64
    cmp  rax, dlsbur_len
    ja   .error
    mov  rdx, rax
    mov  rcx, r10
    ;restore rcx

.havelen:
    cmp rdx, 8
    ja  .error
    ;modified, now at most 8 replacements, because the buffer I gave is only this big
    ;September 24, 2026
    mov rsi, rcx
    ;now rsi points to source
    mov rdi, r8
    mov rcx, r9
    ;now rcx is the length

.replop:    
    mov al, ('$')
    mov ah, [rsi]

    cld
    repne scasb;scan
    jne .exit ;This only executes when rcx=0 or found. If the flag is not equal, it means not found; because length is set, it won't go out of bounds

    mov [rdi-1], ah
    inc rsi
    dec rdx

    or  rdx, rdx
    jz  .exit
    or  rcx, rcx
    jnz .replop

.exit:

;In short, rax on success does not return null

    pop rdi
    pop rsi
    pop rbp
    
    ret
    
.error:
    xor rax, rax
    jmp .exit


;Internal function, only for date feature    
;Corrupts RAX as return value
kp_prtnum_frmrax_intime:
;Assumes rax has already been assigned
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;check for negative
    jns  .np            ;if not negative, skip
    mov  byte [bu], 45  ;ASCII for negative sign
    inc  rdi
    neg  rax
.np:
    ; push rsi
    push rcx
    push rdx
    push rbx

    mov rbx, 10
    xor rcx, rcx
.divlop:
    inc  rcx
    xor  rdx, rdx
    div  rbx
    push rdx
    or   rax, rax
    ; jz   .preprt
    ; jmp  .divlop
    jnz  .divlop
.preprt:
    lea rbx, [bu]
    ;print to bu first
.lre:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .lre

    ; inc rdi
    mov byte [rbx+rdi], 0

;Data processing, used by date function for alignment
;if rsi is not 0, keep 2 digits
    ; mov  rsi,   [rbp+32]
    test rsi,   rsi
    jz   .sk
    mov  ax,    [rbx]
    test ah,    ah
    jnz  .sk
    xchg ah,    al
    ;swap one digit and '0'
    mov  al,    ('0')
    mov  [rbx], ax
    xor  rax,   rax

    mov [rbx+2], al
    ;append 0 at end

.sk:

    lea rax, [bu]
    ;return address

    pop rbx
    pop rdx
    pop rcx
    ; pop rsi
    pop rdi
    ret

;Append string at end, 4 parameters
;(source, source length, destination start, destination buffer length)
;if source length is negative, calculate automatically
;returns pointer to trailing \0, returns 0 on failure
kp_strend_fastcall_win64:

    ;check null pointers and zero length
    test rcx, rcx
    jz   .nullet
    test r8,  r8
    jz   .nullet
    test r9,  r9
    jz   .nullet
    test rdx, rdx
    jz   .nullet

    ;main part begins

    mov r10, rcx ; backup source pointer
    mov rcx, r8  ; rcx = dst, for internal strlen
    
    call kp_strlenled_inside
    ; Returns: rax = pointer to destination trailing \0, rcx = current destination length

    sub rcx, r9 ; current length - total capacity
    neg rcx     ; negate to get remaining space
    js  .nullet ; if negative, destination space is full, just leave

    mov r9,  rcx
    mov rcx, r10

;mysterious label
.noauto:   

    ;now we can start copying the string
    
    mov r8, rax ; r8 = address of destination trailing \0
    
    call kp_strcpy_fastcall_win64
    
    ret

;exit on null pointer or insufficient length
.nullet:
    xor rax, rax
    ret

;End of string
;Only one parameter, rcx holds string start, returns rax pointing to \0, returns 0 on failure
kp_strled_fastcall_win64:

    xor  rax, rax
    push rdi
    mov  rdi, rcx
    mov  rcx, -1
    cld

    repne scasb 
    or  rcx, rcx
    jz  .nofind
    ; not rcx
    ; dec rcx
    ; mov rax, rcx
    lea rax, [rdi-1]
    pop rdi
    ret
    ; jmp .ret

.nofind:
    xor rax, rax
.ret:
    pop rdi
    ret

;Internal function, for internal use only
;Corrupts rax, rcx; returns length and end respectively
kp_strlenled_inside:
;Only one parameter, rcx holds string start, returns rax pointing to \0, rcx returns length, both return 0 on failure
    xor  rax, rax
    push rdi
    mov  rdi, rcx
    mov  rcx, -1
    cld

    repne scasb 
    or  rcx, rcx
    jz  .nofind
    not rcx
    dec rcx
    lea rax, [rdi-1]
    pop rdi
    ret
    ; jmp .ret

.nofind:
    xor rax, rax
    xor rcx, rcx
.ret:
    pop rdi
    ret

;Use system API to quickly convert UTF8 to UTF16le
;int(src,srclen,dst,dstlen) all units in bytes
;No checks, directly use API return value * 2
;If what you pass is strlen without \0, you must append 0 yourself at the end
;I suggest directly filling length with -1
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

;Short-input version of time function; again, return values were not considered at the time
;void(filetime, fast string address, struct address start, disable Beijing time
;About disabling Beijing time (if 0, ignore; if non-zero, give UTC time)
kp_timefmt_fastcall_win64:    

    adod

    test rdx, rdx
    jz   .nodx    ;give a useless 8 bytes to prevent crash
.oudx:

    push rbx
    push rdi
    push r9
    push rdx
    mov  rbx, rcx

    test r9,  r9     ;check time flag
    jz   .enboeg
    mov  r10, unboeg ;roll back UTC time
    sub  rcx, r10
;if Beijing time enabled, jump directly
.enboeg:

    or  r8, r8
    jnz .normal
    lea r8, [dust]

.normal:

    adod

    ;parameter passing squad
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

    ;there is a push rdx before
    pop  rdi
    pop  r9
    test r9,  r9
    jz   .nore
    test rdi, rdi
    jz   .nore
    ;next, overwrite back to the real filetime
    mov  rdi, [rdi]
    mov  al,  ('{')
    mov  rcx, -1
    cld
    repne scasb
    jne  .nore
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
    ;But there is no way, because I need to maintain compatibility with the past
    ;Now I can only write a cramped portal/trampoline function to do it
    ;I'll write a complete version of this thing separately when I have time later

.nore:

    pop rdi
    pop rbx
    pdod

    ret

.nodx:
    lea rdx, [wasteimm]
    jmp .oudx

;Replace one $ with custom ASCII symbol
;(destination, character in dl), corrupts rax, rcx
;No checks at all, internal function
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

;Test function, SIMD version of strlen
;rcx holds string start
;Really, driving a flying car and still need a seatbelt, so annoying
kp_simd_strlen_fastcall_win64:
    ;Because using movdqu unaligned version, must constantly check page boundaries

    mov r9,  16
    xor rdx, rdx

    pxor xmm1, xmm1

.label:

    ;check page boundary
    mov r10, rcx
    and r10, 0xFFF ;take high 12 bits
    cmp r10, 4080  ;compare with last page start
    ja  .slow
    ;if near page boundary, switch to slow branch

    movdqu   xmm0, [rcx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0
    
    or  r8, r8
    jnz .found

    add rdx, r9
    add rcx, r9

    jmp .label

.found:

    tzcnt r8d, r8d

    lea rax, [rdx+r8]

    ret

.slow:

    push rdi
    mov  rdi, rcx
    xor  rax, rax
    neg  r10
    lea  rcx, [r10+4096]
    mov  r11, rcx
    cld
    repne scasb
    jne  .nofd
    neg  rcx
    lea  rcx, [r11+rcx-1]
    lea  rax, [rdx+rcx]
    pop  rdi
    ret
    
.nofd:
    add rdx, r11
    mov rcx, rdi
    pop rdi
    jmp .label
    
;SSE version of strlen, rcx=src
;ONE OF the weirdest functions written so far
;Leave the comments for 20,000 years later
;So ingenious that changing one letter might completely crash it
kp_sse_strlen_fastcall_win64:
;I really don't want to write this comment; one register is used as 4 variables
;No mask merging, can only process 16 bytes at a time

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

.label:

    movdqa   xmm0, [rcx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    test r8, r8

    jnz .ssefound

    add rcx, r9
    add rdx, r9

    jmp .label

.ssefound:

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

;Test function, copy memory with MOVSB
;Recommended on CPUs supporting ERMSB
;(src,srclen,dst,dstlen)
kp_ermsb_fastcall_win64:
;Does this kind of function have any meaning? Just so it can be used in C

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



;Read binary as hexadecimal and convert to hexadecimal ASCII text
;(source, source length, destination, destination length) units in bytes
;Returns: address of trailing \0; when chaining, overwrite from this address
;Still no null pointer checks; leave comments for tomorrow
kp_hex2ascii_fastcall_win64:

    cld

    lea r10, [rdx*2]
    cmp r10, r9
    jae .mgd
    
    test rdx, rdx
    jz   .mgd
    
    push rbx
    push rdi
    push rsi

    xchg rcx, rdx

    lea rbx, [hex2ascii_xlatable] ;lookup table
    
    mov rdi, r8
    mov rsi, rdx
    ;rsi points to source
    
;loop
.xlatloop:

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
    jnz .xlatloop

    xor al, al

    stosb
    ;append 0 at end

    lea rax, [rdi-1]
    pop rsi
    pop rdi
    pop rbx

    ret

.mgd:
    xor rax, rax
    ret

;Two ASCII characters as one byte
;If the last thing you write is something like A\0, the table lookup will most likely not execute
;(source, source length, destination, destination length) units in bytes
;Returns: address after the last data byte; when chaining, continue writing from this address
;But you need to calculate the remaining length yourself or use dynamic memory
kp_ascii2hex_fastcall_win64:

    cld

    test rdx, rdx
    jz   .mgd

    shl r9,  1
    cmp rdx, r9
    ja  .mgd

;main text

    push rbx
    push rdi
    push rsi

    mov rsi, rcx
    mov rdi, r8
    mov rcx, rdx
    shr rcx, 1

    lea rbx, [ascii2hex_xlatable] ;lookup table

.xlatloop:

    lodsb;load

    xlat;lookup table

    mov r9b, al ;temporarily store
    
    lodsb;load

    xlat;lookup table

    shl r9b, 4   ;write back to high bits
    or  al,  r9b ;merge

    stosb;store

    dec rcx
    jnz .xlatloop

    lea rax, [rdi]

    pop rsi
    pop rdi
    pop rbx

    ret

.mgd:

    xor rax, rax

    ret

;Currently the most usable strlen
;Heavily modified SSE2 version
;rcx=src
kp_sse2_strlen_fastcall_win64:

    mov rdx, rcx
    mov r9,  rcx
    and rdx, -16 ;brute-force align
    sub rcx, rdx

    pxor     xmm1, xmm1
    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    shr r8d, cl ;remove useless mask
    jnz .found  ;non-zero means found

    test rdx, 16
    ;check alignment to 32
    jz   .ssego  ;If the fourth bit is set, it means adding sixteen directly aligns to 32 bytes

    add rdx, 16 ;Otherwise, still need to handle 16 bytes separately, then align

    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    test r8d, r8d
    jnz  .gofind

;preparation
.ssego:
    add rdx, 16
.sseloop:

    movdqa   xmm0, [rdx]
    movdqa   xmm2, [rdx+16]
    pcmpeqb  xmm0, xmm1
    pcmpeqb  xmm2, xmm1
    pmovmskb r8d,  xmm0
    pmovmskb eax,  xmm2
    
    shl  eax, 16   ;mask high bits
    or   r8d, eax  ;merge mask
    test r8d, r8d
    jnz  .ssefound

    add rdx, 32
    jmp .sseloop

.gofind:

    tzcnt eax, r8d
    sub   rdx, r9
    add   rax, rdx
    
    ret

.found:

    tzcnt eax, r8d

    ret

.ssefound:

    tzcnt eax, r8d

    sub rdx, r9
    add rax, rdx
    ret

;Heavily modified AVX2 version, similar to SSE2 version, too lazy to comment
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
    ;check alignment to 64
    jz   .avxgo

    add rdx, 32

    vmovdqa   ymm0, [rdx]
    vpcmpeqb  ymm2,ymm0, ymm1
    vpmovmskb r8d,  ymm2

    test r8d, r8d
    jnz  .gofind

.avxgo:
    add rdx, 32
.avxloop:

    vmovdqa   ymm0, [rdx]
    vmovdqa   ymm2, [rdx+32]
    vpcmpeqb  ymm0,ymm0, ymm1
    vpcmpeqb  ymm2,ymm2, ymm1
    vpmovmskb r8d,  ymm0
    vpmovmskb eax,  ymm2
    
    shl  rax, 32
    or   r8,  rax
    test r8,  r8
    jnz  .avxfound

    add rdx, 64
    jmp .avxloop

.gofind:

    tzcnt rax, r8
    sub   rdx, r9
    add   rax, rdx
    vzeroupper
    ret

.found:

    tzcnt rax, r8
    vzeroupper
    ret

.avxfound:

    tzcnt rax, r8
    vzeroupper
    sub   rdx, r9
    add   rax, rdx
    ret

;Wrapper for CreateFileW; return value follows the API, but failure is 0
;int(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition)
;Pass NULL for lpSecurityAttributes, pass NULL for hTemplateFile
;Pass FILE_ATTRIBUTE_NORMAL for dwFlagsAndAttributes
;No checks at all
kp_win32api_createfile_w_fastcall_win64:
    
    adod

    push r15 ;garbage alignment

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

    ret;Yep, it's really just this little

;Wrapper for GetFileSizeEx
;int(hFile,lpFileSize)
;Same as API: failure returns 0, success non-zero
kp_win32api_get_file_size_ex_fastcall_win64:

    adod

    sub  rsp, 32
    call GetFileSizeEx

    pdod

    ret;Probably the shortest one

;Wrapper for ReadFile
;int(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead)
;Behavior basically same as API; the 5th parameter is always NULL
;nNumberOfBytesToRead, how many bytes to read. DWORD, 32-bit.
;lpNumberOfBytesRead, pointer to a DWORD; the API writes how many were actually read. This value may be less than what you wanted to read.
kp_win32api_read_file_fastcall_win64:

    adod

    push NULL ;alignment
    push NULL

    sub  rsp, 32
    call ReadFile

    pdod

    ret

; Wrapper for WriteFile
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

;Wrapper for SetFilePointerEx
;(handle, offset, new position pointer, starting position)
;(hFile, liDistanceToMove, lpNewFilePointer, dwMoveMethod)
kp_win32api_set_file_pointer_ex_fastcall_win64:

    adod

    sub rsp, 32

    call SetFilePointerEx

    pdod

    ret;The shortest!

;Get file pointer
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

;Wrapper for CloseHandle
;(handle)
kp_win32api_close_handle_fastcall_win64:

    adod

    sub rsp, 32

    call CloseHandle

    pdod

    ret

;Wrapper for MessageBoxW
kp_win32api_msgbox_w_fastcall_win64:

    adod

    sub rsp, 32

    call MessageBoxW

    pdod

    ret

;Wrapper for WideCharToMultiByte
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




;Wrapper for VirtualAlloc
;(address, size, allocation type, protection attributes)
;(lpAddress, dwSize, flAllocationType, flProtect)
kp_win32api_virtual_alloc_fastcall_win64:

    adod

    sub rsp, 32

    call VirtualAlloc

    pdod

    ret



;Wrapper for VirtualFree
;(address, size, free type)
;(lpAddress, dwSize, dwFreeType)
kp_win32api_virtual_free_fastcall_win64:

    adod

    sub rsp, 32

    call VirtualFree

    pdod

    ret

;Originally the first step of character ascii_hex formatting
;Text grouping, byte-level processing, only suitable for ASCII and UTF-8
;You can input a negative number for parameter 4 to ignore (disable) length checking
; You can input a negative number for parameter 6 to ignore (disable) newline function
;By default use spaces to divide, newline uses 0x0A0D (little-endian), i.e. CRLF
;(source, source length, destination, destination length, how many bytes per group, how many groups per line)
;srclen=0 exits directly; failure returns NULL; success returns pointer to destination trailing \0
kp_text_format_divide_fastcall_win64:
;I announce that I will abandon comments for at least two months

;check srclen and dstlen

    ;perform a pointless act
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
    ;0 bytes per group, I can't help it
    test r11, r11
    jz   .error

    ;check rdx
    test rdx, rdx
    jz   .error
    jns  .havestrlen
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
.havestrlen:
    test rdx, rdx
    jz   .error

    mov r12, r10
    mov r13, r11
    mov r14, rdx

    xor eax, eax

    test r9,  r9
    jns  .r9ok
    bts  rax, 0  ;disable length check

.r9ok:
    test r11, r11
    jns  .chk
    bts  rax, 1   ;disable newline

.chk:

    push rax
    push rdx
    push rbx

    mov rax, rdx
    xor edx, edx
    mov rbx, r10

    div rbx

    mov  r10, rax
    test edx, edx
    jz   .alnd
    inc  r10      ;fallback for unaligned
.alnd:
;next calculate how many lines
    mov rax, r10
    xor edx, edx
    mov rbx, r11

    div rbx

    mov  r11, rax
    test rdx, rdx
    jz   .ok
    inc  r11
.ok:
    pop rbx
    pop rdx
    pop rax

;length calculation
    
;required length = source length + groups - lines + (lines - 1) * 2 + 1
;(srclen+groups+lines-1)
    lea rdx, [rdx+r10]
    lea r15, [r11-1]
    add rdx, r15

    bt rax, 0
    jc .main

    cmp rdx, r9
    jbe .main

    jmp .error

;main body, two
;respectively with newline and without
;All beings equal main, all beings equal rdx, everything else same except rax's bit 1
.main:

    bt   rax, 1
    jc   .disablenewline
    ;rcx=src,rdx=len,r8=dst,r10=groups,r11=lines,r12=objspergroup,r13=groupsperline
    push rdi
    push rsi
    mov  rsi, rcx
    mov  rdi, r8
    ;big loop = lines-1
    ;portal
    cmp  r11, 1
    je   .last
    lea  rcx, [r11-1]
;big loop, executes lines-1 times total
.big:
    push rcx
    mov  rax, 0x20
    mov  rcx, r13
    cmp  rcx, 1
    jz   .onegpl
    dec  rcx
    ;middle loop, each time executes groups per line - 1
    .mid:
    push rcx
    ;small loop, copies one group and formats each time
    mov  rcx, r12
    rep movsb
    stosb
    pop  rcx
    dec  rcx
    jnz  .mid
    ;when groups per line is 1
    .onegpl:
    mov  rcx, r12
    rep movsb
    mov  rax, 0x0A0D
    stosw
    pop  rcx
    dec  rcx
    jnz  .big
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
    je   .reallast
    dec  rcx
    .lastloop:
    push rcx
    mov  rcx, r12
    rep movsb
    stosb
    pop  rcx
    dec  rcx
    jnz  .lastloop

    .reallast:
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
    jmp .normalexit

.disablenewline:

    push rdi
    push rsi
    mov  rsi, rcx
    mov  rdi, r8
    mov  rcx, r10
    mov  rax, 0x20
    cmp  rcx, 1
    je   .dislast
    dec  rcx
    .disbig:
    push rcx
    mov  rcx, r12
    rep movsb
    stosb
    pop  rcx
    dec  rcx
    jnz  .disbig

.dislast:
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

.normalexit:

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

    ret;Wasted another whole day writing a pile of crap

;UTF-8 single character decode function
;Assumes rsi is already set
;rax=0 failure, on success returns character code point
;Corrupts rax, rdx
;Automatically decrements rcx
kp_text_utf8_single_symbol_decode_inside:

    xor eax, eax
    xor edx, edx
    mov r10, rsi

    lodsb

    bt ax, 7
    
    jc  .notascii
    ;ASCII character directly out
    dec rcx
    ret

.notascii:


    bt  ax, 6
    jnc .broken ;if it starts with 10, it means it's broken

    bt  ax, 5
    ;if it starts with 110, it means 2 bytes
    jnc .word

    bt  ax, 4
    ;if it starts with 1110, it means 3 bytes
    jnc .tri

    ;UTF-8 seems to have at most 4 bytes, so directly enter main branch
    jmp .double

;2 bytes
.word:

    sub rcx, 2
    js  .werr
    ;process first byte first
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
    jmp .check
    
;3 bytes
.tri:

    sub rcx, 3
    js  .terr
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
    jmp .check

;4 bytes
.double:

    sub rcx, 4
    js  .derr
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

.check:
;rax is already decoded

    test rax, rax
    jz   .fail

    cmp rax, 0x10FFFF
    ja  .fail

    cmp rax, 0xD800
    jb  .normalexit
    cmp rax, 0xE000
    jb  .fail

.normalexit:
    ret

.fail:
    mov rsi,       r10
    mov word [r8], 0xFFFF
    xor rax,       rax
    ret

.broken:
    dec rsi
    xor eax, eax
    ret

.werr:
    sub rsi, 2
    xor eax, eax
    ret

.terr:
    sub rsi, 3
    xor eax, eax
    ret

.derr:
    sub rsi, 4
    xor eax, eax
    ret

;UTF-8 to UTF-16LE main function
;(source, source length, destination, destination length)
;if source length is negative, calculate automatically; destination length must be at least twice the source length
;Return value: errors (null pointer, insufficient length) are 0,
;character error: the word pointed to by r8 is FFFF
kp_text_utf8t16le_main_fastcall_win64:
;Note: internal function corrupts r10; if you need it, save it before calling the subroutine

    test rcx, rcx
    jz   .npointer
    test r8,  r8
    jz   .npointer

    test r9, r9
    jz   .npointer

    test rdx, rdx
    jz   .npointer
    jns  .havestrlen

    push rcx
    push r8
    push r9

    adod

    sub  rsp, 32
    ;Wrote it, wouldn't hurt to use it
    call kp_avx2_strlen_fastcall_win64

    pdod

    pop r9
    pop r8
    pop rcx

    mov rdx, rax

.havestrlen:

    lea rax, [rdx+rdx+2]
    cmp rax, r9
    ja  .npointer

.prepare:

    push rsi
    push rdi

    mov rsi, rcx
    mov al,  [rsi+rdx]
    mov rdi, r8

    bt  ax, 7
    jnc .bthept
    bt  ax, 6
    jnc .error

.bthept:
    cld
    mov  rcx, rdx
    ;rdx is probably not needed anymore
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

;null pointer, empty city ruse, insufficient size returns
.npointer:
    xor rax, rax
    ret


;fmt function reset version
;(original filetime, struct pointer, flags, UTC offset - seconds)
;Flags: bit0 enable UTC offset, bit1 enable milliseconds, bit2 enable microseconds
;Struct unsigned long long, returns pure numbers instead of text
;(year, month, day, hour, minute, second, millisecond, microsecond)
;48~64 bytes; milliseconds and microseconds need to be enabled via flags
;Default is UTC time; if Beijing time is needed, add the offset
kp_improved_filetime_to_realtime_calc_fastcall_win64:

    ;null pointer check
    test rdx, rdx
    jz   .null

    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    
    mov [rbp+16], rcx
    ; mov [rbp+24], rdx
    mov [rbp+32], r8

    mov r11, rdx
    ;save original struct pointer
    mov rax, rcx
    xor rdx, rdx
    mov rcx, 10000000

    div rcx

    mov [rbp+24], rdx
    ;save subticks

    test r8,  1
    je   .nooffset
    add  rax, r9

.nooffset:

    lea rbx, [rbp-128]
    ;rax equals total seconds
    xor rdx, rdx

    mov rcx, aoeg
    add rax, rcx

    mov rcx, seconds_per_day

    div rcx
    
    ;rax=days, rdx=remaining seconds

    mov [rbx],    rax
    mov [rbx+8],  rdx
    mov rcx,      days_per_400_years ;first calculate how many complete 400-year periods
    xor rdx,      rdx
    div rcx
    mov [rbx+16], rax
    mov rax,      rdx
    mov rcx,      days_per_100_years ;continue dividing by 100 years
    xor rdx,      rdx
    div rcx
    mov [rbx+24], rax
    mov rax,      rdx
    mov rcx,      days_per_4_years   ;calculate how many 4-year periods
    xor rdx,      rdx
    div rcx
    mov [rbx+32], rax
    mov [rbx+40], rdx
    ;remaining days
    
    imul rax,[rbx+16],400
    mov [rbx+48], rax
    imul rax,[rbx+24],100
    add [rbx+48], rax
    imul rax,[rbx+32],4
    add [rbx+48], rax
    ;now all parts except less than 4 years have been calculated

    ;first compare whether leap year handling is necessary
    mov rax, [rbx+40]
    cmp rax, 1460
    je  .skipdivy
    ;this label is later
    mov rcx, 365
    xor rdx, rdx
    div rcx

;1460 days directly teleports here    
.skipdivn:    
    
    ;save remaining years and days
    mov [rbx+56], rax
    mov [rbx+64], rdx
    mov r9,       rax
    inc rax
    add rax,      [rbx+48]
    mov [r11],    rax

    ; Comments written for AI after being angered to death by AI
    ; tempyears = absolute year-1 - ((absolute year-1) mod 4)
    ; = current 4-year period start - 1 (not absolute year!)
    ; Example: 2000 -> 1996, 2001 -> 2000, 1900 -> 1896
    ; Purpose: compare tempyears with tempyears+4 /100, /400
    ;   equal -> no crossing; not equal -> crossed, continue checking 400
    ; Absolute year = tempyears + 1 + nbofovys (complete years already passed in current period)

    ;now check whether there is a century common year

    lea r10, [mthlep]
    lea rcx, [mthcom]
    ;In VS Code, hovering the cursor over it shows the comment above the label (plugin required)

    ; cmp    rax, 3
    cmp    r9,  3
    cmovne r10, rcx
    jne    .lepsub

    ;next we need to consider leap years
    mov rax, [rbx+48]
    mov r9,  rax
    ;copy rax first; r9 is the original tempyears of rax
    mov rcx, 100
    xor rdx, rdx
    div rcx
    mov r8,  rax
    ;save first result
    mov rax, r9
    add rax, 4
    xor rdx, rdx
    div rcx
    cmp rax, r8
    ;compare with first result
    ;here it is still the leap year table
    je  .lepsub
    ;not equal means there is a century year
    ;now check whether there is a 400-year leap year
    mov rcx, 400
    xor rdx, rdx
    mov rax, r9
    div rcx
    mov r8,  rax
    ;save first result
    xor rdx, rdx
    mov rax, r9
    add rax, 4
    div rcx
    cmp rax, r8
    ;compare; equal means it is not a 400-year leap, but a century common year

    lea   rcx, [mthcom]
    cmove r10, rcx

;code reuse here
;subtraction for calculating month
;this expects rax to equal the extra days, already initialized below

    .lepsub:
    mov rax, [rbx+64]
    xor rcx, rcx
    xor rsi, rsi

.leplop:
    inc   rcx
    ;Does anyone really remember that rsi has been zeroed? (Originally at the beginning)
    ;OK now changed to zero it in advance
    movzx rdx, byte [rbx+rsi]
    inc   rsi
    cmp   rax, rdx
    
    jb  .edlepsub
    sub rax, rdx
    jmp .leplop

.edlepsub:    
    ;rax=remaining days, rcx equals month
    inc rax
    ;this is the unfinished day, so add it
    mov [r11+16], rax
    mov [r11+8],  rcx

;At this point year, month, day are calculated; next are hour, minute, second  
    mov rax, [rbx+8]
    xor rdx, rdx
    mov rcx, 3600
    div rcx

    mov [r11+24], rax
    
    ;now give the remaining seconds in rdx to rax
    xchg rax, rdx
    xor  rdx, rdx
    mov  rcx, 60
    div  rcx

    mov [r11+32], rax
    mov [r11+40], rdx

    mov r8, [rbp+32]
    ;restore flags
    
    mov rax, [rbp+24]
    ;get subticks
    mov ecx, 10000
    xor edx, edx
    
    div rcx

    bt  r8, 1
    jnc .exit

    mov [r11+48], rax
    ;milliseconds

    bt  r8, 2
    jnc .exit
    
    mov rax, rdx
    xor edx, edx
    mov ecx, 10

    div rcx

    mov [r11+56], rax

.exit:

    mov rax, [rbp+16]

    pop rsi
    pop rbx
    pop rbp

    ret



    ;The real addresses in this part are deprecated

    ; [rbx + 128]  realus       
    ; [rbx + 120]  realms         
    ; [rbx + 112]  realseconds    
    ; [rbx + 104]  realminutes    
    ; [rbx + 96]   realhours      
    ; [rbx + 88]   realdays       
    ; [rbx + 80]   realmonth      
    ; [rbx + 72]   realyears

    ; r11 points to struct! 

    ; [rbx + 64]   overdays       
    ; [rbx + 56]   nbofovys       
    ; [rbx + 48]   tempyears      
    ; [rbx + 40]   tempdays       
    ; [rbx + 32]   nboffoys       
    ; [rbx + 24]   nbofohys       
    ; [rbx + 16]   nboffhys       
    ; [rbx + 8]    seconds        
    ; [rbx + 0]    days 



;1460-day special handling label
.skipdivy:
    mov rax, 3
    mov rdx, 365
    jmp .skipdivn

;Playing:《真昼の空の月》.mp3
;Didn't expect to remake this pile of crap today (October 4, 2026)
;Code recycling here

;null pointer returns directly
.null:
    xor rax, rax
    ret

































































;   Note: end of code section (I really can't stand that NASM has no end marker and I always get it wrong)

WARNING_SIGN:

section kpstdlib

A_UNAVAILABLE_SIGN:

ksignlabel:
;KUSSA(KUSSA_LTSC)
    jmp ksignlabel
    db 'KUSSA_LTSC'

;Content from another project:

    ;"We made a difficult decision":

        ;Starting September 6, 2026, this teaching demo no longer follows the GPL and switches to KUDOS
        ;Versions previously released under GPL are not affected
        ;Because it needs to use closed-source libraries or source-available libraries, which do not meet GPL requirements

    ;September 6, 2026

;What you must know:

    ;It does not use an open source license, only source-available
    ;If you are a student and study assembly for a hobby unrelated to work, you can freely research and learn
    ;This code is free; don't sell it for money
    ;If you paid to obtain it, you were cheated out of a little money
    ;Free link: https://github.com/KUSSA-LTSC/KUDOS-kpstdlib/

;September 11, 2026

; What you must know:
;
; It is not an open source license, only source-available.
; This is not an OSI open source license.
;
; This code is free; don't sell it for money.
; If you paid to obtain it, you were cheated.
; Free link: https://github.com/KUSSA-LTSC/KUDOS-kpstdlib/
;
; Individuals may study assembly for hobby, private, non-commercial purposes.
; Students may learn, but only for personal private study, or in accordance with the license-defined
; "permitted educational uses": public free courses on mainstream online platforms.
;
; It is prohibited to share source code, modified versions, or binary files with friends, classmates, colleagues,
; students, other departments, subsidiaries, or any third party.
; Research collaboration, peer review, and paper publication are carried out under Section 1.4 of the license.
;
; Configuration files may be public, but must not contain source code, scripts, binaries,
; executable logic, or any material that can reconstruct the software.
;
; Commercial use, use by for-profit entities, evaluation, testing, bundling, AI training,
; all require prior written consent on paper from the project owner.
;
;September 12, 2026

; Damn, I'm going to die of exhaustion

;September 13, 2026

; Is high school hell? Today is the 918 memorial day

;September 18, 2026

; Happy Mid-Autumn Festival
; Happy my ass, spending it with homework
; That bloated filetime_to_realtime, I will rewrite it sooner or later

; I'm really dying of exhaustion
; This bloated thing still has a bunch of unfinished stuff
; Even a bunch of instruction sets

; Technically there is a pile of technical debt
; Functionally there are a bunch of unfinished things
; Comments are still missing a huge amount; AI-written comments are crap, not like human-written ones

; Still, 廣井きくり is my favorite one

;September 24, 2026

; Getting old is really useless; today I only wrote 02 functions
; The last day of September
; How can homework be used as a stool?

;September 30, 2026

; Today is October 1st, National Day

; On this happy day, I sincerely wish my motherland a happy birthday.
; On this happy day, I sincerely wish my motherland a happy birthday.

; Wrote a lot today, such as the AVX2 version of strlen

; Code broke 2000 lines, but most of it is comments, haha~

;October 1, 2026

; I hate string formatting
; I'm really done with this annoying thing
; Homework, I can't finish it

;October 2, 2026

; Added some comments, and because I feel unwell I don't want to do homework

;October 3, 2026

; Major update: I rewrote that pile of crap filetime_to_realtime (yay)
; But I only rewrote the calculation part, and changed some behavior, so I gave this remade function a new label
; Fixed many unknown issues

;October 4, 2026

;That's the end, that's all~
