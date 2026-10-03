;kpstdlib.asm

;KUSSA_LTSC 2026 保留所有权利

;旧版声明保留：

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-scancode-kudos-sal-2.5

;KUSSA's standard library
;源码可见，仅供免费教育研究和学习
;注释以后再补充吧

;这是什么：一个NASM项目（废话）
;用来干嘛：为了用来写C代码
;你为啥要看：关我屁事
;能从里面学到东西吗：能，但是我还没补完注释
;它可能不像网上其它教程那么模范
;它更倾向于8086时代的老式写法
;对于x86-64架构的指令集做出了决策和取舍
;比起8086少了诸多限制
;这是初学者版本吗：不是，我建议你先学别的语言或者先去看别的汇编教程
;这是初学者版本吗：是的，这里几乎可以遇到大部分初学者容易错和迷惑的地方
;能从中学到什么：很多，看你咋学
;它标准化吗：从调用约定上来讲基本符合微软x64ABI
;但是它的写法可能比较诡异
;看不懂咋办：不看，或者你去问AI
;是完全手写的吗：是的，可能让AI帮我做了一些参数上的检查，比如我曾经把GetFileSizeEx打错字成GetFileSizeEX
;我经常让AI帮我看编译和链接报错，辅助查询intel SDM PDF
;它好用吗：不一定，但是除了win32api封装以外都会返回NULL代表失败
;NULL是个常量，等于零
;怎么考虑更新内容的：我需要啥我就写啥
;（事实上一个月过去了我的日志功能要用的函数都还没写完
;它能替代CRT吗：现在能做不少事情，但是还不能完全替代
;为啥要封装系统api：因为和windows.h不一定兼容，为了让我更好记住，为了能方便维护和移植，为了写程序更方便
;再说你为啥要学汇编：它能让你更好理解代码的工作，以及解决非常多匪夷所思的BUG
;但是学习汇编对于大多数人来讲并不容易
;我是例外，我反而写C代码总是出问题，还不会修BUG
;它性能会比CRT更好吗：不会，差不多，可能某些激进的函数会快一点点点
;总之你要有一定的编程基础，而且你要能够有耐心去了解8086的指令或者x86的指令才能看懂大部分，注释不是保姆，只会写出来最重要的，容易错的
;警告：内部函数，未完成函数，永远不能被导出，也不应该被修改，只是为了方便代码复用，用于特定场景下的业务服务


;bash:

;nasm -f win64 .\kpstdlib.asm -o .\kpstdlib.obj 
;gcc -o test.exe test.c kpstdlib.obj -nostdlib -lkernel32 -luser32 -mwindows -e main -ffreestanding -fno-stack-protector -fno-asynchronous-unwind-tables -O2

;新版声明：

; Copyright (c) 2026-8086 KUSSA (KUSSA_LTSC)
; All rights reserved.
;
; SPDX-License-Identifier: LicenseRef-KUDOS-Source-Available-2.5
;
; KUSSA's standard library
; This is NOT an open source license. This is a source-available,
; anti-commercial license.
;
; 本文件仅按 KUDOS SOURCE AVAILABLE LICENSE Version 2.5 授权。
; 完整条款见项目根目录：
; KUDOS SOURCE AVAILABLE LICENSE.txt
;
; 未经项目所有者事先纸质书面同意，禁止：
; - 商业使用、营利实体使用、营利实体评估或测试；
; - 将本软件或修改版分发、公开、上传、分享给任何第三方；
; - 与商业相关捆绑包组合、链接或一起分发；
; - 使用本软件训练、微调、蒸馏、评估任何 AI 或机器学习模型。
;
; 允许的用途仅限许可证明确规定的：
; - 个人私人学习；
; - 非营利组织对原始未修改软件的内部行政使用；
; - 主流在线平台上的公开免费课程；
; - 按第 1.4 条进行的非商业研究、同行评审和论文发表。
;
; 配置文件如不含源代码、脚本、二进制或可执行逻辑，可以公开共享。

;代码往下

; %include 'third.inc'
%include 'kmarco.inc'

;宏展开放这里了别再问我啦！
;就是开头的宏文件里面的，我自己写的
;看到这两行不用纠结，看不懂没关系
;默认栈对齐16自己就行

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
; SPDX-License-Identifier: LicenseRef-scancode-kapivara-sal-1.0

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

; 等价于pdod
; %macro kaak 0
;     mov rsp, rbp
;     pop rbp
; %endmacro

bits    64
default rel

;立项日期无从考究，但是可以确定在2026年8月26日及以前

;虽然也是个教学用的性能没必要太好，但是还是想要追求完美一些
;为了方便调试和写，寄存器非必要全用r64
;标签都是瞎几把写的因为我英文不好

