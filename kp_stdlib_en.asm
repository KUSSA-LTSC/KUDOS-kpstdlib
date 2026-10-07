; ============================================================
; AI TRANSLATION NOTICE
; This file was translated by an AI from Simplified Chinese to American English.
; All code, identifiers, symbol names, API names, file names, and string literals
; remain unchanged unless they were Chinese comments.
; ============================================================

;kpstdlib.asm

;KUSSA_LTSC 2026 All rights reserved

;Legacy notice retained:

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-scancode-kudos-sal-2.5

;KUSSA's standard library
;Source-available, for free educational research and study only
;Comments will be added later.

;What this is: a NASM project (obviously)
;What it's for: for writing C code
;Why are you looking at it: none of my business
;Can you learn from it: yes, but I haven't finished the comments
;It may not be as exemplary as other online tutorials
;It leans toward the old-style 8086-era way of writing
;Decisions and tradeoffs were made for the x86-64 instruction set
;There are far fewer restrictions than on 8086
;Is this a beginner version: no. I suggest you learn another language first or read other assembly tutorials first
;Is this a beginner version: yes. Here you can encounter most of the places where beginners easily make mistakes and get confused
;What can you learn from it: a lot, depends on how you study
;Is it standardized: in terms of calling convention, it basically conforms to the Microsoft x64 ABI
;But its style may be rather bizarre
;What if you can't understand it: don't read it, or go ask AI
;Is it completely handwritten: yes. I may have had AI help check some parameters, for example I once typoed GetFileSizeEx as GetFileSizeEX
;I often have AI help me look at compile and link errors, and help query the Intel SDM PDF
;Is it easy to use: not necessarily, but except for the win32api wrappers, it returns NULL to indicate failure
;NULL is a constant equal to zero
;How updates are decided: I write whatever I need
;(In fact, a month has passed and I still haven't finished the functions needed for my logging feature
;Can it replace the CRT: it can do quite a lot now, but it still cannot fully replace it
;Why wrap system APIs: because it may not be compatible with windows.h, to help me remember better, to make maintenance and porting easier, and to make writing programs more convenient
;Also, why should you learn assembly: it lets you better understand how code works and solve many bizarre bugs
;But learning assembly is not easy for most people
;I am the exception. Instead, I always have problems writing C code and don't know how to fix bugs
;Will its performance be better than the CRT: no, about the same. Some aggressive functions may be a tiny bit faster
;In short, you need some programming foundation, and you need patience to understand 8086 or x86 instructions to understand most of it. Comments are not a babysitter; they only write the most important and error-prone parts
;Warning: internal functions and unfinished functions must never be exported, and should not be modified. They are only for code reuse convenience, for business services in specific scenarios

;bash:

;nasm -f win64 .\kpstdlib.asm -o .\kpstdlib.obj 
;gcc -o test.exe test.c kpstdlib.obj -nostdlib -lkernel32 -luser32 -mwindows -e main -ffreestanding -fno-stack-protector -fno-asynchronous-unwind-tables -O2

;New notice:

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
; Full terms are in the project root:
; KUDOS SOURCE AVAILABLE LICENSE.txt
;
; Without prior written paper consent from the project owner, the following are prohibited:
; - Commercial use, use by for-profit entities, or evaluation or testing by for-profit entities;
; - Distributing, publishing, uploading, or sharing this software or modified versions with any third party;
; - Combining, linking, or distributing together with commercially related bundles;
; - Using this software to train, fine-tune, distill, or evaluate any AI or machine learning model.
;
; Permitted uses are only those explicitly specified by the license:
; - Personal private study;
; - Internal administrative use of the original unmodified software by non-profit organizations;
; - Public free courses on mainstream online platforms;
; - Non-commercial research, peer review, and paper publication under Section 1.4.
;
; Configuration files may be publicly shared if they do not contain source code, scripts, binaries, or executable logic.

;About the license:

; This is a license leaning toward education and rejecting commercialization
; It is not an open source license, but it can better facilitate my future use of other people's closed-source libraries
; Of course, if there is an opportunity later, and when it can independently implement all functions except system functions, the library license will likely revert to GPLv3

;Of course, it is very hard to implement all functions without depending on third-party or closed-source libraries. I cannot learn everything

;...Code below...

; %include 'third.inc'
%include 'kmarco.inc'

;Macro expansions are placed here, don't ask me again!
;They are from the macro file at the beginning; I wrote them myself
;Don't worry about these two lines; it's okay if you don't understand them
;The default stack alignment of 16 is handled automatically

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

;The project start date cannot be traced, but it can be confirmed to be on or before August 26, 2026

;Although it is also for teaching and performance doesn't need to be too good, I still want to pursue perfection a bit
;For easier debugging and writing, use r64 for all registers unless unnecessary
;Labels are written randomly because my English is bad

; bu, date, dlsbur, dust, wasteimm are global static buffers.
; Functions that use these addresses absolutely, absolutely, absolutely must not be called concurrently in multiple threads!

; I do not recommend using the AVX2 version; its performance is usually worse than the SSE2 version

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
global  kp_win32api_get_last_error_fastcall_win64
global  kp_improved_prtnum_frmrcx_fastcall_win64
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
global  kp_u64_hex2ascii_fastcall_win64
global  kp_strend_wthrnl_fastcall_win64
global  kp_strcpy_enddls_fastcall_win64
global  kp_prtnum_frmrcx_fastcall_win64
global  kp_ssse3_strchr_fastcall_win64
global  kp_avx2_strlen_fastcall_win64
global  kp_sse2_strlen_fastcall_win64
global  kp_simd_strlen_fastcall_win64
global  kp_sse2_strcpy_fastcall_win64
global  kp_sse_strlen_fastcall_win64
global  kp_hex2ascii_fastcall_win64
global  kp_ascii2hex_fastcall_win64
global  kp_timefmt_fastcall_win64
global  kp_stredy_fastcall_win64
global  kp_strcpy_fastcall_win64
global  kp_strend_fastcall_win64
global  kp_strled_fastcall_win64
global  kp_strlen_fastcall_win64
global  kp_strchr_fastcall_win64
global  kp_ermsb_fastcall_win64

global  kp_win32api_get_module_handle_w_fastcall_win64
global  kp_win32api_get_console_window_fastcall_win64
global  kp_win32api_get_foreground_window_fastcall_win64
global  kp_win32api_find_window_w_fastcall_win64
global  kp_win32api_get_std_handle_fastcall_win64
global  kp_win32api_alloc_console_fastcall_win64

global  kp_avx2_strcpy_fastcall_win64

;======WIN32API======

extern  ReadFile
extern  WriteFile
extern  ExitProcess
extern  CloseHandle
extern  CreateFileW
extern  MessageBoxW
extern  VirtualFree
extern  FindWindowW
extern  AllocConsole
extern  GetLastError
extern  VirtualAlloc
extern  GetStdHandle
extern  FindWindowExW
extern  GetFileSizeEx
extern  GetConsoleWindow
extern  GetModuleHandleW
extern  SetFilePointerEx
extern  GetForegroundWindow
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
    tempyears   dq 0 ;temporary year count
    tempdays    dq 0 ;temporary day count
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
   ;FileTime subtraction value to disable Beijing time
    unboeg equ UTC8_OFFSET*10000000
    ;Year constant with Beijing time offset added
    boeg   equ aoeg+UTC8_OFFSET
    
    ;Placeholder junk
    dust times 128 db 0

    ;Month table
    mthcom             db  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    mthlep             db  31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    ;Time constants
    seconds_per_day    equ 86400
    days_per_4_years   equ 1461
    days_per_100_years equ 36524
    days_per_400_years equ 146097
    ;Newly added $ replacement buffer
    dlsbur:
        times 8 db 0
    dlsbur_end:
    
    dlsbur_len equ (dlsbur_end-dlsbur)

    align 16
    ;Crazy hex2ascii table
    hex2ascii_xlatable db '0123456789ABCDEF'

    align 16
    ;Crazy ascii2hex table
    ascii2hex_xlatable:
    times 48  db 0                       ; 0x00-0x2F illegal area
    db           0,1,2,3,4,5,6,7,8,9     ; 0x30-0x39  '0'-'9'
    times 7   db 0                       ; 0x3A-0x40  between '9' and 'A'
    db           0xA,0xB,0xC,0xD,0xE,0xF ; 0x41-0x46  'A'-'F'
    times 26  db 0                       ; 0x47-0x60  between 'F' and 'a'
    db           0xA,0xB,0xC,0xD,0xE,0xF ; 0x61-0x66  'a'-'f'
    times 153 db 0                       ; 0x67-0xFF illegal area


; Mysterious constants, extracted from windows.inc

; ==================== General ====================
; Empty content, null pointer
NULL                  equ 0
; True
TRUE                  equ 1
; False
FALSE                 equ 0
; Default window position, let the system choose
CW_USEDEFAULT         equ 0x80000000
; Infinite wait
INFINITE              equ 0xFFFFFFFF

; ==================== Window class styles ====================
; Redraw when window height changes
CS_VREDRAW            equ 0x0001
; Redraw when window width changes
CS_HREDRAW            equ 0x0002

; ==================== Window styles ====================
; Overlapped window (default, borderless)
WS_OVERLAPPED         equ 0x00000000
; Popup window
WS_POPUP              equ 0x80000000
; Child window
WS_CHILD              equ 0x40000000
; Window visible
WS_VISIBLE            equ 0x10000000
; Has title bar
WS_CAPTION            equ 0x00C00000
; Has border
WS_BORDER             equ 0x00800000
; Has system menu (top-left icon)
WS_SYSMENU            equ 0x00080000
; Resizable border
WS_THICKFRAME         equ 0x00040000
; Has minimize button
WS_MINIMIZEBOX        equ 0x00020000
; Has maximize button
WS_MAXIMIZEBOX        equ 0x00010000
; Standard overlapped window: title bar + system menu + resizable + minimize + maximize
WS_OVERLAPPEDWINDOW   equ WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX

; ==================== ShowWindow ====================
; Hide window
SW_HIDE               equ 0
; Normal display
SW_SHOWNORMAL         equ 1
; Minimized display
SW_SHOWMINIMIZED      equ 2
; Maximized display
SW_SHOWMAXIMIZED      equ 3
; Show according to most recent state
SW_SHOW               equ 5
; Restore from minimized/maximized
SW_RESTORE            equ 9

; ==================== Window messages ====================
; Window creation
WM_CREATE             equ 0x0001
; Window destruction
WM_DESTROY            equ 0x0002
; Window size changed
WM_SIZE               equ 0x0005
; Needs repaint
WM_PAINT              equ 0x000F
; Close request
WM_CLOSE              equ 0x0010
; Exit message loop
WM_QUIT               equ 0x0012
; Key down
WM_KEYDOWN            equ 0x0100
; Key up
WM_KEYUP              equ 0x0101
; Character input
WM_CHAR               equ 0x0102
; Menu/control command
WM_COMMAND            equ 0x0111
; Timer triggered
WM_TIMER              equ 0x0113
; Mouse move
WM_MOUSEMOVE          equ 0x0200
; Left button down
WM_LBUTTONDOWN        equ 0x0201
; Left button up
WM_LBUTTONUP          equ 0x0202
; Right button down
WM_RBUTTONDOWN        equ 0x0204
; Right button up
WM_RBUTTONUP          equ 0x0205

; ==================== Message box ====================
; Only an "OK" button
MB_OK                 equ 0x00000000
; "OK" + "Cancel"
MB_OKCANCEL           equ 0x00000001
; "Yes" + "No"
MB_YESNO              equ 0x00000004
; Error icon
MB_ICONERROR          equ 0x00000010
; Question icon
MB_ICONQUESTION       equ 0x00000020
; Warning icon
MB_ICONWARNING        equ 0x00000030
; Information icon
MB_ICONINFORMATION    equ 0x00000040

; ==================== Message box return values ====================
; User clicked "OK"
IDOK                  equ 1
; User clicked "Cancel"
IDCANCEL              equ 2
; User clicked "Yes"
IDYES                 equ 6
; User clicked "No"
IDNO                  equ 7

; ==================== System resources ====================
; Standard arrow cursor
IDC_ARROW             equ 32512
; Standard application icon
IDI_APPLICATION       equ 32512

; ==================== Colors ====================
; Window background color (white)
COLOR_WINDOW          equ 5
; Button face color (gray)
COLOR_BTNFACE         equ 15

; ==================== Memory ====================
; Commit: allocate physical storage
MEM_COMMIT            equ 0x1000
; Reserve: only occupy address space, do not allocate physical storage
MEM_RESERVE           equ 0x2000
; Decommit, keep address
MEM_DECOMMIT          equ 0x4000
; Fully release (address + storage)
MEM_RELEASE           equ 0x8000
; No access
PAGE_NOACCESS         equ 0x01
; Read/write
PAGE_READWRITE        equ 0x04

; ==================== File ====================
; Read permission
GENERIC_READ          equ 0x80000000
; Write permission
GENERIC_WRITE         equ 0x40000000
; Create new file, fail if already exists
CREATE_NEW            equ 1
; Always create, overwrite if exists
CREATE_ALWAYS         equ 2
; Open existing file only
OPEN_EXISTING         equ 3
; Open existing; create if not exists
OPEN_ALWAYS           equ 4
; Open existing and truncate
TRUNCATE_EXISTING     equ 5
; Normal file attributes
FILE_ATTRIBUTE_NORMAL equ 0x80
; Invalid handle (API failure return value)
INVALID_HANDLE_VALUE  equ -1
; Start from file beginning
FILE_BEGIN            equ 0
; Start from current position
FILE_CURRENT          equ 1
; Start from end of file
FILE_END              equ 2
; Allow other processes to read
FILE_SHARE_READ       equ 1
; Allow other processes to write
FILE_SHARE_WRITE      equ 2
; Allow other processes to delete
FILE_SHARE_DELETE     equ 4
; Standard input handle
STD_INPUT_HANDLE      equ -10
; Standard output handle
STD_OUTPUT_HANDLE     equ -11
; Standard error handle
STD_ERROR_HANDLE      equ -12


;Code section
section .text

;First function?
;A very old-fashioned way of writing, there are 4 SIMD examples later
;Warning: this early function uses 8086-style writing and usually preserves all registers by default. Yes, all of them except the return value. If you modify this function, then all functions after it that use it may have their registers clobbered. You need to check them one by one. I suggest not modifying it
;However, this one clobbers rcx and does not check for null pointers
kp_strlen_fastcall_win64:
;Only one parameter: rcx holds the string start; returns rax in bytes
    xor  rax, rax
    ;rax=0 is used to search for \0
    push rdi
    mov  rdi, rcx
    mov  rcx, -1

    cld;Clear direction flag

    repne scasb;Repeat; if not equal, continue scanning and comparing al with [rdi]
    test rcx, rcx
    ;This is a pure 8086 aftereffect. If rcx=0, it means either not found or it landed exactly there, but x64 registers are very large, so there is no special handling
    jz   .nofind
    not  rcx      ;Invert
    dec  rcx      ;Subtract one
    ;This gets the length; the principle is due to binary properties
    mov  rax, rcx
    pop  rdi
    ret
;Simple comments like this are mostly gone later; usually only forgetful and error-prone comments remain
.nofind:
    xor rax, rax
.ret:
    pop rdi
    ret

;Deprecated, kept here purely for archival purposes, with a stack diagram attached
;8086-era function, used back then to batch-output numeric strings, but I found it doesn't work well on x64
;! Warning: unfinished function, absolutely do not use!
kp_prtnum_frmstk_wthrcx_rep_fastcall_win64:
;Subroutine, assumed already aligned, and no register parameters are passed
;Currently the feature of passing parameters in RAX has not been implemented
;If rcx is 0, it means there are no numbers; exit directly
    or   rcx, rcx ;.....[STACK].....
    jz   .exit    ;NUM2       RBP+56
    push rbp      ;NUM1       RBP+48
    mov  rbp, rsp ;SHADOW 4
    push rsi      ;SHADOW 3
    push rcx      ;SHADOW 2
    push rax      ;SHADOW 1
    push rbx      ;RET        RBP+8
    push rdx      ;RBP    0   RBP+0
    push rdi      ;RBP points to original RBP's PUSH
;Save all used
    ;PREPROCE

    xor rsi, rsi
    xor rdi, rdi

;Overall loop conversion output
.lb_tltp:

    mov rax, [rbp+rsi+48] ;Read number from stack
;Newly added negative check
    ; test rax, 0x8000000000000000
    ; Well, x64 cannot directly write 64-bit imm except with mov
    ; jz   .np
;Changed to a shorter way
    or  rax, rax
    jns .isnotnegative
;If not negative, skip
    mov byte [bu], 45 ;ASCII for negative sign
    inc rdi
;Convert negative to positive
    neg rax
;Label: not negative
.isnotnegative:
    mov  rbx, 10
    push rcx
    xor  rcx, rcx
;Division loop; divide by 10 each time to get the units digit
.divlop:
    inc  rcx      ;STACK
    xor  rdx, rdx ;ori_rcx,rcx*rdx
    div  rbx
    push rdx
    or   rax, rax
    jz   .preprt

    jmp .divlop
;Prepare to print
.preprt:

    lea rbx, [bu]
;Print loop (actually writing to memory)
.lre:

    pop rdx
    add rdx,       48
    ;Convert to ASCII and write
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .lre

;Here rdx will all be popped; rsp points to ori_rcx

    ; inc rdi
    mov byte [rbx+rdi], 0
    ;Append 0 at the end

;Here it should call output bu, but it hasn't been done yet

;Initialize for the next loop

    xor rdi, rdi
    add rsi, 8
    pop rcx

    dec rcx
    jnz .lb_tltp

    

;rcx=0, rsp points to ori_rdi

    pop rdi
    pop rdx
    pop rbx
    pop rax
    pop rcx
    pop rsi
    pop rbp

;Technically AX should be left for the return value, but actually I'm too lazy

.exit:
    ret


;Pending agenda, parameters, for example RAX can indicate whether signed is enabled, whether address writeback is enabled; if enabled, address defaults to starting at RBX. I also don't know whether 64-bit has a text command that can write across directly. I remember I could directly set direction, spacing, and then place text
;There is no pending agenda now; this function is deprecated. It is x64 now, not 8086
;Once again, this function is deprecated. Just treat it as an ad (October 3, 2026)

;Internal function, C cannot use it directly; ported from 8086 code
;Print rax alone, for logging; should not clobber any registers
;Clobbers RAX as return
kp_prtnum_frmrax:
;Assume rax is already assigned
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;Check negative
    jns  .isnotnegative ;If not negative, skip
    mov  byte [bu], 45  ;ASCII for negative sign
    
    inc rdi
    neg rax ;Convert negative to positive

;If not negative, go here
.isnotnegative:
    push rsi
    push rcx
    push rdx
    push rbx
    mov  rbx, 10
    xor  rcx, rcx
;Division loop
.divlop:
    inc  rcx
    xor  rdx, rdx
    div  rbx
    push rdx
    or   rax, rax
    jz   .preprt
    jmp  .divlop
;Print preparation
.preprt:
    lea rbx, [bu]
    ;Print to bu first; load address here
;Write digits loop
.loopofrewrite:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .loopofrewrite

    ; inc rdi ; This inc must not be written
    mov byte [rbx+rdi], 0

    lea rax, [bu]
    ;Return address

    pop rbx
    pop rdx
    pop rcx
    pop rsi
    pop rdi

    ret

;Calculate date, return year, month, day, hour, minute, second from parameter 3 to parameter 8 (why is this here?)
;(This line of comment is clearly written at the beginning of kp_filetime_to_realtime_frmrax_ret_fastcall_win64)
;(Actually forgotten to delete when moving; treat it as an Easter egg) (October 3, 2026)

;Print rcx alone; now C code can use it
;Filler function, haha, this is the shortest one
kp_prtnum_frmrcx_fastcall_win64:
    mov rax, rcx
    jmp kp_prtnum_frmrax

;Text copy with checks (actually useless checks)
;rcx holds source pointer, rdx holds source length, r8 holds destination pointer, r9 holds destination length, all in bytes
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
    ;It doesn't clobber registers so it can be used directly, but if using later SIMD versions it may clobber registers, so save them
    mov  rdx, rax                 ;Return value is in rax, calling convention

    pop rcx

.havesrclen:

    cmp rdx, r9
    jae .mgd
    ;If source is longer than destination, exit
    ;No longer check whether rcx is 0 because 0 is fine
    ; push rbp
    ; mov  rbp, rsp
    ; Stack frame is no longer needed now

    cld

    push rsi
    push rdi

    mov rsi, rcx ;Source
    mov rdi, r8  ;Destination
    cmp rdx, 15  ;Branch for different lengths
    ja  .msq
    mov rcx, rdx
    rep movsb

    mov byte [rdi], 0

    jmp .normal

.msq:
    mov rcx, rdx
    shr rcx, 3
    rep movsq;On old CPUs movsq is faster than movsb, but actually all x64 CPUs have SSE2
    mov rcx, rdx
    and rcx, 7
    rep movsb

    mov byte [rdi], 0 ;Append 0 at the end
    
.normal:
    ; sub rdi, r8
    ; mov rax, rdi
    ; This commented-out code returns length, meaningless, equals srclen
    mov rax, rdi
    ;Return pointer
    pop rdi
    pop rsi
    ret

.mgd:
    xor rax, rax ;0 means failure, or length is 0
    ; mov rsp, rbp
    ; pop rbp
    ret

db '少羽牛逼' ;This is a signature, i.e., a feature. These 4 characters will be put unchanged into the exe. Later, to check this function, just search for the feature in x64dbg and it will locate here

;Input rcx; can use system-provided time GetSystemTimeAsFileTime
;Parameters: rcx holds time provided by the system; 1 address is used to return compact plain-text time
;Example: 20260905220631_134330908XXXXXXXXX\0
;The remaining 6 addresses are memory pointers for year, month, day, hour, minute, second respectively
;void(imm64,immmem64ptr,mem64addr*6)
kp_filetime_to_realtime_frmrax_ret_fastcall_win64:
;The design was problematic at the time. It only considered Beijing time and did not consider making it a UTC offset in one go
;And at the time I didn't consider structs either, so it was very messy
;If you pass a null pointer, the program won't crash, it just won't return anything. Yes, I didn't consider return values back then because they weren't needed, or rather I never thought it could fail
;This is the largest function in the project, all I can say

; ...STACK_TABLE...
; P8 seconds    RBP+72
; P7 minutes    RBP+64
; P6 hours      RBP+56
; P5 day        RBP+48
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
    mov  rbp, rsp ;Used later to get parameters
    push rbx
    push rsi
    push rdi
    push r15

    ; xor rsi, rsi
    ; mov rdi, 7
    ;If unrolled, these two lines are not needed

;Check null pointers. Although unrolling has better performance, well, let's unroll it then
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
    ;All parameters have been saved; the first 4 are in shadow space
    mov rax,      rcx

    xor rbx, rbx ;I forgot what this line is for. Actually useless (yes, useless, kept as an Easter egg) (October 3, 2026)
    
    ;Modified, but behavior is basically unchanged
    ;Make it return correctly even when ft=0
    mov r10, unboeg
    add rax, r10

    ;First convert to seconds
    mov rcx, 10000000
    xor rdx, rdx
    div rcx
    mov rcx, aoeg
    add rax, rcx
    xor rdx, rdx
    ;Now rax is total seconds
    mov rcx, seconds_per_day
    div rcx
    
    ;rax=days, rdx=remaining seconds
    ;If you don't understand, go check the SDM
    mov [days],     rax
    mov [seconds],  rdx
    mov rcx,        days_per_400_years ;First calculate how many complete 400-year periods
    xor rdx,        rdx
    div rcx
    mov [nboffhys], rax
    mov rax,        rdx
    mov rcx,        days_per_100_years ;Continue dividing by 100 years
    xor rdx,        rdx
    div rcx
    mov [nbofohys], rax
    mov rax,        rdx
    mov rcx,        days_per_4_years   ;Calculate how many 4-year periods
    xor rdx,        rdx
    div rcx
    mov [nboffoys], rax
    mov [tempdays], rdx
    ;Remaining days
    
    imul rax,[nboffhys],400
    mov [tempyears], rax
    imul rax,[nbofohys],100
    add [tempyears], rax
    imul rax,[nboffoys],4
    add [tempyears], rax
    ;Now everything except the less-than-4-years part has been calculated

;First compare whether leap year handling is needed
    mov rax, [tempdays]
    cmp rax, 1460
    je  .skipdivy
    ;This label is later
    mov rcx, 365
    xor rdx, rdx
    div rcx

;For 1460 days, portal directly here    
.skipdivn:    
    
    ;Save remaining years and days
    mov [nbofovys],  rax
    mov [overdays],  rdx
    mov r9,          rax
    inc rax
    add rax,         [tempyears]
    mov [realyears], rax
    ; mov rax,         r9

    ; Comments written for AI because AI pissed me off
    ; tempyears = absolute year-1 - ((absolute year-1) mod 4)
    ; = start of current 4-year cycle - 1 (not absolute year!)
    ; Example: 2000 -> 1996, 2001 -> 2000, 1900 -> 1896
    ; Purpose: compare tempyears and tempyears+4 for /100 and /400
    ;   equal -> no boundary crossed; not equal -> boundary crossed, continue checking 400
    ; Absolute year = tempyears + 1 + nbofovys (complete years already passed in current cycle)

    ;Now calculate whether there is a century common year

    lea rbx, [mthlep]
    lea rcx, [mthcom]
    ;In VS Code, hover the cursor to see the comment above a label (requires an extension)

    ; cmp    rax, 3
    cmp    r9,  3
    cmovne rbx, rcx
    jne    .lepsub

    ;Now the remaining part needs to consider leap years
    mov   rax, [tempyears]
    mov   r9,  rax
    ;First copy rax; r9 is the original tempyears of rax
    mov   rcx, 100
    xor   rdx, rdx
    div   rcx
    mov   r8,  rax
    ;Save first result
    mov   rax, r9
    add   rax, 4
    xor   rdx, rdx
    div   rcx
    cmp   rax, r8
    ;Compare with first result
    ;Here it is still the leap year table
    je    .lepsub
    ;Not equal means there is a century year
    ;Now check whether there is a 400-year leap year
    mov   rcx, 400
    xor   rdx, rdx
    mov   rax, r9
    div   rcx
    mov   r8,  rax
    ;Save first result
    xor   rdx, rdx
    mov   rax, r9
    add   rax, 4
    div   rcx
    cmp   rax, r8
    ;Compare; equal means it is not a 400-year leap, but a century common year
    lea   rbx, [mthlep]
    lea   rcx, [mthcom]
    cmove rbx, rcx

;Code reuse part
;Month subtraction calculation
;This expects rax to equal the extra days, initialized below

.lepsub:
    mov rax, [overdays]
    xor rcx, rcx
    xor rsi, rsi

.leplop:
    inc   rcx
    ;Does anyone really remember that rsi has been zeroed? (Originally at the beginning)
    ;OK, now changed to zero it in advance
    movzx rdx, byte [rbx+rsi]
    inc   rsi
    cmp   rax, rdx
    ; jge   .lepsub
    jb    .edlepsub
    sub   rax, rdx
    jmp   .leplop

.edlepsub:    
    ;rax=remaining days, rcx=month
    inc rax
    ;This is the incomplete day, so add it
    mov [realdays],  rax
    mov [realmonth], rcx

;At this point year, month, and day are calculated; next are hour, minute, second  
    mov rax, [seconds]
    xor rdx, rdx
    mov rcx, 3600
    div rcx

    mov [realhours], rax
    
    ;Now give the remaining seconds in rdx to rax
    xchg rax, rdx
    xor  rdx, rdx
    mov  rcx, 60
    div  rcx

    mov [realminutes], rax
    mov [realseconds], rdx

;Now output return value

    lea rbx, [date] ;Currently output here by default

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
    ;Calculate remaining length and put it in r9
    mov  rax, [r15+rsi]
    call kp_prtnum_frmrax_intime
    call kp_strcpy_enddls_fastcall_win64
    ;This function returns rax as the end address
    add  rsi, 8
    dec  rdi
    jnz  .reprtlop
    ;In the 8086 era I was still used to loops to compress code, but now theoretically unrolling gives better performance

;Now the time has been concatenated

    lea rcx, [bu]
    mov rdx, -1
    mov r8,  rax
    sub rax, rbx
    mov r9,  datelen
    sub r9,  rax
    ;Calculate remaining length and put it in r9

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
    ;Calculate remaining length and put it in r9
    mov  rax,  [rbp+16]
    ;Now rax is filetime
    call kp_prtnum_frmrax
    call kp_strcpy_enddls_fastcall_win64
    
;Newly added $ rewriting
    mov rcx, 0x007D3B3A3A5F2D2D
    ;equals ('--_::;}',0)
    ;Little-endian must be written reversed
    ;Small update, now has a } ending

    mov [dlsbur], rcx ;This is a parameter for another function's business

