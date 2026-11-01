;kpstdmac.inc

%ifndef KPSTDMAC_INC

%define KPSTDMAC_INC

%macro adod 0
    push rbp
    mov rbp , rsp
    and rsp , -16
%endmacro

%macro pdod 0
    mov rsp,rbp
    pop rbp
%endmacro    

%define L __?utf16?__

; kslf 表名, 槽位名, 实现符号
%macro kslf 3
    lea rdx, [%1.%2]
    lea rax, [%3]
    mov [rdx], rax
%endmacro

; ksjf 表名, 函数名，前缀
%macro ksjf 3
%3_%2:
    jmp qword [%1.%2]
%endmacro

%endif