global  bu
; global  realseconds
; global  realminutes
; global  realhours
; global  realdays
; global  realmonth
; global  realyears
global  dlsbur
; 这个可以自定义符号
; global  kp_prtnum_frmstk_wthrcx_rep_fastcall_win64
global  kp_replace_single_dollar_symbol_wthcnt_fastcall_win64
global  kp_filetime_to_realtime_frmrax_ret_fastcall_win64
global  kp_win32api_get_file_pointer_ex_fastcall_win64
global  kp_win32api_set_file_pointer_ex_fastcall_win64
global  kp_win32api_get_file_size_ex_fastcall_win64
global  kp_win32api_close_handle_fastcall_win64
global  kp_win32api_createfile_w_fastcall_win64
global  kp_win32api_ezutf8t16le_fastcall_win64
global  kp_win32api_write_file_fastcall_win64
global  kp_win32api_read_file_fastcall_win64
global  kp_win32api_msgbox_w_fastcall_win64
global  kp_text_format_divide_fastcall_win64
global  kp_strcpy_enddls_fastcall_win64
global  kp_prtnum_frmrcx_fastcall_win64
global  kp_avx2_strlen_fastcall_win64
global  kp_sse2_strlen_fastcall_win64
global  kp_strlen_simd_fastcall_win64
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
    ;数据先丢这里
    bu:
    times 22  db 0
    date:
    times 256 db 0 ;日期文本
    date_end:  
    
    datelen equ (date_end - date)
    
    wasteimm dq 0

    days        dq 0 ;总天数
    seconds     dq 0 ;总秒数
    tempyears   dq 0 ;年数暂存
    tempdays    dq 0 ;天数暂存
    nboffhys    dq 0 ;400年的数量
    nbofohys    dq 0 ;100年的数量
    nboffoys    dq 0 ;4年的数量
    nbofovys    dq 0 ;多出的年数
    overdays    dq 0 ;多出的天数
    realyears   dq 0 ;年份
    realmonth   dq 0 ;月份
    realdays    dq 0 ;天数
    realhours   dq 0 ;小时
    realminutes dq 0 ;分钟
    realseconds dq 0 ;秒数
    
    ;年份常量，1600年
    aoeg        equ 50491123200
    ;北京时间时差
    UTC8_OFFSET equ 28800
   ;禁用北京时间的filetime减法数
    unboeg equ UTC8_OFFSET*10000000
    ;加上北京时间时差的年份常量
    boeg   equ aoeg+UTC8_OFFSET
    
    ;占位垃圾
    dust times 128 db 0

    ;月表
    mthcom             db  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    mthlep             db  31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    ;时间常量
    seconds_per_day    equ 86400
    days_per_4_years   equ 1461
    days_per_100_years equ 36524
    days_per_400_years equ 146097
    ;新增$替换缓冲区
    dlsbur:
        times 8 db 0
    dlsbur_end:
    
    dlsbur_len equ (dlsbur_end-dlsbur)

    align 16
    hex2ascii_xlatable db '0123456789ABCDEF'

    align 16
    ;神人ascii2hex表
    ascii2hex_xlatable:
    times 48  db 0                       ; 0x00-0x2F 非法区
    db           0,1,2,3,4,5,6,7,8,9     ; 0x30-0x39  '0'-'9'
    times 7   db 0                       ; 0x3A-0x40  '9'到'A'之间
    db           0xA,0xB,0xC,0xD,0xE,0xF ; 0x41-0x46  'A'-'F'
    times 26  db 0                       ; 0x47-0x60  'F'到'a'之间
    db           0xA,0xB,0xC,0xD,0xE,0xF ; 0x61-0x66  'a'-'f'
    times 153 db 0                       ; 0x67-0xFF 非法区


; 神秘常量，提取自windows.inc

; ==================== 通用 ====================
; 空内容、空指针
NULL                  equ 0
; 真
TRUE                  equ 1
; 假
FALSE                 equ 0
; 窗口位置的默认值，让系统自己选
CW_USEDEFAULT         equ 0x80000000
; 无限等待
INFINITE              equ 0xFFFFFFFF

; ==================== 窗口类样式 ====================
; 窗口垂直方向变化时重绘
CS_VREDRAW            equ 0x0001
; 窗口水平方向变化时重绘
CS_HREDRAW            equ 0x0002

; ==================== 窗口样式 ====================
; 重叠窗口（默认无边框）
WS_OVERLAPPED         equ 0x00000000
; 弹出式窗口
WS_POPUP              equ 0x80000000
; 子窗口
WS_CHILD              equ 0x40000000
; 窗口可见
WS_VISIBLE            equ 0x10000000
; 有标题栏
WS_CAPTION            equ 0x00C00000
; 有边框
WS_BORDER             equ 0x00800000
; 有系统菜单（左上角图标）
WS_SYSMENU            equ 0x00080000
; 可调整大小的边框
WS_THICKFRAME         equ 0x00040000
; 有最小化按钮
WS_MINIMIZEBOX        equ 0x00020000
; 有最大化按钮
WS_MAXIMIZEBOX        equ 0x00010000
; 标准重叠窗口：标题栏+系统菜单+可缩放+最小化+最大化
WS_OVERLAPPEDWINDOW   equ WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX

; ==================== ShowWindow ====================
; 隐藏窗口
SW_HIDE               equ 0
; 正常显示
SW_SHOWNORMAL         equ 1
; 最小化显示
SW_SHOWMINIMIZED      equ 2
; 最大化显示
SW_SHOWMAXIMIZED      equ 3
; 按最近状态显示
SW_SHOW               equ 5
; 从最小化/最大化恢复
SW_RESTORE            equ 9

; ==================== 窗口消息 ====================
; 窗口创建
WM_CREATE             equ 0x0001
; 窗口销毁
WM_DESTROY            equ 0x0002
; 窗口大小改变
WM_SIZE               equ 0x0005
; 需要重绘
WM_PAINT              equ 0x000F
; 关闭请求
WM_CLOSE              equ 0x0010
; 退出消息循环
WM_QUIT               equ 0x0012
; 键盘按下
WM_KEYDOWN            equ 0x0100
; 键盘抬起
WM_KEYUP              equ 0x0101
; 字符输入
WM_CHAR               equ 0x0102
; 菜单/控件命令
WM_COMMAND            equ 0x0111
; 定时器触发
WM_TIMER              equ 0x0113
; 鼠标移动
WM_MOUSEMOVE          equ 0x0200
; 左键按下
WM_LBUTTONDOWN        equ 0x0201
; 左键抬起
WM_LBUTTONUP          equ 0x0202
; 右键按下
WM_RBUTTONDOWN        equ 0x0204
; 右键抬起
WM_RBUTTONUP          equ 0x0205

; ==================== 消息框 ====================
; 只有一个"确定"按钮
MB_OK                 equ 0x00000000
; "确定"+"取消"
MB_OKCANCEL           equ 0x00000001
; "是"+"否"
MB_YESNO              equ 0x00000004
; 错误图标
MB_ICONERROR          equ 0x00000010
; 问号图标
MB_ICONQUESTION       equ 0x00000020
; 警告图标
MB_ICONWARNING        equ 0x00000030
; 信息图标
MB_ICONINFORMATION    equ 0x00000040

; ==================== 消息框返回值 ====================
; 用户点了"确定"
IDOK                  equ 1
; 用户点了"取消"
IDCANCEL              equ 2
; 用户点了"是"
IDYES                 equ 6
; 用户点了"否"
IDNO                  equ 7

; ==================== 系统资源 ====================
; 标准箭头光标
IDC_ARROW             equ 32512
; 标准应用图标
IDI_APPLICATION       equ 32512

; ==================== 颜色 ====================
; 窗口背景色（白）
COLOR_WINDOW          equ 5
; 按钮表面色（灰）
COLOR_BTNFACE         equ 15

; ==================== 内存 ====================
; 提交：分配物理存储
MEM_COMMIT            equ 0x1000
; 保留：只占地址空间，不分配物理存储
MEM_RESERVE           equ 0x2000
; 取消提交，保留地址
MEM_DECOMMIT          equ 0x4000
; 完全释放（地址+存储）
MEM_RELEASE           equ 0x8000
; 不可访问
PAGE_NOACCESS         equ 0x01
; 可读可写
PAGE_READWRITE        equ 0x04

