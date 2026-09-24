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

%include 'third.inc'

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
global  dlsbur ; 这个可以自定义符号
; global  kp_prtnum_frmstk_wthrcx_rep_fastcall_win64
global  kp_replace_single_dollar_symbol_wthcnt_fastcall_win64
global  kp_filetime_to_realtime_frmrax_ret_fastcall_win64
global  kp_strcpy_enddls_fastcall_win64
global  kp_ezutf8t16le_fastcall_win64
global kp_sse_strlen_fastcall_win64
global  kp_strcpy_fastcall_win64
global  kp_strend_fastcall_win64
global  kp_strled_fastcall_win64
global  kp_strlen_fastcall_win64
global  kp_timefmt_fastcall_win64

extern  MultiByteToWideChar

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
        times 64 db 0
    dlsbur_end:
    
    dlsbur_len equ (dlsbur_end-dlsbur)

section .text

kp_strlen_fastcall_win64:
;只有一个参数，rcx放字符串起始，返回rax，单位字节    
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
    mov rax, rcx
    pop rdi
    ret
    ; jmp .ret

.nofind:
    xor rax, rax
.ret:
    pop rdi
    ret

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
    push rdi
;保存所有用到的
    ;PREPROCE

    xor rsi, rsi
    xor rdi, rdi

    

;整体循环转化输出
.lb_tltp:

    mov rax, [rbp+rsi+48]
;新增检查负数
    ; test rax, 0x8000000000000000
    ; jz   .np
;改成更短的写法
    or  rax, rax
    jns .np
;不是负数就跳过
    mov byte [bu], 45 ;负数符号的ASCII
    inc rdi
;负数转正
    neg rax
.np:
    mov  rbx, 10
    push rcx
    xor  rcx, rcx
;除法循环
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

;单独打印rax，给日志功能用，应该不会破坏任何寄存器
kp_prtnum_frmrax:
;默认rax已经赋值
    push rdi
    xor  rdi,       rdi
    or   rax,       rax ;检查负数
    jns  .np            ;不是负数就跳过
    mov  byte [bu], 45  ;负数符号的ASCII
    inc  rdi
    neg  rax
.np:
    push rsi
    push rcx
    push rdx
    push rbx
    mov  rbx, 10
    xor  rcx, rcx
.divlop:
    inc  rcx
    xor  rdx, rdx
    div  rbx
    push rdx
    or   rax, rax
    jz   .preprt
    jmp  .divlop
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

    lea rax, [bu]
    ;返回地址

    pop rbx
    pop rdx
    pop rcx
    pop rsi
    pop rdi
    ret

;算出来日期，从参数3到参数8返回年份，月份，日子，小时，分钟，秒数

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
    jns  .busu
    push rcx

    call kp_strlen_fastcall_win64
    mov  rdx, rax

    pop rcx

.busu:

    cmp rdx, r9
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

    mov byte [rdi], 0

    jmp .normal

.msq:
    mov rcx, rdx
    shr rcx, 3
    rep movsq
    mov rcx, rdx
    and rcx, 7
    rep movsb

    mov byte [rdi], 0

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

db '少羽牛逼'

;输入rcx，可以用系统提供时间GetSystemTimeAsFileTime
;传入参数：rcx放时间由系统提供，1个地址用来返回纯文本的紧凑时间
;例如：20260905220631_134330908XXXXXXXXX\0
;剩下6个地址分别是年月日时分秒的内存指针
;void(imm64,immmem64ptr,mem64addr*6)
kp_filetime_to_realtime_frmrax_ret_fastcall_win64:
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
    mov  rbp, rsp
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
    ;已经保存了所有参数
    mov rax,      rcx

    xor rbx, rbx ;这行干嘛用的我也忘了，其实没用
    
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
    mov [days],      rax
    mov [seconds],   rdx
    mov rcx,         days_per_400_years
    xor rdx,         rdx
    div rcx
    mov [nboffhys],  rax
    mov rax,         rdx                ;继续除以100年
    mov rcx,         days_per_100_years
    xor rdx,         rdx
    div rcx
    mov [nbofohys],  rax
    mov rax,         rdx
    mov rcx,         days_per_4_years
    xor rdx,         rdx
    div rcx
    mov [nboffoys],  rax
    mov [tempdays],  rdx
    ;剩下的天数
    ;现在先算有没有世纪平年
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

    lea rbx, [mthlep]
    lea rcx, [mthcom]

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
    ;真的还有人记得rsi已经清零了吗（在开头）
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
    ;这里是没过完的一天
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

    lea rbx, [date]

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

    mov [dlsbur], rcx

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
db 'This_is_a_sentence.'
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
    call kp_strlen_fastcall_win64
    mov  rdx, rax
    pop  rcx
