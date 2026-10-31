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