; ==================== 文件 ====================
; 读取权限
GENERIC_READ          equ 0x80000000
; 写入权限
GENERIC_WRITE         equ 0x40000000
; 创建新文件，已存在则失败
CREATE_NEW            equ 1
; 总是创建，已存在则覆盖
CREATE_ALWAYS         equ 2
; 只打开已存在的文件
OPEN_EXISTING         equ 3
; 打开已存在的，不存在则创建
OPEN_ALWAYS           equ 4
; 打开已存在的并清空
TRUNCATE_EXISTING     equ 5
; 普通文件属性
FILE_ATTRIBUTE_NORMAL equ 0x80
; 无效句柄（API 失败返回值）
INVALID_HANDLE_VALUE  equ -1
; 从文件头开始
FILE_BEGIN            equ 0
; 从当前位置开始
FILE_CURRENT          equ 1
; 从文件尾开始
FILE_END              equ 2
; 允许其他进程读
FILE_SHARE_READ       equ 1
; 允许其他进程写
FILE_SHARE_WRITE      equ 2
; 允许其他进程删除
FILE_SHARE_DELETE     equ 4
; 标准输入句柄
STD_INPUT_HANDLE      equ -10
; 标准输出句柄
STD_OUTPUT_HANDLE     equ -11
; 标准错误句柄
STD_ERROR_HANDLE      equ -12


;代码段
section .text

;strlen
;第一个函数？
;很老套的写法，后面有4个SIMD示例
kp_strlen_fastcall_win64:
;只有一个参数，rcx放字符串起始，返回rax，单位字节    
    xor  rax, rax
    ;rax=0用来查找\0
    push rdi
    mov  rdi, rcx
    mov  rcx, -1

    cld;清除方向标志

    repne scasb;重复，不相等就继续扫描比对al和[rdi]
    or  rcx, rcx
    ;这个纯纯8086后遗症，如果rcx=0说明没有找到或者刚好落到，但是x64的寄存器很大，所以没有特别的处理
    jz  .nofind
    not rcx      ;取反
    dec rcx      ;减一
    ;这样就能得到长度了，原理是因为二进制特性
    mov rax, rcx
    pop rdi
    ret

.nofind:
    xor rax, rax
.ret:
    pop rdi
    ret

;已经废弃了，单纯留在这里留档，附上栈图
;8086时代函数，当时用来批量输出数字字符串，但是我发现在x64上不好用
;！警告：未完成函数，千万不要使用！
kp_prtnum_frmstk_wthrcx_rep_fastcall_win64:
;子程序，默认已经对齐，而且没有寄存器传递参数
;目前还没做RAX传递参数的功能
;rcx是0的话说明没有数字，直接退出
    or   rcx, rcx ;.....[STACK].....
    jz   .exit    ;NUM2       RBP+56
    push rbp      ;NUM1       RBP+48
    mov  rbp, rsp ;SHADOW 4
    push rsi      ;SHADOW 3
    push rcx      ;SHADOW 2
    push rax      ;SHADOW 1
    push rbx      ;RET        RBP+8
    push rdx      ;RBP    0   RBP+0
    push rdi      ;RBP指向原来RBP的PUSH
;保存所有用到的
    ;PREPROCE

    xor rsi, rsi
    xor rdi, rdi

;整体循环转化输出
.lb_tltp:

    mov rax, [rbp+rsi+48] ;读栈上数字
;新增检查负数
    ; test rax, 0x8000000000000000
    ; 好吧x64不能直接写64位imm除了mov
    ; jz   .np
;改成更短的写法
    or  rax, rax
    jns .isnotnegative
;不是负数就跳过
    mov byte [bu], 45 ;负数符号的ASCII
    inc rdi
;负数转正
    neg rax
;标号：不是负数
.isnotnegative:
    mov  rbx, 10
    push rcx
    xor  rcx, rcx
;除法循环，每次除以10得到个位数字大小
.divlop:
    inc  rcx      ;STACK
    xor  rdx, rdx ;ori_rcx,rcx*rdx
    div  rbx
    push rdx
    or   rax, rax
    jz   .preprt

    jmp .divlop
;准备打印
.preprt:

    lea rbx, [bu]
;打印循环（其实是写入内存）
.lre:

    pop rdx
    add rdx,       48
    ;变成ASCII并且写入
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .lre

;这里rdx会全部pop，rsp指向ori_rcx

    ; inc rdi
    mov byte [rbx+rdi], 0
    ;末尾补上0

;这里应该调用输出bu，但是还没做

;初始化准备下一轮循环

    xor rdi, rdi
    add rsi, 8
    pop rcx

    dec rcx
    jnz .lb_tltp

    

;rcx=0,rsp指向ori_rdi

    pop rdi
    pop rdx
    pop rbx
    pop rax
    pop rcx
    pop rsi
    pop rbp

;按理来讲应该留个AX放返回值，但是实际上我懒得

.exit:
    ret


;待定议程，参数，比如RAX可以说明是否启用有符号，是否启用地址回写，如果启用，地址默认起始RBX，我也不知道64位有没有能够专门隔着写的文字命令，以前我记得可以直接设定方向，间隔，然后放文字就行
;现在没有待定了，这个函数被废弃了，现在是x64而不是8086
;再次声明这个函数被废弃了，当广告看就行（2026年10月3日）

;内部函数，C不能直接用，8086代码移植
;单独打印rax，给日志功能用，应该不会破坏任何寄存器
;破坏RAX返回
kp_prtnum_frmrax:
;默认rax已经赋值
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;检查负数
    jns  .isnotnegative ;不是负数就跳过
    mov  byte [bu], 45  ;负数符号的ASCII
    
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
    or   rax, rax
    jz   .preprt
    jmp  .divlop
;打印准备
.preprt:
    lea rbx, [bu]
    ;先打印到bu，这里加载地址
;写数字循环
.loopofrewrite:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .loopofrewrite

    ; inc rdi ; 这个inc不能写
    mov byte [rbx+rdi], 0

    lea rax, [bu]
    ;返回地址

    pop rbx
    pop rdx
    pop rcx
    pop rsi
    pop rdi

    ret

;算出来日期，从参数3到参数8返回年份，月份，日子，小时，分钟，秒数（为啥这里会有这个）
;（这行注释就明明白白写在kp_filetime_to_realtime_frmrax_ret_fastcall_win64函数开头）
;（其实是移动时候忘了删，当彩蛋吧）（2026年10月3日）