.busu:   
    lea r10, [rdx+1]
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

    ; mov byte [rdi], 0
    mov ah,    0
    mov al,    ('$')
    mov [rdi], ax
    inc rdi

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

;替换所有$为自定义ASCII符号
;(源，源长，目标，目标长)
;以0结尾的源，源长为负数自动算
;源长也是符号替换的数量（相当于）
kp_replace_single_dollar_symbol_wthcnt_fastcall_win64:
    push rbp
    mov  rbp, rsp
    push rsi
    push rdi
    
    or  r9, r9
    jz  .error
    ;目标长为0那还说啥
    cmp r9, 8
    ja  .error
    ;修改，现在最多替换8个，因为我给的缓冲区就这么点
    ;2026年9月24日

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
    mov rsi, rcx
    ;现在rsi指向源
    mov rdi, r8
    mov rcx, r9
    ;现在rcx就是长度了

.replop:    
    mov al, ('$')
    mov ah, [rsi]

    repne scasb
    jne .exit

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
    push rbp
    mov  rbp, rsp
    mov  rbx, 10
    xor  rcx, rcx
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
    or   rsi,   rsi
    jz   .sk
    mov  ax,    [rbx]
    or   ah,    ah
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

    pop rbp
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
    or rcx, rcx
    jz .nullet
    or r8,  r8
    jz .nullet
    or r9,  r9
    jz .nullet
    or rdx, rdx
    jz .nullet

    ;正片开始

    mov  r10, rcx
    mov  rcx, r8
    call kp_strlenled_inside

    sub rcx, r9
    neg rcx
    js  .nullet

    mov r9,  rcx
    mov rcx, r10

.noauto:   

    ;现在可以开始复制字符串
    
    mov  r8, rax
    call kp_strcpy_fastcall_win64
    
    ret

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
kp_ezutf8t16le_fastcall_win64:
    
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

;时间函数的简短输入版本
;void(filetime,快速字符串地址,结构体地址起始,禁用北京时间
;关于禁用北京时间（0的话就不管，如果是非0的话就给UTC时间）
kp_timefmt_fastcall_win64:    

    adod

    or rdx, rdx
    jz .nodx
.oudx:

    push rbx
    push rdi
    push r9
    push rdx
    mov  rbx, rcx

    or  r9,  r9
    jz  .enboeg
    mov r10, unboeg
    sub rcx, r10
.enboeg:

    or  r8, r8
    jnz .normal
    lea r8, [dust]

.normal:

    adod

    lea  r10, [r8+40]
    push r10
    lea  r10, [r8+32]
    push r10
    lea  r10, [r8+24]
    push r10
    lea  r10, [r8+16]
    push r10
    lea  r9,  [r8+8]
    
    sub  rsp, 32
    call kp_filetime_to_realtime_frmrax_ret_fastcall_win64

    pdod

;回写filetime

    ;前面有个push rdx
    pop  rdi
    pop  r9
    or   r9,  r9
    jz   .nore
    or   rdi, rdi
    jz   .nore
    mov  rdi, [rdi]
    mov  al,  ('{')
    mov  rcx, -1
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
;(目标，字符放dl)
;没有任何检查，内部函数
kp_replace_single_dollar_symbol:
    
    push rdi
    mov  al,      ('$')
    mov  rcx,     -1
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
    
;SSE版本的strlen    
;rcx=src
;注释的话留给两万年后吧
kp_sse_strlen_fastcall_win64:

    push rdi

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

    movdqa  xmm0, [rcx]
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
    mov rcx, rdi

    pop rdi

    ret

;   注意：  代码段结束（我真服了这nasm没有结束标志老是搞错）




WARNING_SIGN:

section .kpstdlib

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

;2026年9月24日

;到底了，就这么多~