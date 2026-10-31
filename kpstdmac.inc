;kpstdmac.inc

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