;单独打印rcx，这下C代码能用的
;滚木函数，哈哈，这才是最短的一个
kp_prtnum_frmrcx_fastcall_win64:
    mov rax, rcx
    jmp kp_prtnum_frmrax

;文本复制，带检查（实际没有用的检查）
;rcx放源指针，rdx放源长度，r8放目标指针，r9放目标长度，单位均为字节
;返回末尾0指针，rdx为负数自动算
kp_strcpy_fastcall_win64:
    
    or rcx, rcx
    jz .mgd
    or r8,  r8
    jz .mgd
    ;据说有空指针

    or   rdx, rdx
    jns  .havesrclen
    push rcx

    call kp_strlen_fastcall_win64 ;第一个函数
    ;没有破坏寄存器所以能直接用，但是如果用后面的SIMD版本可能会破坏寄存器，要保存
    mov  rdx, rax                 ;返回值在rax，调用约定

    pop rcx

.havesrclen:

    cmp rdx, r9
    jae .mgd
    ;如果源比目标长就退出
    ;不检查rcx是不是0了因为0也没事
    ; push rbp
    ; mov  rbp, rsp
    ; 栈帧用不上了现在

    cld

    push rsi
    push rdi

    mov rsi, rcx ;源
    mov rdi, r8  ;目标
    cmp rdx, 15  ;不同长度的分支
    ja  .msq
    mov rcx, rdx
    rep movsb

    mov byte [rdi], 0

    jmp .normal

.msq:
    mov rcx, rdx
    shr rcx, 3
    rep movsq;老CPU上的movsq比movsb更快，但是实际上所有x64都有SSE2
    mov rcx, rdx
    and rcx, 7
    rep movsb

    mov byte [rdi], 0 ;末尾补0
    
.normal:
    ; sub rdi, r8
    ; mov rax, rdi
    ; 注释这样是返回长度，没意义，等于srclen
    mov rax, rdi
    ;返回指针
    pop rdi
    pop rsi
    ret

.mgd:
    xor rax, rax ;0代表失败，或者长度为0
    ; mov rsp, rbp
    ; pop rbp
    ret

db '少羽牛逼' ;这个是签名，也就是特征，这4个字会被原封不动放进exe里面，以后要检查这个函数直接就是x64dbg里面搜特征就能定位到这里

;输入rcx，可以用系统提供时间GetSystemTimeAsFileTime
;传入参数：rcx放时间由系统提供，1个地址用来返回纯文本的紧凑时间
;例如：20260905220631_134330908XXXXXXXXX\0
;剩下6个地址分别是年月日时分秒的内存指针
;void(imm64,immmem64ptr,mem64addr*6)
kp_filetime_to_realtime_frmrax_ret_fastcall_win64:
;当时设计上就有问题，当时只考虑北京时间，而没有考虑一口气做成UTC偏移
;而且当时也没考虑结构体，所以就很狼狈
;如果你传空指针的话，程序不会崩溃，只是不会返回东西，是的，当初就没有考虑返回值，因为用不上，或者说我没有想过怎么可能会失败
;最大工程的函数我只能说

; ...STACK_TABLE...
; P8秒    RBP+72
; P7分    RBP+64
; P6时    RBP+56
; P5日    RBP+48
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
    mov  rbp, rsp ;到时候用来get参数
    push rbx
    push rsi
    push rdi
    push r15

    ; xor rsi, rsi
    ; mov rdi, 7
    ;展开就用不上这两行

;检查空指针，虽然说展开性能更好，好吧那就展开吧
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
    ;已经保存了所有参数，前面4个在影子空间
    mov rax,      rcx

    xor rbx, rbx ;这行干嘛用的我也忘了，其实没用（对就是没用，留着当彩蛋）（2026年10月3日）
    
    ;修改，但是行为基本不变
    ;让ft=0时候也能正确返回
    mov r10, unboeg
    add rax, r10

    ;先换成秒
    mov rcx, 10000000
    xor rdx, rdx
    div rcx
    mov rcx, aoeg
    add rax, rcx
    xor rdx, rdx
    ;现在rax就是总秒数
    mov rcx, seconds_per_day
    div rcx
    
    ;rax=天数，rdx=剩余秒数
    ;看不懂就去查SDM
    mov [days],     rax
    mov [seconds],  rdx
    mov rcx,        days_per_400_years ;先算有多少完整400年
    xor rdx,        rdx
    div rcx
    mov [nboffhys], rax
    mov rax,        rdx
    mov rcx,        days_per_100_years ;继续除以100年
    xor rdx,        rdx
    div rcx
    mov [nbofohys], rax
    mov rax,        rdx
    mov rcx,        days_per_4_years   ;算有多少个4年
    xor rdx,        rdx
    div rcx
    mov [nboffoys], rax
    mov [tempdays], rdx
    ;剩下的天数
    
    imul rax,[nboffhys],400
    mov [tempyears], rax
    imul rax,[nbofohys],100
    add [tempyears], rax
    imul rax,[nboffoys],4
    add [tempyears], rax
    ;现在所有除了不到4年的部分已经算完了

;先比较闰年必要
    mov rax, [tempdays]
    cmp rax, 1460
    je  .skipdivy
    ;这个标号在后面
    mov rcx, 365
    xor rdx, rdx
    div rcx

;1460天直接传送门走这里    
.skipdivn:    
    
    ;保存剩余年数和天数
    mov [nbofovys],  rax
    mov [overdays],  rdx
    mov r9,          rax
    inc rax
    add rax,         [tempyears]
    mov [realyears], rax
    ; mov rax,         r9

    ; 被AI气死了给AI写的注释
    ; tempyears = 绝对年份-1 - ((绝对年份-1) mod 4)
    ; = 当前4年周期起点 - 1（不是绝对年份！）
    ; 例：2000 -> 1996，2001 -> 2000，1900 -> 1896
    ; 用途：拿 tempyears 和 tempyears+4 比 /100、/400
    ;   相等 -> 没跨界；不等 -> 跨界，继续查 400
    ; 绝对年份 = tempyears + 1 + nbofovys（当前周期内已过完整年数）

    ;现在算有没有世纪平年

    lea rbx, [mthlep]
    lea rcx, [mthcom]
    ;VS code里面光标放上去就能知道标号上面的注释（需要插件）

    ; cmp    rax, 3
    cmp    r9,  3
    cmovne rbx, rcx
    jne    .lepsub

    ;剩下就要考虑闰年
    mov   rax, [tempyears]
    mov   r9,  rax
    ;先复制一份rax，r9就是rax的原来tempyears
    mov   rcx, 100
    xor   rdx, rdx
    div   rcx
    mov   r8,  rax
    ;保存第一次结果
    mov   rax, r9
    add   rax, 4
    xor   rdx, rdx
    div   rcx
    cmp   rax, r8
    ;与第一次结果比较
    ;这里还是闰年表
    je    .lepsub
    ;不相等说明有世纪年
    ;现在检查有没有400年闰年
    mov   rcx, 400
    xor   rdx, rdx
    mov   rax, r9
    div   rcx
    mov   r8,  rax
    ;保存第一次结果
    xor   rdx, rdx
    mov   rax, r9
    add   rax, 4
    div   rcx
    cmp   rax, r8
    ;比较，相等说明不是400年，而是世纪平年
    lea   rbx, [mthlep]
    lea   rcx, [mthcom]
    cmove rbx, rcx

