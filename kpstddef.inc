; kpstddef.inc

%ifndef KPSTDDEF_INC
%define KPSTDDEF_INC

; "确定"按钮
MB_OK              equ 0x00000000
; 错误图标
MB_ICONERROR       equ 0x00000010
; 询问图标
MB_ICONQUESTION    equ 0x00000020
; 警告：黄三角感叹号
MB_ICONWARNING     equ 0x00000030
; 信息：蓝圆圈小写 i
MB_ICONINFORMATION equ 0x00000040

%include 'kpstdmac.inc'

%endif