;r9 length must be provided manually
    lea  rcx, [date]
    call kp_strlen_fastcall_win64
    mov  r9, rax

    lea rcx, [dlsbur]
    mov rdx, -1
    lea r8,  [date]

    call kp_replace_single_dollar_symbol_wthcnt_fastcall_win64
    ;I think it shouldn't fail, and there's nothing worth checking

    mov rcx,   [rbp+24]
    lea rdx,   [date]
    mov [rcx], rdx
    ;Text date has been written back

    xor rsi, rsi
    mov rdi, 6

.reback:

    mov rcx,   [rbp+rsi+32]
    mov rdx,   [r15+rsi]
    mov [rcx], rdx
    add rsi,   8
    dec rdi
    jnz .reback

;Return process

;Null pointer return
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

db 'This_is_a_sentence.' ;Still a marker

;Damn, I finally finished this thing. The date function took me three weeks    
;Calculate date, return year, month, day, hour, minute, second from parameter 3 to parameter 8
;This thing tortured me for three weeks (ended September 13, 2026)

;Text copy with checks (actually useless checks)
;The only difference from strcpy is
;The ending is '$\0'
;rcx holds source pointer, rdx holds source length, r8 holds destination pointer, r9 holds destination length, all in bytes
;Returns pointer to trailing 0; if rdx is negative, calculate automatically
kp_strcpy_enddls_fastcall_win64:
    
    test rcx, rcx
    jz   .mgd
    test r8,  r8
    jz   .mgd
    test r9,  r9
    jz   .mgd
    ;They say there are null pointers
    test rdx, rdx
    jns  .busu
    push rcx
    call kp_strlen_fastcall_win64 ;Do not casually replace with another strlen, otherwise you need to save registers
    mov  rdx, rax
    pop  rcx
