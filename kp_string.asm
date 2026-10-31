; kp_string.asm

; Copyright (c) 2026-8086 KUSSA. All rights reserved.

bits    64
default rel

section k1 code

; rcx = src
k1_strlen_2610:

    xor ax, ax

    push rdi
    mov  rdi, rcx
    mov  rcx, -1

    cld

    repne scasb
    
    not rcx
    dec rcx
    
    mov rax, rcx
    pop rdi
    ret


;查找第一个字符，返回（索引+1），如果查找的字符是\0则返回strlen
;（留空，源，源长，单字节字符）单位字节
;长度给负数自动算，但是要保证0结尾，返回0表示没找到
k1_strchr_2610:

    test rdx, rdx
    jz   .np

    mov  rcx, rdx
    test r9b, r9b
    ;来都来了
    jz   kp_strlen

    test r8, r8
    jz   .np
    jns  .havelen
    
    push rcx
    push rdx
    push r9

    sub rsp, 32

    call kp_strlen
    mov  r8, rax

    add rsp, 32

    pop r9
    pop rdx
    pop rcx

.havelen:

    mov rcx, r8
    mov al,  r9b
    mov r9,  rdx

    push rdi
    mov  rdi, rdx

    repne scasb
    jne .nf

    lea rax, [rdi]
    sub rax, r9

    pop rdi
    ret

.nf:
    pop rdi
.np:
    xor rax, rax
    ret



;标量memcmp，不检查空指针
;相等返回末尾指针，不相等返回0，并且往返回地址写偏移+1，没长度返回0 ,返回地址写0
;（源，源长，目标，返回值指针）
k1_memcmp_2610:

    test rdx, rdx
    jz   .np

    cld

    push rsi
    push rdi

    mov rsi, rcx
    mov rdi, r8

    xchg rcx, rdx

    repe cmpsb

    jne .ue

    mov rax, rdi

    pop rdi
    pop rsi

    ret

.ue:

    mov rax,  rsi
    sub rax,  rdx
    mov [r9], rax
    pop rdi
    pop rsi

    xor eax, eax
    ret

.np:

    xor eax,  eax
    mov [r9], rax
    ret
















section k5 code

;查找第一个字符，返回（索引+1），如果查找的字符是\0则返回strlen
;（留空，源，源长，单字节字符）单位字节
;长度给负数自动算，但是要保证0结尾，返回0表示没找到
k5_strchr_2610:
; 实际上是ssse3

    test rdx, rdx
    jz   .np

    mov  rcx, rdx
    test r9b, r9b
    jz   kp_strlen
    ;依旧

    test r8, r8
    jz   .np
    jns  .havelen

    push r9
    push rdx
    push rcx

    sub rsp, 32

    ;其实不用考虑对齐，因为没有栈上的simd参数
    call kp_strlen
    ;本是同根生o(*￣︶￣*)o

    add rsp, 32

    pop  rcx
    pop  rdx
    pop  r9
    test rax, rax
    jz   .np
    mov  r8,  rax

.havelen:

    cmp r8, 64
    jna k1_strchr_2610

    mov r11, r8

    movzx  r9d,  r9b
    movd   xmm1, r9d
    ;这期神了
    pxor   xmm0, xmm0
    pshufb xmm1, xmm0

    mov rcx, rdx
    mov r9,  rcx
    and rdx, -16
    sub rcx, rdx

    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    shr  r8d, cl ;除去无用掩码
    test r8,  r8
    jnz  .found  ;不为零说明找到

    test rdx, 16
    ;检查对齐32位
    jz   .ssego  ;如果第四位有，说明加上十六直接就是对齐32字节

    add rdx, 16 ;不然就还要单独处理16字节，再对齐

    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    test r8d, r8d
    jnz  .gofind

;准备工作
.ssego:
    add  rdx, 16
    ;加点小手段
    ;算已还要扫描的字节
    mov  r10, rdx
    sub  r10, r9
    mov  rcx, r11
    sub  rcx, r10
    ;秘制手法
    ;决定sse2循环次数
    test rcx, 31
    jz   .ald
    add  rcx, 32
    ;如果不对齐32字节要加一次
.ald:

    shr rcx, 5
    ;位移得出来循环次数

.sseloop:

    movdqa   xmm0, [rdx]
    movdqa   xmm2, [rdx+16]
    pcmpeqb  xmm0, xmm1
    pcmpeqb  xmm2, xmm1
    pmovmskb r8d,  xmm0
    pmovmskb eax,  xmm2
    
    shl  eax, 16   ;掩码高位
    or   r8d, eax  ;合并掩码
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
    lea rax, [rax+rdx+1]

    ret

.found:

    bsf eax, r8d
    inc eax
    ret

.ssefound:

    bsf eax, r8d
    inc eax

    sub rdx, r9
    add rax, rdx

    cmp rax, r11
    ja  .np

    ret

.np:
    xor eax, eax
    ret





























section k7 code

k7_strlen_2610:

    vpxor xmm1,xmm1,xmm1
    mov       rax, rcx
    mov       rdx, rcx
    and       rdx, -32
    vpcmpeqb  ymm0,ymm1,[rdx]
    vpmovmskb r8d, ymm0
    sub       rcx, rdx
    shr       r8d, cl
    test      r8d, r8d
    jnz       .found
    add       rdx, 32

.beforeavx:

    test      dl,  127
    je        .avxloop
    vpcmpeqb ymm0, ymm1, [rdx]
    vpmovmskb r8d, ymm0
    test      r8d, r8d
    jnz       .end
    add       rdx, 32
    jmp       .beforeavx

    align 32
.avxloop:
    vmovdqa   ymm2, [rdx]
    vpminub ymm3, ymm2, [rdx+32]
    vmovdqa   ymm4, [rdx+64]
    vpminub ymm5, ymm4, [rdx+96]
    vpminub ymm0, ymm3, ymm5
    vpcmpeqb ymm0, ymm0, ymm1
    vpmovmskb r8d,  ymm0
    add       rdx,  128
    test      r8d,  r8d
    jz        .avxloop
    sub       rdx,  128

.avxfound:
    vpcmpeqb ymm2, ymm1, [rdx]
    vpcmpeqb ymm3, ymm1, [rdx+32]
    vpmovmskb r8d, ymm2
    vpmovmskb r9d, ymm3
    shl       r9,  32
    or        r8,  r9
    test      r8,  r8
    jnz       .end
    vpcmpeqb ymm4, ymm1, [rdx+64]
    vpcmpeqb ymm5, ymm1, [rdx+96]
    vpmovmskb r8d, ymm4
    vpmovmskb r9d, ymm5
    shl       r9,  32
    or        r8,  r9
    add       rdx, 64
.end:
    vzeroupper
    sub rdx, rax
    bsf rax, r8
    add rax, rdx
    ret
.found:
    vzeroupper
    bsf eax, r8d
    ret

