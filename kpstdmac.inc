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

; kall 函数名, 参数1, 参数2, 参数3, 参数4, 参数5, 参数6...
%macro kall 1-*
    adod
    %xdefine %%func %1

    %if %0 > 1
        mov rcx, %2
    %endif
    %if %0 > 2
        mov rdx, %3
    %endif
    %if %0 > 3
        mov r8, %4
    %endif
    %if %0 > 4
        mov r9, %5
    %endif

    %if %0 > 5
        %assign %%n %0 - 5
        %if (%%n & 1) != 0
            sub rsp, 8
        %endif
        %rep %%n
            %rotate -1
            push %1
        %endrep
    %endif

    sub rsp, 32
    call %%func
    pdod
%endmacro

; kpsh 操作数1, 操作数2, 操作数3...
%macro kpsh 1-*
    %push kpsh_ctx
    %assign %$n %0

    %rep %0
        push %1
        %rotate 1
    %endrep

    %assign %%i 0
    %rep %0
        %rotate -1
        %xdefine %$pop_%+%%i %1
        %assign %%i %%i + 1
    %endrep
%endmacro

; kpop
%macro kpop 0
    %ifctx kpsh_ctx
        %assign %%n %$n
        %assign %%i 0
        %rep %%n
            pop %$pop_%+%%i
            %assign %%i %%i + 1
        %endrep
        %pop
    %else
        %error "kpop without matching kpsh"
    %endif
%endmacro


%endif