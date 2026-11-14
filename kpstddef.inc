; kpstddef.inc

%ifndef KPSTDDEF_INC
%define KPSTDDEF_INC

; “确定”按钮
MB_OK              equ 0x00000000
; 错误图标
MB_ICONERROR       equ 0x00000010
; 询问图标
MB_ICONQUESTION    equ 0x00000020
; 警告：黄三角感叹号
MB_ICONWARNING     equ 0x00000030
; 信息：蓝圆圈小写 i
MB_ICONINFORMATION equ 0x00000040
; 确认取消
MB_OKCANCEL        equ 0x00000001
; 是  否
MB_YESNO           equ 0x00000004
; 返回“确定”
IDOK               equ 0x00000001
; 返回“取消”
IDCANCEL           equ 0x00000002
; 返回“是”
IDYES              equ 0x00000006
; 返回“否”
IDNO               equ 0x00000007

%include 'kpstdmac.inc'

%endif