;代码复用这一块
;算月份的减法
;这个期待rax等于多出来的天数，已经下面初始化有

.lepsub:
    mov rax, [overdays]
    xor rcx, rcx
    xor rsi, rsi

.leplop:
    inc   rcx
    ;真的还有人记得rsi已经清零了吗（原来是在开头）
    ;好了现在改成提前清零
    movzx rdx, byte [rbx+rsi]
    inc   rsi
    cmp   rax, rdx
    ; jge   .lepsub
    jb    .edlepsub
    sub   rax, rdx
    jmp   .leplop

.edlepsub:    
    ;rax=剩余天数，rcx等于月份
    inc rax
    ;这里是没过完的一天，所以加上
    mov [realdays],  rax
    mov [realmonth], rcx

;至此年月日已经算完了，接下来是时分秒  
    mov rax, [seconds]
    xor rdx, rdx
    mov rcx, 3600
    div rcx

    mov [realhours], rax
    
    ;现在rdx的剩余秒数给到rax
    xchg rax, rdx
    xor  rdx, rdx
    mov  rcx, 60
    div  rcx

    mov [realminutes], rax
    mov [realseconds], rdx

;现在输出返回值

    lea rbx, [date] ;目前默认输出到这里

    ;rbx已经做好输出准备
    
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
    ;计算剩余长度并且放入r9
    mov  rax, [r15+rsi]
    call kp_prtnum_frmrax_intime
    call kp_strcpy_enddls_fastcall_win64
    ;这个函数返回rax是末尾地址
    add  rsi, 8
    dec  rdi
    jnz  .reprtlop
    ;8086时代还是习惯循环来压缩代码，不过现在理论上可以展开性能更好

;现在时间已经拼接完成

    lea rcx, [bu]
    mov rdx, -1
    mov r8,  rax
    sub rax, rbx
    mov r9,  datelen
    sub r9,  rax
    ;计算剩余长度并且放入r9

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
    ;计算剩余长度并且放入r9
    mov  rax,  [rbp+16]
    ;现在rax就是filetime
    call kp_prtnum_frmrax
    call kp_strcpy_enddls_fastcall_win64
    
;新增的改写$
    mov rcx, 0x007D3B3A3A5F2D2D
    ;等于('--_::;}',0)
    ;小端序要倒过来写
    ;小更新，现在有了}的结尾

    mov [dlsbur], rcx ;这个是另一个函数的事情的参数

;r9长度要自己给
    lea  rcx, [date]
    call kp_strlen_fastcall_win64
    mov  r9,  rax

    lea rcx, [dlsbur]
    mov rdx, -1
    lea r8,  [date]

    call kp_replace_single_dollar_symbol_wthcnt_fastcall_win64
    ;我觉得应该不会失败，也没啥好检查的

    mov rcx,   [rbp+24]
    lea rdx,   [date]
    mov [rcx], rdx
    ;已经回写文本日期

    xor rsi, rsi
    mov rdi, 6

.reback:

    mov rcx,   [rbp+rsi+32]
    mov rdx,   [r15+rsi]
    mov [rcx], rdx
    add rsi,   8
    dec rdi
    jnz .reback

;返回过程

;空指针返回
.nulptr:

    pop r15
    pop rdi
    pop rsi
    pop rbx
    pop rbp

    ret

;1460天特殊处理标号
.skipdivy:
    mov rax, 3
    mov rdx, 365
    jmp .skipdivn

db 'This_is_a_sentence.' ;依旧标记

;我去终于写完了这玩意，日期函数用了我三个星期    
;算出来日期，从参数3到参数8返回年份，月份，日子，小时，分钟，秒数
;这玩意折磨我三个星期（结束于2026年9月13日）

;文本复制，带检查（实际没有用的检查）
;和strcpy唯一不同的就是
;结尾是'$\0'
;rcx放源指针，rdx放源长度，r8放目标指针，r9放目标长度，单位均为字节
;返回末尾0指针，rdx为负数自动算
kp_strcpy_enddls_fastcall_win64:
    
    or   rcx, rcx
    jz   .mgd
    or   r8,  r8
    jz   .mgd
    ;据说有空指针
    or   rdx, rdx
    jns  .busu
    push rcx
    call kp_strlen_fastcall_win64 ;不要随便换成别的strlen，不然你要保存寄存器
    mov  rdx, rax
    pop  rcx
.busu:   
    lea r10, [rdx+1] ;检查需要的大小
    cmp r10, r9
    jae .mgd
    ;如果源比目标长就退出
    ;不检查rcx是不是0了因为0也没事
    ; push rbp
    ; mov  rbp, rsp
    ; 用不上了现在

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

    ; mov byte [rdi], 0 ; 这个是strcpy剩下的，改成了下面的
    ; mov ah,    0
    ; mov al,    ('$')
    mov ax,    0x0024
    ;一次性写$\0
    mov [rdi], ax
    inc rdi
    ;现在rdi指向\0

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
    ;返回指针
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

;替换所有$为自定义ASCII符号，目前限制8个
;(源，源长，目标，目标长)
;以0结尾的源，源长为负数自动算
;源长也是符号替换的数量（相当于）
;不返回指针，返回当bool，不固定值
kp_replace_single_dollar_symbol_wthcnt_fastcall_win64:
    push rbp
    mov  rbp, rsp
    push rsi
    push rdi
    
    or r9, r9
    jz .error
    ;目标长为0那还说啥

    or   rdx, rdx
    jns  .havelen
    mov  r10, rcx
    ;备份rcx
    call kp_strlen_fastcall_win64
    cmp  rax, dlsbur_len
    ja   .error
    mov  rdx, rax
    mov  rcx, r10
    ;恢复rcx

