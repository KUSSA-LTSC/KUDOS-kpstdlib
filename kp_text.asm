; kp_text.asm

; Copyright (c) 2026-8086 KUSSA. All rights reserved.

bits    64
default rel

%include 'kpstdmac.inc'

section .data

align   16
; 神人 atoh 查表，0xFF 表示非法
atoh_xlatable:

    times 48  db 0xFF                ; 0x00-0x2F 非法区
    db           0,1,2,3,4,5,6,7,8,9 ; 0x30-0x39 '0'-'9'
    times 7   db 0xFF                ; 0x3A-0x40 总之不合法
    db           10,11,12,13,14,15   ; 0x41-0x46 'A'-'F'
    times 26  db 0xFF                ; 0x47-0x60 总之不合法
    db           10,11,12,13,14,15   ; 0x61-0x66 'a'-'f'
    times 153 db 0xFF                ; 0x67-0xFF 非法区

; 神人 atoi 查表，0xFF 表示非法
atou_xlatable:

    times 48  db 0xFF                          ; 0x00-0x2F 非法区
    db           0,1,2,3,4,5,6,7,8,9           ; 0x30-0x39 '0'-'9'
    times 7   db 0xFF                          ; 0x3A-0x40 总之不合法
    db           0xFF,0xFF,0xFF,0xFF,0xFF,0xFF ; 0x41-0x46 'A'-'F'
    times 26  db 0xFF                          ; 0x47-0x60 总之不合法
    db           0xFF,0xFF,0xFF,0xFF,0xFF,0xFF ; 0x61-0x66 'a'-'f'
    times 153 db 0xFF                          ; 0x67-0xFF 非法区

section k1 code

; 打印数字
;（数字，目标）
; 目标剩余长度至少22字节
k1_itoa_2611:

    mov rax, rcx
    mov r8,  rdx

    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;检查负数
    jns  .isnotnegative ;不是负数就跳过
    mov  byte [r8], 45  ;负数符号的ASCII
    
    inc rdi
    neg rax ;负数转正

;不是负数走这里
.isnotnegative:
    push rsi
    push rcx
    push rdx
    push rbx
    mov  rbx, 10
    xor  rcx, rcx
;除法循环
.divlop:
    inc  rcx
    xor  rdx, rdx
    div  rbx
    push rdx
    test rax, rax
    jz   .preprt
    jmp  .divlop
;打印准备
.preprt:
    mov rbx, r8
;写数字循环
.loopofrewrite:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .loopofrewrite

    mov byte [rbx+rdi], 0

    mov rax, r8
    ;返回地址

    pop rbx
    pop rdx
    pop rcx
    pop rsi
    pop rdi

    ret

; 把字符变成无符号数字
; 按照无符号解析，不允许负号
; 不检查空指针
; （文本，长度）
; 长度给负数的话，自动算，但是后果自负
; 长度给 0的话自动访问[0x00000000]崩溃
; 长度太长的话自动访问[0x00000000]崩溃
k1_atou_2611:

    prbp

    test rdx, rdx
    jz   .panic
    jns  .havelen

    push rcx
    kall kp_strlen, rcx
    pop  rcx

    mov  rdx, rax
    test rdx, rdx
    jz   .panic

.havelen:

    cmp rdx, 20
    ja  .panic

    ; 先检查合法性
    push rbx
    push rcx
    mov  r8,  rcx
    lea  rbx, [atou_xlatable]
    mov  ecx, edx
    xor  eax, eax

.checkloop:

    mov al, [r8]
    xlat
    cmp al, 0xFF
    je  .panic
    inc r8
    
loop .checkloop
    
    ; 恢复r8
    mov r8, [rsp]

    cmp  rdx, 20
    jb   .goahead
    call .limit

db '18446744073709551615';2^64-1

.limit:
    pop r10
    mov ecx, edx
    mov r11, r8

.liloop:

    xor eax, eax
    mov al,  [r11]
    cmp al,  [r10]
    ja  .panic
    jb  .goahead
    inc r11
    inc r10

loop .liloop

.goahead:

    mov ecx, edx
    xor edx, edx
    xor eax, eax
    xor r10, r10
    mov r11, 10

.calcloop:

    mov al, [r8]

    xlat

    lea r9,  [r10*2]
    lea r10, [r10*8]
    add r9,  r10
    lea r10, [r9+rax]

    inc r8

loop .calcloop

    mov rax, r10
    pop rcx
    pop rbx

    pdod

    ret
    
.panic:

    mov [abs 0x00], rax



; atou 的提前检查
; 只能根据返回 0来判断失败！
; （文本，长度）
; 按照无符号解析，不允许负号
; 不检查空指针
; 长度给负数的话，自动算，但是后果自负
; 长度给 0的话算失败
k1_chks_atou_2611:

    test rdx, rdx
    jz   .np
    jns  .havelen

    push rcx
    adod
    shadow
    call kp_strlen
    pdod
    pop  rcx
    
    mov rdx, rax

.havelen:

    cmp  rdx, 20
    ja   .np
    test rdx, rdx
    jz   .np
    
    mov r8,  rcx
    mov rcx, rdx
    lea r9,  [atou_xlatable]

    xor eax, eax

.chkloop:

    mov al, [r8]
    mov al, [r9+rax]
    cmp al, 0xFF
    je  .np
    inc r8

loop .chkloop

    mov eax, 1
    ret

.np:

    xor eax, eax
    ret

; （文本，长度）    
k1_atoi_2611:
    test rdx, rdx
    jz   .panic
    jns  .havelen

    push rcx
    adod
    shadow
    call kp_strlen
    pdod
    pop  rcx
    mov  rdx, rax



.havelen:

    test rdx, rdx
    jz   .panic

    cmp rdx, 21
    ja  .panic

    cmp byte [rcx], ('+')
    je  .positive

    cmp byte [rcx], ('-')
    je  .negative

    jmp .default

.positive:

    inc rcx
    dec rdx

.default:

    adod
    shadow
    call kp_atou
    pdod
    bt   rax, 63
    jc   .panic
    ret

.negative:

    adod
    shadow
    inc  rcx
    dec  rdx
    call kp_atou
    mov  rdx, 0x8000000000000000
    cmp  rax, rdx
    ja   .panic
    neg  rax
    pdod
    ret

.panic:
    xor eax,   eax
    mov [rax], rsp