.busu:   
    lea r10, [rdx+1] ;Check required size
    cmp r10, r9
    jae .mgd
    ;If source is longer than destination, exit
    ;No longer check whether rcx is 0 because 0 is fine
    ; push rbp
    ; mov  rbp, rsp
    ; No longer needed now

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

    ; mov byte [rdi], 0 ; This is left over from strcpy, changed to the following
    ; mov ah,    0
    ; mov al,    ('$')
    mov ax,    0x0024
    ;Write $\0 at once
    mov [rdi], ax
    inc rdi
    ;Now rdi points to \0

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
    ;Return pointer
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
;Source ends with 0; if source length is negative, calculate automatically
;Source length is also the number of symbol replacements (equivalent)
;Does not return a pointer; returns as bool, non-fixed value
;Not thread-safe
kp_replace_single_dollar_symbol_wthcnt_fastcall_win64:
    push rbp
    mov  rbp, rsp
    push rsi
    push rdi
    
    test rcx, rcx
    jz   .error

    test r9, r9
    jz   .error
    ;If destination length is 0, what else is there to say

    test rdx, rdx
    jz   .error
    jns  .havelen
    mov  r10, rcx
    ;Back up rcx
    call kp_strlen_fastcall_win64
    cmp  rax, dlsbur_len
    ja   .error
    mov  rdx, rax
    mov  rcx, r10
    ;Restore rcx