.havelen:
    cmp rdx, 8
    ja  .error
    ;修改，现在最多替换8个，因为我给的缓冲区就这么点
    ;2026年9月24日
    mov rsi, rcx
    ;现在rsi指向源
    mov rdi, r8
    mov rcx, r9
    ;现在rcx就是长度了

.replop:    
    mov al, ('$')
    mov ah, [rsi]

    cld
    repne scasb;扫描
    jne .exit ;这里只有rcx=0或者找到了才会执行，如果标志是不相等，说明没找到，因为设置了长度，所以不会越界

    mov [rdi-1], ah
    inc rsi
    dec rdx

    or  rdx, rdx
    jz  .exit
    or  rcx, rcx
    jnz .replop

.exit:

;总之rax成功不返回空

    pop rdi
    pop rsi
    pop rbp
    
    ret
    
.error:
    xor rax, rax
    jmp .exit


;内部函数，仅限日期功能用    
;破坏RAX作为返回值
kp_prtnum_frmrax_intime:
;默认rax已经赋值
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;检查负数
    jns  .np            ;不是负数就跳过
    mov  byte [bu], 45  ;负数符号的ASCII
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
    ;先打印到bu
.lre:
    pop rdx
    add rdx,       48
    mov [rbx+rdi], dl
    inc rdi
    dec rcx
    jnz .lre

    ; inc rdi
    mov byte [rbx+rdi], 0

;数据处理，给日期函数用来对齐
;如果rsi不等于0就保留2位
    ; mov  rsi,   [rbp+32]
    test rsi,   rsi
    jz   .sk
    mov  ax,    [rbx]
    test ah,    ah
    jnz  .sk
    xchg ah,    al
    mov  al,    ('0')
    mov  [rbx], ax
    xor  rax,   rax

    mov [rbx+2], al
    ;结尾补0

.sk:

    lea rax, [bu]
    ;返回地址

    pop rbx
    pop rdx
    pop rcx
    ; pop rsi
    pop rdi
    ret

;末尾拼接字符串，4个参数
;（源，源长，目标起始，目标缓冲区长）
;源长度为负数时候自动算
;返回末尾\0指针，失败返回0
kp_strend_fastcall_win64:

    ;检查空指针和0长度
    test rcx, rcx
    jz   .nullet
    test r8,  r8
    jz   .nullet
    test r9,  r9
    jz   .nullet
    test rdx, rdx
    jz   .nullet

    ;正片开始

    mov r10, rcx ; 备份源指针
    mov rcx, r8  ; rcx = dst，给内部 strlen 用
    
    call kp_strlenled_inside
    ; 返回：rax = 目标末尾\0指针，rcx = 目标当前长度

    sub rcx, r9 ; 当前长度 - 总容量
    neg rcx     ; 取反，得到剩余空间
    js  .nullet ; 如果为负，说明目标空间已满，直接跑路

    mov r9,  rcx
    mov rcx, r10

;神秘标号
.noauto:   

    ;现在可以开始复制字符串
    
    mov r8, rax ; r8 = 目标末尾的 \0 地址
    
    call kp_strcpy_fastcall_win64
    
    ret

;空指针和长度不够退出
.nullet:
    xor rax, rax
    ret

;字符串末尾
;只有一个参数，rcx放字符串起始，返回rax指向\0，失败返回0
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

;内部函数，仅供内部使用
;破坏rax，rcx，分别返回长度和末尾
kp_strlenled_inside:
;只有一个参数，rcx放字符串起始，返回rax指向\0，rcx返回长度，失败均返回0
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

;利用系统API快速转UTF8为UTF16le
;int(src,srclen,dst,dstlen)单位均为字节
;不检查，直接就用API返回值*2
;如果你传入的是strlen不含\0的话你要最后自己补0
;我建议长度直接填-1
kp_win32api_ezutf8t16le_fastcall_win64:
    
    adod

    shr  r9,  1
    push r9
    push r8
    sub  rsp, 32
    ;影子空间
    mov  r9,  rdx
    mov  r8,  rcx
    mov  rcx, 65001
    xor  rdx, rdx

    call MultiByteToWideChar

    shl rax, 1

    pdod

    ret