.havelen:
    cmp rdx, 8
    ja  .error
    ;Modified; now at most 8 replacements because that's all the buffer I gave
    ;September 24, 2026
    mov rsi, rcx
    ;Now rsi points to source
    mov rdi, r8
    mov rcx, r9
    ;Now rcx is the length

.replop:    
    mov al, ('$')
    mov ah, [rsi]

    cld
    repne scasb;Scan
    jne .exit ;This executes only when rcx=0 or found. If the flag is not equal, it means not found. Because length is set, it won't overrun

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


;Internal function, only for date functionality    
;Clobbers RAX as return value
kp_prtnum_frmrax_intime:
;Assume rax is already assigned
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;Check negative
    jns  .np            ;If not negative, skip
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
    ;Print to bu first
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
;If rsi is not 0, keep 2 digits
    ; mov  rsi,   [rbp+32]
    test rsi,   rsi
    jz   .sk
    mov  ax,    [rbx]
    test ah,    ah
    jnz  .sk
    xchg ah,    al
    ;Swap one digit and '0'
    mov  al,    ('0')
    mov  [rbx], ax
    xor  rax,   rax

    mov [rbx+2], al
    ;Append 0 at the end

.sk:

    lea rax, [bu]
    ;Return address

    pop rbx
    pop rdx
    pop rcx
    ; pop rsi
    pop rdi
    ret

;Append string at end, 4 parameters
;(source, source length, destination start, destination buffer length)
;If source length is negative, calculate automatically
;Returns trailing \0 pointer, failure returns 0
kp_strend_fastcall_win64:

    ;Check null pointers and zero length
    test rcx, rcx
    jz   .nullet
    test r8,  r8
    jz   .nullet
    test r9,  r9
    jz   .nullet
    test rdx, rdx
    jz   .nullet

    ;Main part begins

    mov r10, rcx ; Back up source pointer
    mov rcx, r8  ; rcx = dst, for internal strlen
    
    call kp_strlenled_inside
    ; Returns: rax = destination trailing \0 pointer, rcx = destination current length

    sub rcx, r9 ; current length - total capacity
    neg rcx     ; negate to get remaining space
    js  .nullet ; if negative, destination is full, just leave

    mov r9,  rcx
    mov rcx, r10

;Mysterious label
.noauto:   

    ;Now can start copying string
    
    mov r8, rax ; r8 = address of destination's trailing \0
    
    call kp_strcpy_fastcall_win64
    
    ret

;Null pointer and insufficient length exit
.nullet:
    xor rax, rax
    ret

;String end
;Only one parameter: rcx holds string start; returns rax pointing to \0, failure returns 0
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

;Internal function, only for internal use
;Clobbers rax, rcx; returns length and end respectively
kp_strlenled_inside:
;Only one parameter: rcx holds string start; returns rax pointing to \0, rcx returns length, failure returns 0 for both
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
;int(src,srclen,dst,dstlen), all units in bytes
;No checks; directly use API return value * 2
;If what you pass is strlen without \0, you need to append 0 yourself at the end
;I suggest filling length with -1
kp_win32api_ezutf8t16le_fastcall_win64:
    
    adod

    shr  r9,  1
    push r9
    push r8
    sub  rsp, 32
    ;Shadow space
    mov  r9,  rdx
    mov  r8,  rcx
    mov  rcx, 65001
    xor  rdx, rdx

    call MultiByteToWideChar

    shl rax, 1

    pdod

    ret