;时间函数的简短输入版本，依旧当初没考虑返回值
;void(filetime,快速字符串地址,结构体地址起始,禁用北京时间
;关于禁用北京时间（0的话就不管，如果是非0的话就给UTC时间）
kp_timefmt_fastcall_win64:    

    adod

    test rdx, rdx
    jz   .nodx    ;给一个没用的8字节，防崩
.oudx:

    push rbx
    push rdi
    push r9
    push rdx
    mov  rbx, rcx

    test r9,  r9     ;检查时间标志
    jz   .enboeg
    mov  r10, unboeg ;回退UTC时间
    sub  rcx, r10
;启用北京时间直接跳
.enboeg:

    or  r8, r8
    jnz .normal
    lea r8, [dust]

.normal:

    adod

    ;传参大队
    lea  r10, [r8+40]
    push r10
    lea  r10, [r8+32]
    push r10
    lea  r10, [r8+24]
    push r10
    lea  r10, [r8+16]
    push r10
    lea  r9,  [r8+8]
    
    ;影子空间
    sub rsp, 32
    
    call kp_filetime_to_realtime_frmrax_ret_fastcall_win64

    pdod

;回写filetime

    ;前面有个push rdx
    pop  rdi
    pop  r9
    test   r9,  r9
    jz   .nore
    test   rdi, rdi
    jz   .nore
    ;接下来是重新覆写回去真正的filetime
    mov  rdi, [rdi]
    mov  al,  ('{')
    mov  rcx, -1
    cld
    repne scasb
    jne  .nore
    mov  rax, rbx
    ;现在rax就是filetime
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

    ;我知道这函数就是一坨屎
    ;但是没有办法，因为要保证以前的兼容
    ;现在只能写个憋屈的传送门滚木函数来搞
    ;以后有时间再另外写这玩意的完整版本吧

.nore:

    pop rdi
    pop rbx
    pdod

    ret

.nodx:
    lea rdx, [wasteimm]
    jmp .oudx

;替换一个$为自定义ASCII符号
;(目标，字符放dl)，破坏rax，rcx
;没有任何检查，内部函数
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

;测试函数，SIMD版本的strlen
;rcx放字符串起始
;真就飞车还要安全带啊，烦死了
kp_strlen_simd_fastcall_win64:

    mov r9,  16
    xor rdx, rdx

    pxor xmm1, xmm1

.label:

    ;检查页边界
    mov r10, rcx
    and r10, 0xFFF
    cmp r10, 4080
    ja  .slow

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
    
;SSE版本的strlen，rcx=src
;ONE OF 目前写的最诡异的函数
;注释的话留给两万年后吧
;非常的巧妙以至于改一个字母都可能完全奔溃
kp_sse_strlen_fastcall_win64:

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

;测试函数，用MOVSB复制内存
;建议在支持ERMSB的CPU上用
;(src,srclen,dst,dstlen)
kp_ermsb_fastcall_win64:

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



;把二进制按照16进制来读取，并且转换成16进制ascii文本
;（源，源长，目标，目标长）单位字节
;返回：末尾 \0 的地址，链式调用时从该地址覆盖写入
;依旧不检查空指针，注释留给明天
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

    lea rbx, [hex2ascii_xlatable]
    
    mov rdi, r8
    mov rsi, rdx
    ;rsi指向源
    
;循环
.xlatloop:

    lodsb

    mov r9b, al
    shr al,  4
    
    xlat
    stosb

    mov al, r9b
    and al, 0xF
    ;0b1111

    xlat
    stosb

    dec rcx
    jnz .xlatloop

    xor al, al

    stosb
    ;末尾补0

    lea rax, [rdi-1]
    pop rsi
    pop rdi
    pop rbx

    ret

.mgd:
    xor rax, rax
    ret

;两个ascii当一个byte
;如果你最后写的是A\0这种的话，查表大概率是不会执行
;（源，源长，目标，目标长）单位字节
;返回：最后一个数据字节之后的地址，链式调用时从该地址继续写入
;但是你要自己算好剩余长度或者用动态内存
kp_ascii2hex_fastcall_win64:

    cld

    test rdx, rdx
    jz   .mgd

    shl r9,  1
    cmp rdx, r9
    ja  .mgd

;正文

    push rbx
    push rdi
    push rsi

    mov rsi, rcx
    mov rdi, r8
    mov rcx, rdx
    shr rcx, 1

    lea rbx, [ascii2hex_xlatable]

.xlatloop:

    lodsb

    xlat

    mov r9b, al
    
    lodsb

    xlat

    shl r9b, 4
    or  al,  r9b

    stosb

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

;目前最好用的strlen
;爆改sse2版本
;rcx=src
kp_sse2_strlen_fastcall_win64:

    mov rdx, rcx
    mov r9,  rcx
    and rdx, -16
    sub rcx, rdx

    pxor     xmm1, xmm1
    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    shr r8d, cl
    jnz .found

    test rdx, 16
    ;检查对齐32位
    jz   .ssego

    add rdx, 16

    movdqa   xmm0, [rdx]
    pcmpeqb  xmm0, xmm1
    pmovmskb r8d,  xmm0

    test r8d, r8d
    jnz  .gofind

.ssego:
    add rdx, 16
.sseloop:

    movdqa   xmm0, [rdx]
    movdqa   xmm2, [rdx+16]
    pcmpeqb  xmm0, xmm1
    pcmpeqb  xmm2, xmm1
    pmovmskb r8d,  xmm0
    pmovmskb eax,  xmm2
    
    shl  eax, 16
    or   r8d, eax
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

;爆改avx2版本
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
    ;检查对齐64位
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

;封装CreateFileW，返回值按照api的来，但是失败为0
;int(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition)
;lpSecurityAttributes传NULL，hTemplateFile传NULL
;dwFlagsAndAttributes传FILE_ATTRIBUTE_NORMAL
;没有任何检查
kp_win32api_createfile_w_fastcall_win64:
    
    adod

    push r15 ;垃圾对齐

    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push r9

    xor r9,  r9
    xor r15, r15

    sub  rsp, 32
    call CreateFileW

    cmp   rax, -1
    cmove rax, r15

    mov r15, [rsp+56] ;恢复

    pdod

    ret;对的真就这么一点点

;封装GetFileSizeEx
;int(hFile,lpFileSize)
;和api一样，失败返回0，成功非0
kp_win32api_get_file_size_ex_fastcall_win64:

    adod

    sub  rsp, 32
    call GetFileSizeEx

    pdod

    ret;最短小的吧估计

;封装ReadFile
;int(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead)
;行为基本和api一样，第5个参数永远为NULL
;nNumberOfBytesToRead，想读多少字节。DWORD，32 位。
;lpNumberOfBytesRead，指向一个 DWORD 的指针，API 把“实际读了多少”写进去。这个值可能小于你想读的。
kp_win32api_read_file_fastcall_win64:

    adod

    push NULL ;对齐
    push NULL

    sub  rsp, 32
    call ReadFile

    pdod

    ret

; 封装WriteFile
;（句柄，源，源长，实际写入指针）
;（hFile, lpBuffer, nNumberOfBytesToWrite, lpNumberOfBytesWritten）
kp_win32api_write_file_fastcall_win64:

    adod

    push rax     ;占位
    push NULL
    sub  rsp, 32

    call WriteFile

    pdod

    ret

;封装SetFilePointerEx
;（句柄，偏移量，新位置指针，起始位置）
;（hFile, liDistanceToMove, lpNewFilePointer, dwMoveMethod）
kp_win32api_set_file_pointer_ex_fastcall_win64:

    adod

    sub rsp, 32

    call SetFilePointerEx

    pdod

    ret;最短的！

;获取文件指针
;（句柄，64位变量指针）
kp_win32api_get_file_pointer_ex_fastcall_win64:

    adod

    sub rsp, 32

    mov r8,  rdx
    xor rdx, rdx
    mov r9d, FILE_CURRENT

    call SetFilePointerEx

    pdod

    ret

;封装CloseHandle
;(handle)
kp_win32api_close_handle_fastcall_win64:

    adod

    sub rsp, 32

    call CloseHandle

    pdod

    ret

;封装MessageBoxW
kp_win32api_msgbox_w_fastcall_win64:

    adod

    sub rsp, 32

    call MessageBoxW

    pdod

    ret

;封装WideCharToMultiByte
;（源，源长，目标，目标字节长）
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




;封装VirtualAlloc
;（地址，大小，分配类型，保护属性）
;（lpAddress, dwSize, flAllocationType, flProtect）
kp_win32api_virtual_alloc_fastcall_win64:

    adod

    sub rsp, 32

    call VirtualAlloc

    pdod

    ret



;封装VirtualFree
;（地址，大小，释放类型）
;（lpAddress, dwSize, dwFreeType）
kp_win32api_virtual_free_fastcall_win64:

    adod

    sub rsp, 32

    call VirtualFree

    pdod

    ret

;本来字符ascii_hex格式化第一步
;文本分组，字节级别处理，仅适合ascii及utf8
;你可以通过参数4输入负数来忽略（禁用）长度检查
; 你可以通过参数6输入负数来忽略（禁用）换行功能
;默认用空格划分，换行用0x0A0D（小端序）也就是回车换行
;（源，源长，目标，目标长，多少个字节一组，一行多少组）
;srclen=0直接退出，失败返回NULL，成功返回指向目标末尾\0指针
kp_text_format_divide_fastcall_win64:

;检查srclen和dstlen

    ;表演个脱裤子放屁
    push rbp
    mov  rbp, rsp

;===STACK===
; [rbp+56]  arg 6   行组数
; [rbp+48]  arg 5   组大小
; [rbp+40]  shadow 4
; [rbp+32]  shadow 3
; [rbp+24]  shadow 2
; [rbp+16]  shadow 1
; [rbp+8]   返回地址
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
    ;0个字节一组我也没办法
    test r11, r11
    jz   .error

    ;检查rdx
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
    bts  rax, 0  ;禁用长度检查

.r9ok:
    test r11, r11
    jns  .chk
    bts  rax, 1   ;禁用换行

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
    inc  r10      ;不对齐的兜底
.alnd:
;接下来算有多少行
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

;长度计算
    
;需要长度=源长+组数-行数+（行数-1）*2+1
;(srclen+groups+lines-1)
    lea rdx, [rdx+r10]
    lea r15, [r11-1]
    add rdx, r15

    bt rax, 0
    jc .main

    cmp rdx, r9
    jbe .main

    jmp .error

;代码主体，两个
;分别为有换行和没有
;众生平等main，众生平等rdx，其它的都一样例外rax's bit 1
.main:

    bt   rax, 1
    jc   .disablenewline
    ;rcx=src,rdx=len,r8=dst,r10=groups,r11=lines,r12=objspergroup,r13=groupsperline
    push rdi
    push rsi
    mov  rsi, rcx
    mov  rdi, r8
    ;大循环=lines-1
    ;传送门
    cmp  r11, 1
    je   .last
    lea  rcx, [r11-1]
;大循环，总共执行行数-1
.big:
    push rcx
    mov  rax, 0x20
    mov  rcx, r13
    cmp  rcx, 1
    jz   .onegpl
    dec  rcx
    ;中间循环，每次执行行中组数-1
    .mid:
    push rcx
    ;小循环，每次复制一个组并且格式化
    mov  rcx, r12
    rep movsb
    stosb
    pop  rcx
    dec  rcx
    jnz  .mid
    ;当每行组数为1时候
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
    ;现在rax就是剩余组数
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

    ret;又浪费了一整天写了坨狗屎出来

;   注意：  代码段结束（我真服了这nasm没有结束标志老是搞错）




WARNING_SIGN:

section kpstdlib

A_UNAVAILABLE_SIGN:

ksignlabel:
;KUSSA(KUSSA_LTSC)
    jmp ksignlabel
    db 'KUSSA_LTSC'

;来自另一个项目的内容：

    ;“我们做了个艰难的决定”：

        ;自从2026年9月6日起，这个教学demo不再遵循GPL协议，改用KUDOS
        ;原来已经用GPL协议发布的版本不受影响
        ;因为要使用闭源库或者是源码可见的库，不符合GPL要求

    ;2026年9月6日

;你必须要知道的：

    ;用的不是开源许可证，只是源码可见
    ;如果你是学生并且进行与工作无关的学习汇编出于爱好的话可以随便研究学习
    ;这个代码是免费的，不要拿去卖钱
    ;如果你付费获得的话，说明你被骗了一点点钱
    ;免费链接：https://github.com/KUSSA-LTSC/KUDOS-kpstdlib/

;2026年9月11日

; 你必须要知道的：
;
; 用的不是开源许可证，只是源码可见。
; 这不是 OSI 开源许可证。
;
; 这个代码是免费的，不要拿去卖钱。
; 如果你付费获得的话，说明你被骗了。
; 免费链接：https://github.com/KUSSA-LTSC/KUDOS-kpstdlib/
;
; 个人可以出于爱好、私人、非商业目的学习汇编。
; 学生可以学习，但仅限个人私人学习，或符合许可证定义的
; “允许的教育用途”：主流在线平台公开免费课程。
;
; 禁止把源代码、修改版、二进制文件分享给朋友、同学、同事、
; 学生、其他部门、子公司或任何第三方。
; 研究合作、同行评审、论文发表按许可证第 1.4 条执行。
;
; 配置文件可以公开，但不能包含源代码、脚本、二进制、
; 可执行逻辑或任何能重构软件的材料。
;
; 商业使用、营利实体使用、评估、测试、捆绑、AI 训练，
; 全部需要项目所有者事先纸质书面同意。
;
;2026年9月12日

; 我去了我要累死了啊

;2026年9月13日

; 高中是地狱吗？今天可是918记难日

;2026年9月18日

; 中秋快乐
; 快乐个屁，共度作业
; 那个臃肿的filetime_to_realtime我迟早给它重写

; 我真的是累死了要
; 这臃肿的东西还有一堆没搞
; 甚至还有一堆指令集

; 技术上有一堆技术债
; 功能上有一堆未完成
; 注释也还差了一大大堆，AI写出来的注释就是狗屎，不像人写的

; 还是广井菊里我最喜欢的一个

;2026年9月24日

; 人老了真是不中用了，今天就写了02个函数
; 九月的最后一天啊
; 作业咋能当凳子坐了啊

;2026年9月30日

; 今天是10月01日国庆

; 在这个幸福的日子里，我诚心祝祖国生日快乐。
; 在這個幸福的日子裡，我誠心祝祖國生日快樂。

; 今天写了很多吧，比如avx2版本的strlen

; 代码破2000行了，但是大部分都是注释，O(∩_∩)O哈哈~

;2026年10月1日

; 我讨厌字符串格式化
; 真的服了这烦人玩意
; 作业啊，我写不完啊

;2026年10月2日

;到底了，就这么多~