;Short input version of time function; again, originally didn't consider return values
;void(filetime, quick string address, struct address start, disable Beijing time
;About disabling Beijing time (if 0, ignore; if non-zero, give UTC time)
kp_timefmt_fastcall_win64:    

    adod

    test rdx, rdx
    jz   .nodx    ;Give a useless 8 bytes to prevent crash
.oudx:

    push rbx
    push rdi
    push r9
    push rdx
    mov  rbx, rcx

    test r9,  r9     ;Check time flag
    jz   .enboeg
    mov  r10, unboeg ;Roll back UTC time
    sub  rcx, r10
;If Beijing time enabled, jump directly
.enboeg:

    or  r8, r8
    jnz .normal
    lea r8, [dust]

.normal:

    adod

    ;Parameter passing crew
    lea  r10, [r8+40]
    push r10
    lea  r10, [r8+32]
    push r10
    lea  r10, [r8+24]
    push r10
    lea  r10, [r8+16]
    push r10
    lea  r9,  [r8+8]
    
    ;Shadow space
    sub rsp, 32
    
    call kp_filetime_to_realtime_frmrax_ret_fastcall_win64

    pdod

;Write back filetime

    ;There is a push rdx earlier
    pop  rdi
    pop  r9
    test r9,  r9
    jz   .nore
    test rdi, rdi
    jz   .nore
    ;Next, rewrite the real filetime back
    mov  rdi, [rdi]
    mov  al,  ('{')
    mov  rcx, -1
    cld
    repne scasb
    jne  .nore
    mov  rax, rbx
    ;Now rax is filetime
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
    ;But there is no way, because compatibility with the old version must be preserved
    ;Now I can only write a cramped portal filler function to do it
    ;I'll write a complete version of this thing separately when I have time later

.nore:

    pop rdi
    pop rbx
    pdod

    ret

.nodx:
    lea rdx, [wasteimm]
    jmp .oudx

;Replace one $ with a custom ASCII symbol
;(destination, character in dl), clobbers rax, rcx
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
;Really, speeding and still needing a seatbelt, annoying
kp_simd_strlen_fastcall_win64:
    ;Because it uses the unaligned movdqu version, it must constantly check page boundaries

    mov r9,  16
    xor rdx, rdx

    pxor xmm1, xmm1

.label:

    ;Check page boundary
    mov r10, rcx
    and r10, 0xFFF ;Take upper 12 bits
    cmp r10, 4080  ;Compare with last page start
    ja  .slow
    ;If close to page boundary, switch to slow branch

    movdqu   xmm0, [rcx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0
    
    or  r8, r8
    jnz .found

    add rdx, r9
    add rcx, r9

    jmp .label

.found:

    bsf r8d, r8d

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
;ONE OF the weirdest functions I've currently written
;Leave the comments for twenty thousand years later
;So clever that changing one letter may completely crash it
kp_sse_strlen_fastcall_win64:
;I really don't want to write comments for this; one register used as 4 variables
;No mask merging; can only process 16 bytes at a time

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
;Suggested on CPUs supporting ERMSB
;(src,srclen,dst,dstlen)
kp_ermsb_fastcall_win64:
;What meaning does this kind of function have? Just so it can be used from C

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



;Read binary as hexadecimal and convert it into hexadecimal ASCII text
;(source, source length, destination, destination length) in bytes; destination must be 2 times source length
;Return: address of trailing \0; for chained calls, overwrite from that address
;Leave comments for tomorrow
kp_hex2ascii_fastcall_win64:

    cld

    lea r10, [rdx*2]
    cmp r10, r9
    jae .mgd

    test rcx, rcx
    jz   .mgd

    test r8, r8
    jz   .mgd
    
    test rdx, rdx
    jz   .mgd
    
    push rbx
    push rdi
    push rsi

    xchg rcx, rdx

    lea rbx, [hex2ascii_xlatable] ;Lookup table
    
    mov rdi, r8
    mov rsi, rdx
    ;rsi points to source
    
;Loop
.xlatloop:

    lodsb

    mov r9b, al
    shr al,  4
    
    xlat;Lookup table
    stosb;Store

    mov al, r9b
    and al, 0xF
    ;0b1111

    xlat
    stosb

    dec rcx
    jnz .xlatloop

    xor al, al

    stosb
    ;Append 0 at the end

    lea rax, [rdi-1]
    pop rsi
    pop rdi
    pop rbx

    ret

.mgd:
    xor rax, rax
    ret

;Two ASCII characters as one byte
;If what you write at the end is A\0, the lookup table probably won't execute
;(source, source length, destination, destination length) in bytes
;Return: address after the last data byte; for chained calls, continue writing from that address
;But you need to calculate remaining length yourself or use dynamic memory
;Note: will not append \0
kp_ascii2hex_fastcall_win64:

    test rcx, rcx
    jz   .mgd

    test rdx, rdx
    jz   .mgd
    
    shl r9,  1
    cmp rdx, r9
    ja  .mgd
    
    cld
    
;Main body

    push rbx
    push rdi
    push rsi

    mov rsi, rcx
    mov rdi, r8
    mov rcx, rdx
    shr rcx, 1

    lea rbx, [ascii2hex_xlatable] ;Lookup table

.xlatloop:

    lodsb;Fetch

    xlat;Lookup table

    mov r9b, al ;Temporarily store
    
    lodsb;Fetch

    xlat;Lookup table

    shl r9b, 4   ;Write back high bits
    or  al,  r9b ;Merge

    stosb;Store

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

;Currently the best strlen
;Heavily modified SSE2 version
;rcx=src
kp_sse2_strlen_fastcall_win64:

    test rcx, rcx
    jz   .np

    mov rdx, rcx
    mov r9,  rcx
    and rdx, -16 ;Force alignment
    sub rcx, rdx

    pxor     xmm1, xmm1
    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    shr  r8d, cl ;Remove useless mask
    test r8,  r8
    jnz  .found  ;Non-zero means found

    test rdx, 16
    ;Check 32-bit alignment
    jz   .ssego  ;If bit 4 is set, adding 16 directly aligns to 32 bytes

    add rdx, 16 ;Otherwise still need to handle 16 bytes separately, then align

    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    test r8d, r8d
    jnz  .gofind

;Preparation
.ssego:
    add rdx, 16
.sseloop:

    movdqa   xmm0, [rdx]
    movdqa   xmm2, [rdx+16]
    pcmpeqb  xmm0, xmm1
    pcmpeqb  xmm2, xmm1
    pmovmskb r8d,  xmm0
    pmovmskb eax,  xmm2
    
    shl  eax, 16   ;Mask high bits
    or   r8d, eax  ;Merge masks
    test r8d, r8d
    jnz  .ssefound

    add rdx, 32
    jmp .sseloop

.gofind:

    bsf rax, r8
    sub rdx, r9
    add rax, rdx
    
    ret

.found:

    bsf rax, r8

    ret

.ssefound:

    bsf rax, r8

    sub rdx, r9
    add rax, rdx
    ret

.np:
    xor eax, eax
    ret

;Heavily modified AVX2 version, similar to SSE2 version, too lazy to comment
;rcx=src
kp_avx2_strlen_fastcall_win64:

    test rcx, rcx
    jz   .np

    mov rdx, rcx
    mov r9,  rcx
    and rdx, -32
    sub rcx, rdx

    vpxor     ymm1,ymm1,ymm1
    vmovdqa   ymm0, [rdx]
    vpcmpeqb  ymm2,ymm0,ymm1
    vpmovmskb r8d,  ymm2

    shr  r8d, cl
    test r8,  r8
    jnz  .found

    test rdx, 32
    ;Check 64-bit alignment
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

    bsf rax, r8
    sub rdx, r9
    add rax, rdx
    vzeroupper
    ret

.found:

    bsf rax, r8
    vzeroupper
    ret

.avxfound:

    bsf rax, r8
    vzeroupper
    sub rdx, r9
    add rax, rdx
    ret

.np:
    xor eax, eax
    ret

;Wrap CreateFileW; return value follows API, but failure is 0
;int(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition)
;lpSecurityAttributes passes NULL, hTemplateFile passes NULL
;dwFlagsAndAttributes passes FILE_ATTRIBUTE_NORMAL
;No checks at all
kp_win32api_createfile_w_fastcall_win64:
    
    adod

    ; push r15 ;Junk alignment
    push rax

    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push r9

    xor r9, r9
    ; xor r15, r15

    sub  rsp, 32
    call CreateFileW

    xor   ecx, ecx
    cmp   rax, -1
    cmove rax, rcx

    ; mov r15, [rsp+56] ;Restore

    pdod

    ret;Yes, really just this little bit

;Wrap GetFileSizeEx
;int(hFile,lpFileSize)
;Same as API, failure returns 0, success non-zero
kp_win32api_get_file_size_ex_fastcall_win64:

    jmp GetFileSizeEx
    ;Probably the shortest one

;Wrap ReadFile
;int(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead)
;Behavior basically same as API; the 5th parameter is always NULL
;nNumberOfBytesToRead: how many bytes to read. DWORD, 32-bit.
;lpNumberOfBytesRead: pointer to a DWORD; the API writes "how many actually read" into it. This value may be less than what you wanted to read.
kp_win32api_read_file_fastcall_win64:

    adod

    push NULL ;Alignment
    push NULL

    sub  rsp, 32
    call ReadFile

    pdod

    ret

; Wrap WriteFile
;(handle, source, source length, actual written pointer)
;(hFile, lpBuffer, nNumberOfBytesToWrite, lpNumberOfBytesWritten)
kp_win32api_write_file_fastcall_win64:

    adod

    push rax     ;Placeholder
    push NULL
    sub  rsp, 32

    call WriteFile

    pdod

    ret

;Wrap SetFilePointerEx
;(handle, offset, new position pointer, starting position)
;(hFile, liDistanceToMove, lpNewFilePointer, dwMoveMethod)
kp_win32api_set_file_pointer_ex_fastcall_win64:

    jmp SetFilePointerEx

;Get file pointer
;(handle, 64-bit variable pointer)
kp_win32api_get_file_pointer_ex_fastcall_win64:

    mov r8,  rdx
    xor rdx, rdx
    mov r9d, FILE_CURRENT

    jmp SetFilePointerEx

;Wrap CloseHandle
;(handle)
kp_win32api_close_handle_fastcall_win64:

    jmp CloseHandle

;Wrap MessageBoxW
kp_win32api_msgbox_w_fastcall_win64:

    jmp MessageBoxW

;Wrap WideCharToMultiByte
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




;Wrap VirtualAlloc
;(address, size, allocation type, protection attributes)
;(lpAddress, dwSize, flAllocationType, flProtect)
kp_win32api_virtual_alloc_fastcall_win64:

    jmp VirtualAlloc


;Wrap VirtualFree
;(address, size, free type)
;(lpAddress, dwSize, dwFreeType)
kp_win32api_virtual_free_fastcall_win64:

    jmp VirtualFree

;Originally the first step of character ascii_hex formatting
;Text grouping, byte-level processing, only suitable for ascii and utf8
;You can pass a negative number for parameter 4 to ignore (disable) length checking
; You can pass a negative number for parameter 6 to ignore (disable) newline functionality
;By default uses spaces for division; newline uses 0x0A0D (little-endian), i.e., carriage return + line feed
;(source, source length, destination, destination length, bytes per group, groups per line)
;srclen=0 exits directly; failure returns NULL; success returns pointer to destination trailing \0
kp_text_format_divide_fastcall_win64:
;I declare this kind of comment released into the wild for at least two months

;Check srclen and dstlen

    ;Put on a show of taking off pants to fart
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
    ;I can't do anything about 0 bytes per group either
    test r11, r11
    jz   .error

    ;Check rdx
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
    bts  rax, 0  ;Disable length check

.r9ok:
    test r11, r11
    jns  .chk
    bts  rax, 1   ;Disable newline

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
    inc  r10      ;Fallback for unaligned
.alnd:
;Next calculate how many lines
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

;Length calculation
    
;Required length = source length + groups - lines + (lines-1)*2 + 1
;(srclen+groups+lines-1)
    lea rdx, [rdx+r10]
    lea r15, [r11-1]
    add rdx, r15

    bt rax, 0
    jc .main

    cmp rdx, r9
    jbe .main

    jmp .error

;Main body, two versions
;Respectively with newline and without
;All beings equal main, all beings equal rdx, everything else is the same except rax's bit 1
.main:

    bt   rax, 1
    jc   .disablenewline
    ;rcx=src,rdx=len,r8=dst,r10=groups,r11=lines,r12=objspergroup,r13=groupsperline
    push rdi
    push rsi
    mov  rsi, rcx
    mov  rdi, r8
    ;Big loop = lines-1
    ;Portal
    cmp  r11, 1
    je   .last
    lea  rcx, [r11-1]
;Big loop, executes lines-1 times total
.big:
    push rcx
    mov  rax, 0x20
    mov  rcx, r13
    cmp  rcx, 1
    jz   .onegpl
    dec  rcx
    ;Middle loop, executes groups per line - 1 times each
    .mid:
    push rcx
    ;Small loop, copies one group and formats it each time
    mov  rcx, r12
    rep movsb
    stosb
    pop  rcx
    dec  rcx
    jnz  .mid
    ;When groups per line is 1
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
    ;Now rax is remaining groups
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

;UTF-8 decode single character, internal function
;Assumes rsi is already set
;rax=0 failure, success returns character code point
;Clobbers rax, rdx
;Automatically decreases rcx
kp_text_utf8_single_symbol_decode_inside:

    xor eax, eax
    xor edx, edx
    mov r10, rsi

    lodsb

    bt ax, 7
    
    jc  .notascii
    ;ASCII character comes out directly
    dec rcx
    ret

.notascii:


    bt  ax, 6
    jnc .broken ;If it starts with 10, it is broken

    bt  ax, 5
    ;If it starts with 110, it is 2 bytes
    jnc .word

    bt  ax, 4
    ;If it starts with 1110, it is 3 bytes
    jnc .tri

    ;It seems UTF-8 has at most 4 bytes, so go directly to the main branch
    jmp .double

;2 bytes
.word:

    sub rcx, 2
    js  .werr
    ;Process first byte first
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
    mov rsi, r10
    ; mov word [r8], 0xFFFF
    xor rax, rax
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

;utf8t16le main function
;(source, source length, destination, destination length)
;If source length is negative, calculate automatically; destination length must be at least 2 times source length
;Return value: error (null pointer, insufficient length, character error) is 0
kp_text_utf8t16le_main_fastcall_win64:
    ;(Cancelled) Note: internal function clobbers r10; if needed, save before calling subfunctions
    ;(Cancelled) Character error: the word pointed to by r8 is FFFF

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
    ;Useful if written
    call kp_avx2_strlen_fastcall_win64
    ; call kp_strlen_fastcall_win64

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
    ;rdx probably no longer needed
    .main:
    ;Now rcx equals byte count
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
    lea rax, [rdi-2]
    pop rdi
    pop rsi
    ret

;Surrogate pair
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

;Null pointer, empty city scheme, not big enough return
.npointer:
    xor rax, rax
    ret


;fmt function reset version
;(original filetime, struct pointer, flags, UTC offset-seconds)
;Flags: bit0 whether to enable UTC offset, bit1 enable milliseconds, bit2 enable microseconds
;Struct unsigned long long, returns pure numbers instead of text
;(year, month, day, hour, minute, second, millisecond, microsecond)
;48~64 bytes; milliseconds and microseconds need to be enabled via flags
;Default is UTC time; if Beijing time is needed, add the offset
kp_improved_filetime_to_realtime_calc_fastcall_win64:

    ;Null pointer check
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
    ;Save original struct pointer
    mov rax, rcx
    xor rdx, rdx
    mov rcx, 10000000

    div rcx

    mov [rbp+24], rdx
    ;Save subticks

    test r8,  1
    je   .nooffset
    add  rax, r9

.nooffset:

    sub rsp,   256
    mov [rsp], rax
    
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
    mov rcx,      days_per_400_years ;First calculate how many complete 400-year periods
    xor rdx,      rdx
    div rcx
    mov [rbx+16], rax
    mov rax,      rdx
    mov rcx,      days_per_100_years ;Continue dividing by 100 years
    xor rdx,      rdx
    div rcx
    mov [rbx+24], rax
    mov rax,      rdx
    mov rcx,      days_per_4_years   ;Calculate how many 4-year periods
    xor rdx,      rdx
    div rcx
    mov [rbx+32], rax
    mov [rbx+40], rdx
    ;Remaining days
    
    imul rax,[rbx+16],400
    mov [rbx+48], rax
    imul rax,[rbx+24],100
    add [rbx+48], rax
    imul rax,[rbx+32],4
    add [rbx+48], rax
    ;Now everything except the less-than-4-years part has been calculated

    ;First compare whether leap year handling is needed
    mov rax, [rbx+40]
    cmp rax, 1460
    je  .skipdivy
    ;This label is later
    mov rcx, 365
    xor rdx, rdx
    div rcx

;For 1460 days, portal directly here    
.skipdivn:    
    
    ;Save remaining years and days
    mov [rbx+56], rax
    mov [rbx+64], rdx
    mov r9,       rax
    inc rax
    add rax,      [rbx+48]
    mov [r11],    rax

    ; Comments written for AI because AI pissed me off
    ; tempyears = absolute year-1 - ((absolute year-1) mod 4)
    ; = start of current 4-year cycle - 1 (not absolute year!)
    ; Example: 2000 -> 1996, 2001 -> 2000, 1900 -> 1896
    ; Purpose: compare tempyears and tempyears+4 for /100 and /400
    ;   equal -> no boundary crossed; not equal -> boundary crossed, continue checking 400
    ; Absolute year = tempyears + 1 + nbofovys (complete years already passed in current cycle)

    ;Now calculate whether there is a century common year

    lea r10, [mthlep]
    lea rcx, [mthcom]
    ;In VS Code, hover the cursor to see the comment above a label (requires an extension)

    ; cmp    rax, 3
    cmp    r9,  3
    cmovne r10, rcx
    jne    .lepsub

    ;Now the remaining part needs to consider leap years
    mov rax, [rbx+48]
    mov r9,  rax
    ;First copy rax; r9 is the original tempyears of rax
    mov rcx, 100
    xor rdx, rdx
    div rcx
    mov r8,  rax
    ;Save first result
    mov rax, r9
    add rax, 4
    xor rdx, rdx
    div rcx
    cmp rax, r8
    ;Compare with first result
    ;Here it is still the leap year table
    je  .lepsub
    ;Not equal means there is a century year
    ;Now check whether there is a 400-year leap year
    mov rcx, 400
    xor rdx, rdx
    mov rax, r9
    div rcx
    mov r8,  rax
    ;Save first result
    xor rdx, rdx
    mov rax, r9
    add rax, 4
    div rcx
    cmp rax, r8
    ;Compare; equal means it is not a 400-year leap, but a century common year

    lea   rcx, [mthcom]
    cmove r10, rcx

;Code reuse part
;Month subtraction calculation
;This expects rax to equal the extra days, initialized below

    .lepsub:
    mov rax, [rbx+64]
    xor rcx, rcx
    xor rsi, rsi

.leplop:
    inc   rcx
    ;Does anyone really remember that rsi has been zeroed? (Originally at the beginning)
    ;OK, now changed to zero it in advance
    movzx rdx, byte [r10+rsi]
    inc   rsi
    cmp   rax, rdx
    
    jb  .edlepsub
    sub rax, rdx
    jmp .leplop

.edlepsub:    
    ;rax=remaining days, rcx=month
    inc rax
    ;This is the incomplete day, so add it
    mov [r11+16], rax
    mov [r11+8],  rcx

;At this point year, month, and day are calculated; next are hour, minute, second  
    mov rax, [rbx+8]
    xor rdx, rdx
    mov rcx, 3600
    div rcx

    mov [r11+24], rax
    
    ;Now give the remaining seconds in rdx to rax
    xchg rax, rdx
    xor  rdx, rdx
    mov  rcx, 60
    div  rcx

    mov [r11+32], rax
    mov [r11+40], rdx

    mov r8, [rbp+32]
    ;Restore flags
    
    mov rax, [rbp+24]
    ;Get subticks
    mov ecx, 10000
    xor edx, edx
    
    div rcx

    bt  r8, 1
    jnc .exit

    mov [r11+48], rax
    ;Milliseconds

    bt  r8, 2
    jnc .exit
    
    mov rax, rdx
    xor edx, edx
    mov ecx, 10

    div rcx

    mov [r11+56], rax

.exit:

    add rsp, 256

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
;Unexpectedly rewrote this pile of crap today (October 4, 2026)
;Code recycling part

;Null pointer returns directly
.null:
    xor rax, rax
    ret

;Find first character
;(left blank, source, source length, single-byte character) in bytes
;If length is negative, calculate automatically, but must ensure it ends with 0
kp_strchr_fastcall_win64:

    test rdx, rdx
    jz   .np

    mov  rcx, rdx
    test r9b, r9b
    ;Since we're already here
    jz   kp_sse2_strlen_fastcall_win64

    test r8, r8
    jz   .np
    jns  .havelen
    
    call kp_strlen_fastcall_win64
    mov  r8, rax

.havelen:

    mov rcx, r8
    mov al,  r9b
    mov r9,  rdx

    push rdi
    mov  rdi, rdx

    repne scasb
    jne .nf

    lea rax, [rdi-1]
    sub rax, r9
    ; ;Return pointer (fake)
    

    pop rdi
    ret

.nf:
    pop rdi
.np:
    xor rax, rax
    ret

;Currently the best strchr
;Heavily modified SSE2 version changed into SSE3 version strchr
;(left blank, source, source length, single-byte character) in bytes
;If length is negative, calculate automatically, but must ensure it ends with 0
kp_ssse3_strchr_fastcall_win64:
;Whatever, change it to return index; C is more convenient with indexes
    test rdx, rdx
    jz   .np

    mov  rcx, rdx
    test r9b, r9b
    jz   kp_sse2_strlen_fastcall_win64
    ;Still

    test r8, r8
    jz   .np
    jns  .havelen

    push r9
    push rdx

    ;Actually no need to consider alignment, because there are no SIMD parameters on the stack
    call kp_sse2_strlen_fastcall_win64
    ;We are from the same root o(*￣︶￣*)o

    pop  rdx
    pop  r9
    test rax, rax
    jz   .np
    mov  r8,  rax

.havelen:

    cmp r8, 64
    jna kp_strchr_fastcall_win64

    mov r11, r8

    movzx  r9d,  r9b
    movd   xmm1, r9d
    ;This episode is amazing
    pxor   xmm0, xmm0
    pshufb xmm1, xmm0

    ; xchg rdx, rcx
    ; ;Too lazy to change, just swap directly

    ; mov rdx, rcx
    mov rcx, rdx
    mov r9,  rcx
    and rdx, -16 ;Force alignment
    sub rcx, rdx

    ; pxor     xmm1, xmm1
    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    shr  r8d, cl ;Remove useless mask
    test r8,  r8
    jnz  .found  ;Non-zero means found

    test rdx, 16
    ;Check 32-bit alignment
    jz   .ssego  ;If bit 4 is set, adding 16 directly aligns to 32 bytes

    add rdx, 16 ;Otherwise still need to handle 16 bytes separately, then align

    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    test r8d, r8d
    jnz  .gofind

;Preparation
.ssego:
    add  rdx, 16
    ;Add a little trick
    ;Calculate bytes still to scan
    mov  r10, rdx
    sub  r10, r9
    mov  rcx, r11
    sub  rcx, r10
    ;Secret technique
    ;Determine SSE2 loop count
    test rcx, 31
    jz   .ald
    add  rcx, 32
    ;If not aligned to 32 bytes, add one more time
.ald:

    shr rcx, 5
    ;Shift to get loop count

.sseloop:

    movdqa   xmm0, [rdx]
    movdqa   xmm2, [rdx+16]
    pcmpeqb  xmm0, xmm1
    pcmpeqb  xmm2, xmm1
    pmovmskb r8d,  xmm0
    pmovmskb eax,  xmm2
    
    shl  eax, 16   ;Mask high bits
    or   r8d, eax  ;Merge masks
    test r8d, r8d
    jnz  .ssefound

    add rdx, 32
    ; jmp .sseloop
    dec rcx
    jnz .sseloop
    jmp .np

.gofind:

    bsf eax, r8d
    sub rdx, r9
    add rax, rdx

    ret

.found:

    bsf eax, r8d

    ret

.ssefound:

    bsf eax, r8d

    sub rdx, r9
    add rax, rdx

    cmp rax, r11
    jae .np

    ret

.np:
    xor eax, eax
    ret

;Reentrant version of print rcx
;(number, destination)
;Destination remaining length at least 22; checks null pointer
kp_improved_prtnum_frmrcx_fastcall_win64:

    test rdx, rdx
    jz   .eterror

    mov rax, rcx
    mov r8,  rdx

    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;Check negative
    jns  .isnotnegative ;If not negative, skip
    mov  byte [r8], 45  ;ASCII for negative sign
    
    inc rdi
    neg rax ;Convert negative to positive

;If not negative, go here
.isnotnegative:
    push rsi
    push rcx
    push rdx
    push rbx
    mov  rbx, 10
    xor  rcx, rcx
;Division loop
.divlop:
    inc  rcx
    xor  rdx, rdx
    div  rbx
    push rdx
    test rax, rax
    jz   .preprt
    jmp  .divlop
;Print preparation
.preprt:
    mov rbx, r8
;Write digits loop
.loopofrewrite:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .loopofrewrite

    ; inc rdi ; This inc must not be written
    mov byte [rbx+rdi], 0

    mov rax, r8
    ;Return address

    pop rbx
    pop rdx
    pop rcx
    pop rsi
    pop rdi

    ret 

.eterror:
    xor eax, eax
    ret

;Append string at end with newline, 4 parameters
;(source, source length, destination start, destination buffer length)
;If source length is negative, calculate automatically
;Returns trailing \0 pointer, failure returns 0
kp_strend_wthrnl_fastcall_win64:

    push rbp
    mov  rbp, rsp

    ;Check null pointers and zero length
    test rcx, rcx
    jz   .nullet
    test r8,  r8
    jz   .nullet
    test r9,  r9
    jz   .nullet
    test rdx, rdx
    jz   .nullet
    cmp  r9,  2
    jna  .nullet

    ;Main part begins

    ; mov r10, rcx ; Back up source pointer
    push rcx
    mov  rcx, r8 ; rcx = dst, for internal strlen
    
    call kp_strlenled_inside
    ; Returns: rax = destination trailing \0 pointer, rcx = destination current length

    sub r9,  2
    sub rcx, r9 ; current length - total capacity
    neg rcx     ; negate to get remaining space
    js  .nullet ; if negative, destination is full, just leave

    mov r9, rcx
    ; mov rcx, r10
    pop rcx

;Mysterious label
.noauto:   

    ;Now can start copying string
    
    mov r8, rax ; r8 = address of destination's trailing \0
    
    call kp_strcpy_fastcall_win64

    mov word [rax], 0x0A0D
    
    add rax, 2

    mov byte [rax], 0
    
    mov rsp, rbp
    pop rbp

    ret

;Null pointer and insufficient length exit
.nullet:
    mov rsp, rbp
    pop rbp
    xor rax, rax
    ret

;Loop concatenate strings
;(address table, entry count, destination, destination length) in bytes
;Does not check null pointers
kp_stredy_fastcall_win64:

    push r15
    push r14
    push r13
    push r12
    push rdi
    push rsi
    push rbp
    mov  rbp, rsp

    test r9, r9
    jz   .error

    test rdx, rdx
    jz   .done

    mov r12, rcx
    mov r13, rdx
    mov r14, r8
    mov r15, r9

.callop:

    ; test r13, r13
    ; jz   .done

    mov rcx, [r12]

    mov rdx, -1
    mov r8,  r14
    mov r9,  r15

    call kp_sse2_strcpy_fastcall_win64

    test rax, rax
    jz   .error

    mov rcx, rax
    sub rcx, r14
    sub r15, rcx
    mov r14, rax

    add r12, 8
    dec r13
    jnz .callop

.done:

    mov rax,        r14
    mov byte [rax], 0

    mov rsp, rbp
    pop rbp
    pop rsi
    pop rdi
    pop r12
    pop r13
    pop r14
    pop r15

    ret

.error:

    mov rsp, rbp
    pop rbp
    pop rsi
    pop rdi
    pop r12
    pop r13
    pop r14
    pop r15

    xor eax, eax
    ret



;Text copy, SSE2 version
;rcx holds source pointer, rdx holds source length, r8 holds destination pointer, r9 holds destination length, all in bytes
;Returns pointer to trailing 0; if rdx is negative, calculate automatically
;Warning: stredy does not leave shadow space before calling it
kp_sse2_strcpy_fastcall_win64:

;Changed October 6, 2026
;Optimized main loop; now processes 32 bytes at a time
;And uses movsb at the end, trying to use mmx to preserve regs

    test rcx, rcx
    jz   .np

    test r8,  r8
    jz   .np

    test r9,  r9
    jz   .np

    test rdx, rdx
    jz   .zerolen
    jns  .havelen

    push rcx
    push r8
    push r9

    call kp_sse2_strlen_fastcall_win64

    pop r9
    pop r8
    pop rcx

    mov rdx, rax

.havelen:

    test rdx, rdx
    jz   .zerolen

    cmp rdx, r9
    jae .np

    cmp rdx, 64
    jb  kp_strcpy_fastcall_win64

    ;After length comparison r9 is useless, just replace it

    mov r9,  rdx
    and r9,  31
    shr rdx, 5

.sseloop:

    movdqu xmm0,    [rcx]
    movdqu [r8],    xmm0
    movdqu xmm0,    [rcx+16]
    movdqu [r8+16], xmm0

    add r8,  32
    add rcx, 32

    dec rdx
    jnz .sseloop

    test r9, r9
    jz   .done

.left:
    ; mov al,   [rcx]
    ; mov [r8], al

    ; inc rcx
    ; inc r8

    ; dec r9
    ; jnz .left

;According to the ABI, x87 registers are volatile

    ; movq mm0, rdi
    ; movq mm1, rsi

    push rdi
    push rsi

    mov rsi, rcx
    mov rdi, r8

    cld;Still add it

    mov rcx, r9
    rep movsb

    mov r8,  rdi
    mov rcx, rsi
;Assigning rcx here is only to keep state consistent

    ; movq rdi, mm0
    ; movq rsi, mm1

    ; emms;Must add if using mmx

    pop rsi
    pop rdi

.done:
    mov byte [r8], 0

    mov rax, r8
    ret

.zerolen:
    mov byte [r8], 0
    
    mov rax, r8
    ret

.np:
    xor eax, eax
    ret


;Wrap GetLastError
;Returns DWORD (eax) error code; 0 means no error
kp_win32api_get_last_error_fastcall_win64:
    jmp GetLastError

;Truly the shortest one
;Playing: 《The_Everlasting_Guilty_Crown》-EGOIST_-GC-S_FLAC
;Drunk, no joy, sad parting; when parting, the river is vast and the moon sinks in it

;Print 64-bit, little-endian wrapper
;rcx=num,rdx=dst, does not check length
;Does not check pointer, actually checks
;Must leave shadow space
kp_u64_hex2ascii_fastcall_win64:

    bswap rcx
    mov   [rsp+8], rcx
    
    lea rcx, [rsp+8]

    mov r8,  rdx
    mov rdx, 8
    mov r9,  17

    ;Now rsp still points to return address

    jmp kp_hex2ascii_fastcall_win64

;Handle acquisition
; Returns HMODULE, failure returns 0
kp_win32api_get_module_handle_w_fastcall_win64:
    jmp GetModuleHandleW


; Returns HWND, failure returns 0
kp_win32api_get_console_window_fastcall_win64:
    jmp GetConsoleWindow


; Returns HWND, failure returns 0
kp_win32api_get_foreground_window_fastcall_win64:
    jmp GetForegroundWindow

; rcx = lpClassName (wide characters, may be NULL)
; rdx = lpWindowName (wide characters, may be NULL)
; Returns HWND, failure returns 0
kp_win32api_find_window_w_fastcall_win64:
    jmp FindWindowW

; rcx = nStdHandle (STD_INPUT_HANDLE = -10, etc.)
; Returns HANDLE; failure returns INVALID_HANDLE_VALUE or 0
kp_win32api_get_std_handle_fastcall_win64:
    jmp GetStdHandle


; Success returns non-zero, failure returns 0
; Note: if the process already has a console, it will fail
kp_win32api_alloc_console_fastcall_win64:
    jmp AllocConsole




;Text copy, SSE2 version heavily modified to AVX2
;Yes, I am padding the update!
;rcx holds source pointer, rdx holds source length, r8 holds destination pointer, r9 holds destination length, all in bytes
;Returns pointer to trailing 0; if rdx is negative, calculate automatically
;Warning: stredy does not call it
kp_avx2_strcpy_fastcall_win64:

;Changed October 6, 2026
;Optimized main loop; now processes 64 bytes at a time
;And uses movsb at the end, trying to use mmx to preserve regs

    test rcx, rcx
    jz   .np

    test r8,  r8
    jz   .np

    test r9,  r9
    jz   .np

    test rdx, rdx
    jz   .zerolen
    jns  .havelen

    push rcx
    push r8
    push r9

    call kp_sse2_strlen_fastcall_win64

    pop r9
    pop r8
    pop rcx

    mov rdx, rax

.havelen:

    test rdx, rdx
    jz   .zerolen

    cmp rdx, r9
    jae .np

    cmp rdx, 128
    jb  .ermsb

    ;After length comparison r9 is useless, just replace it

    mov r9,  rdx
    and r9,  63
    shr rdx, 6

.avxloop:

    vmovdqu ymm0,    [rcx]
    vmovdqu [r8],    ymm0
    vmovdqu ymm0,    [rcx+32]
    vmovdqu [r8+32], ymm0

    add r8,  64
    add rcx, 64

    dec rdx
    jnz .avxloop

    test r9, r9
    jz   .done

.left:
    ; mov al,   [rcx]
    ; mov [r8], al

    ; inc rcx
    ; inc r8

    ; dec r9
    ; jnz .left

;According to the ABI, x87 registers are volatile

    ; movq mm0, rdi
    ; movq mm1, rsi

    push rdi
    push rsi

    mov rsi, rcx
    mov rdi, r8

    cld;Still add it

    mov rcx, r9
    rep movsb

    mov r8,  rdi
    mov rcx, rsi
;Assigning rcx here is only to keep state consistent

    ; movq rdi, mm0
    ; movq rsi, mm1

    ; emms;Must add if using mmx

    pop rsi
    pop rdi

.done:

    vzeroupper

    mov byte [r8], 0

    mov rax, r8
    ret

.zerolen:

    mov byte [r8], 0
    
    mov rax, r8
    ret

.np:
    xor eax, eax
    ret

.ermsb:

;According to the ABI, x87 registers are volatile

    ; movq mm0, rdi
    ; movq mm1, rsi

    push rdi
    push rsi

    mov rsi, rcx
    mov rdi, r8

    cld;Still add it

    mov rcx, r9
    rep movsb

    mov r8,  rdi
    mov rcx, rsi
;Assigning rcx here is only to keep state consistent

    ; movq rdi, mm0
    ; movq rsi, mm1

    ; emms;Must add if using mmx

    pop rsi
    pop rdi

    mov byte [r8], 0

    mov rax, r8
    ret

;Although it is a bit padded, it is still an update

































































;   Note: End of code section (I really can't stand that NASM has no end marker and I keep getting it wrong)

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
        ;Versions previously released under the GPL are not affected
        ;Because it needs to use closed-source libraries or source-available libraries, which do not meet GPL requirements

    ;September 6, 2026

;What you must know:

    ;It does not use an open source license, only source-available
    ;If you are a student and study assembly as a hobby unrelated to work, you can freely research and study
    ;This code is free; don't sell it for money
    ;If you paid to obtain it, you were cheated out of a little money
    ;Free link: https://github.com/KUSSA-LTSC/KUDOS-kpstdlib/

;September 11, 2026

; What you must know:
;
; It does not use an open source license, only source-available.
; This is not an OSI open source license.
;
; This code is free; don't sell it for money.
; If you paid to obtain it, you were cheated.
; Free link: https://github.com/KUSSA-LTSC/KUDOS-kpstdlib/
;
; Individuals may study assembly for hobby, private, non-commercial purposes.
; Students may study, but only for personal private study, or for
; "permitted educational uses" as defined by the license: public free courses on mainstream online platforms.
;
; It is prohibited to share the source code, modified versions, or binary files with friends, classmates, colleagues,
; students, other departments, subsidiaries, or any third party.
; Research cooperation, peer review, and paper publication are handled under Section 1.4 of the license.
;
; Configuration files may be public, but must not contain source code, scripts, binaries,
; executable logic, or any material that can reconstruct the software.
;
; Commercial use, use by for-profit entities, evaluation, testing, bundling, and AI training
; all require prior written paper consent from the project owner.
;
;September 12, 2026

; Damn, I'm going to be exhausted

;September 13, 2026

; Is high school hell? Today is the 918 remembrance day

;September 18, 2026

; Happy Mid-Autumn Festival
; Happy my ass, doing homework together
; That bloated filetime_to_realtime, I will rewrite it sooner or later

; I am really exhausted
; This bloated thing still has a bunch of stuff not done
; There are even a bunch of instruction sets
; Technically there is a bunch of technical debt
; Functionally there is a bunch of unfinished stuff
; Comments are also still missing a huge amount. Comments written by AI are crap, not like human-written
; Still, Hiroi Kikuri is my favorite

;September 24, 2026

; When people get old they really become useless; today I only wrote 02 functions
; The last day of September
; How can homework be used as a stool
;September 30, 2026

; Today is October 01, National Day

; On this happy day, I sincerely wish the motherland a happy birthday.
; On this happy day, I sincerely wish the motherland a happy birthday.

; I wrote a lot today, such as the AVX2 version of strlen

; The code broke 2000 lines, but most of it is comments, O(∩_∩)O haha~
; Yes yes yes, now it broke 3000 lines (October 4, 2026)

;October 1, 2026

; I hate string formatting
; I'm really sick of this annoying thing
; Homework, I can't finish it
;October 2, 2026

; Added some comments, and didn't want to do homework because I felt unwell
;October 3, 2026

; Major update: I rewrote the pile of crap filetime_to_realtime (nice), copied two functions and gave them brand-new names
; But I only rewrote the calculation part and changed some behavior, so I gave this rewritten function a new label
; Fixed many unknown issues; added null pointer checks to some old functions
;October 4, 2026

; I don't know what I wrote today, anyway very annoyed
; Added comments for unit one, then created a unit twenty pile of crap
; Fixed some major vulnerabilities, changed some function behavior
;October 5, 2026

; No major update. The SSE2 version of strcpy extended an AVX2 version branch, but performance may be worse than the SSE2 version
; Improved some functions, modified and supplemented a few comments, evaluated the pros and cons of mmx registers. Not enabled yet, very likely to be used to back up registers in the next function with complex control flow and conditional PUSH
; National Day is about to end. This file is also about to reach 4000 lines, but whether the code has 1500 lines is questionable. Basically no update tomorrow; tomorrow I go back to studying
; New pit not opened. I may consider writing later programs in C. Assembly control flow is too poor, although I think Jcc is much easier to use than if, while, do, etc., but assembly parameter passing is too troublesome, and there are no expressions. It's not hard to write, it's time-consuming
; Owe the comments; no time to fill them
;October 6, 2026

; Damn it, a bug made me stare at dbg for 3 days
; That damn shift instruction doesn't update flags when cl=0. 3 days! Most new features were cut. It was that damn SIMD (SSE2, AVX2) strlen that died in such a small place
; Going back to school, wuwuwuwu~
;October 7, 2026

;That's the bottom of it, that's all~
