; kpstdlib.asm

; 版本：0.1.7.2611
; 开发代号：Horizon

; 不是和UCRT水火不容，是我不满意的函数才会自己写

section .data
    build_date: db __DATE__, 0
    build_time: db __TIME__, 0

section .text

first_comment:

;KUSSA's standard library
;源码可见，仅供免费教育研究和学习
;Copyright (c) 2026-8086 KUSSA. All rights reserved.

    ; 这是什么：一个NASM项目（废话）
    ; 用来干嘛：为了用来写C代码
    ; 你为啥要看：关我屁事
    ; 它标准化吗：从调用约定上来讲基本符合微软x64ABI
    ; 但是它的写法可能比较诡异
    ; 看不懂咋办：不看，或者你去问AI
    ; 是完全手写的吗：是的，可能让AI帮我做了一些参数上的检查，比如我曾经把GetFileSizeEx打错字成GetFileSizeEX
    ; 我经常让AI帮我看编译和链接报错，辅助查询intel SDM PDF
    ; 它好用吗：不一定，但是除了win32api封装以外都会返回NULL代表失败
    ; NULL是个常量，等于零
    ; 怎么考虑更新内容的：我需要啥我就写啥
    ; 为啥要封装系统 api：为了让我更好记住，为了能方便维护和移植，为了写程序更方便
    ; 而且有些系统的 api  我经常要反复传同样的几个参数，不如直接固定一个包装少打字
    ; 再说你为啥要学汇编：它能让你更好理解代码的工作，以及解决非常多匪夷所思的 BUG
    ; 但是学习汇编对于大多数人来讲并不容易
    ; 我是例外，我反而写C代码总是出问题，还不会修BUG，我觉得我的C实在太差劲啦
    ; 它性能会比CRT更好吗：不会，差不少，可能某些激进的函数会快一点点点，但是UCRT的话真的实在太保守啦

;bash:

    ; nasm -f win64 .\kpstdlib.asm -o .\kpstdlib.obj 
    ; gcc -o test.exe test.c kpstdlib.obj -nostdlib -lkernel32 -luser32 -mwindows -e main -ffreestanding -fno-stack-protector -fno-asynchronous-unwind-tables -O2
    ; 注意：这份GCC的命令只是参考，或者说是我之前测试用过的编译命令，我现在用的是CL而不是GCC，所以，你如果要自己写C程序的话，不用看这GCC的编译命令

    ; 注意事项：

        ; 1.如果禁用了CRT，你需要手动指定入口点，千万不能用return 0返回，必须显式用ExitProcess否则程序会跑飞
        ; 2.如果禁用了CRT，某些编译器或者链接器会自作多情检查有没有各种启动和初始化函数，这时候通常需要写一个空的来通过链接
        ; 3.如果需要PDB调试符号，必须用微软的link，当然别的也不是不行，但是话摆在这
        ; 4.我强烈建议把文件名，编译命令和环境注释在代码开头，无论任何代码，这份代码通常是utf8保存的，对于cl需要加上/utf-8选项，而GCC就通常默认utf8
        ; 5.没有头文件的这个库，你需要自己准备，或者让AI写，或者直接写extern，本身不需要，但是和CRT以及系统API兼容，但是链接的时候必须要kernel32和user32
        ; 6.这份代码是免费观看的，但是不是开源

;新版声明：

    ; 纪念legacy_kpstdlib：

        ; 最后一个函数lgprax，只有一行ret，纪念这个库的终点。
        ; 我也不知道我写代码是为了什么啊，我其实更喜欢研究CPU的电路。
        ; 但是我的数学和物理什么的知识还是过于缺乏。
        ; 而且我现在学习也比较忙，我现在觉得我可以拿出来更多时间看番。
        ; 毕竟8年前到现在，看过的动漫也没有多少，还特别喜欢反复看。
        ; 总之，这个库的使命结束啦，明天它就会封上，我打算重写。
        ; 十月份的最后一天，它会从头开始，并且完全转变开发理念。
        ; 话说这段文字可能是为数不多有句号结尾的。
        ; 开源对我来讲其实没啥意义。
        ; 它还能用很久，会被迁移的。

    ; 2026年10月30日

    ; 这份是重写的kpstdlib
    ; 全新的代码，全新的屎山
    ; 以及众多修改，头文件的完善

    ; 有什么大变化？

        ; 1.开发理念改变：
            ; 开发会变得更长更久，为啥，因为我要留出来时间看动漫和别的
            ; 所有函数，优先保证稳定，性能永远不会再考虑，慢工出细活，SIMD是软件卡到不行再换的
            ; 没有人会用准时发布的垃圾，我也不会，我C代码学到哪里，我汇编加到哪里
            ; 旧的kpstdlib很多代码可以复用，可以大幅减少开发时间
            ; 终于开始分文件，段，还有前缀，以及类似ifunc的jmp导出函数，还有初始化函数来修改函数跳转表
            ; 注释不再重要，所有代码优先能看懂，所以尽量写特别简单，性能可能很差
        ; 2.开发方式改变：
            ; 我可以写更新日志啦，因为现在可能写个新函数就要好几周，写个日志用不了多少时间
            ; 分文件之后，我会提供bat 来一键构建，然后就比较方便吧我觉得，比起make简单多
            ; 彻底抛弃gcc ，完全按照cl来开发，因为msys的pacman太傻逼（我不会用），一个软件几MB结果下载回来800MB的依赖，2GB的占用，卸载的时候通常pacman说只能删几十MB，那我那么多空间变空气了吗？
        ; 3.代码许可改变：
            ; Copyright (c) 2026-8086 KUSSA. All rights reserved.

    ; 各种说明：

        ; 版本号说明：

            ; 0.1.3.2611

                ; 0         代表大版本号
                ; 1         代表小版本号
                ; 3         代表修订号
                ; 2611      代表月份，2026年11月

        ; 各种前缀：

            ; k0  绝对稳定
            ; k1  标量
            ; k2  保守（对标微软ucrt）
            ; k3  SSE2
            ; k4  调试版本
            ; k5  SSE4
            ; k6  怎么舒服怎么来
            ; k7  AVX2
            ; k8  最高激进
            ; k9  APX（等有再说）
            ; ks  服务器级别，借鉴的
            ; kp  导出跳板，调用者只认这个
            ; kd  调试（仅主文件，其他文件额外提供）
            ; kf  框架
            ; kx  拓展
            ; kc  拓展
            ; kw  Wrap包装
            ; kn  拓展
            ; km  特殊函数和杂七杂八
            ; kr  注册
            ; ko  输出
            ; ke  基础拓展
            ; kz  拓展
            ; kt  拓展

        ; 重新设计的函数划分：

            ; KPSTDLIB_CORE

                ; CoreInit
                ; String
                ; Calc
                ; Math
                ; Time
                ; Text
                ; Encode
                ; Decode
                ; Input
                ; Output
                ; StdApiWrap
                ; DebugEditionWrap

            ; ExtensionNameReservation

                ; AL-1S
                ; Bocchi
                ; California
                
                ; Xp
                ; Yamada
                ; Zero

                ; Misc
                ; Wrap
                ; Nijika

                ; Kita
                ; Vista
                ; Hiroi

                ; Guangdong
                ; Jealousy
                ; Quotient

                ; Thunder

        ; 注意：数字前缀永远不会直接导出，必须通过给init传不同参数来启用

        ; 一个例子：

            ; k3_strlen_2610

            ; k3        前缀
            ; strlen    函数名
            ; 2610      版号

        ; 重要说明以及警告：

            ; 1.这个库的文字处理标准就是ASCII，对于GBK和UTF-8的支持完全就是意外
            ; 2.开发过程中不保证函数行为不变，也不保证非kp前缀的特定函数名字不变
            ; 3.这个库是用nasm写的，稳定优先，代码能跑就不动，性能永远不是首选项
            ; 4.充分吸取了前面的教训，所有管理架构和函数从设计之初就会留下充足的余地
            ; 5.这个库的kpic是一刀切的，支持avx2的cpu 才能完整运行所有函数，否则kpic全部按照默认的函数跑
            ; 6.因为是x86-64平台，所以不支持avx2的cpu最高只能运行sse2优化的代码
            ; 7.以后可能改变成默认cpu 有sse4并且不支持avx2的最高可以运行到sse4优化的代码

    ; 新增一个函数要注意什么：

        ; 1.检查这主文件有没有包含这个文件
        ; 2.检查这个文件有没包含kpstddef定义
        ; 3.检查这个文件有没包含这个函数的声明
        ; 4.检查这个文件有没包含这个函数的实现
        ; 5.检查这个文件有没包含这个函数的初始化
        ; 6.检查头文件有没包含这个函数的声明以及注释

first_comment_end:

;……代码往下……

include_inc:

    %include 'kpstddef.inc'

include_inc_end:

; 这里似乎少了点什么……

second_comment:

bits    64
default rel

; 这份真的是主文件，哪怕没任何一行真的函数代码

; 遗产展示：

    ; 拒绝展示好吧，浪费空间

; 这个库的立项日期无从考究，但是可以确定在2026年8月26日及以前

second_comment_end:

global_initfunc:

global kpicinit

global_initfunc_end:

; 正文：

kpic_global_list:

    .string:

        global kp_strlen
        global kp_strchr
        global kp_memcmp
        global kp_strstr

    .string_end:

    .win32api:

        global kp_exit
        global kp_error
        global kp_quest
        global kp_warn
        global kp_info

    .win32api_end:

kpic_global_list_end:

include_file_list:

%include 'kp_string.asm'
%include 'kp_win32api.asm'

include_file_list_end:

    
section kpifuncs code
    
    align 16

kp_string:

    ; strlen
    ksjf kpic_string, strlen, kp

    ; strchr
    ksjf kpic_string, strchr, kp

    ; memcmp
    ksjf kpic_string, memcmp, kp

    ; strstr
    ksjf kpic_string, strstr, kp

kp_string_end:

section kpifuncs code

kp_win32api:

    ; ExitProcess
    ksjf kpic_win32api, exit, kp 
    ; ErrorMsgBox
    ksjf kpic_win32api, error, kp
    ; QuestionMsgBox
    ksjf kpic_win32api, quest, kp
    ; WarningMsgBox
    ksjf kpic_win32api, warn, kp
    ; InformationMsgBox
    ksjf kpic_win32api, info, kp

kp_win32api_end:



section .data

align   16

kpic_string:
    .strlen dq k1_strlen_2610
    .strchr dq k1_strchr_2610
    .memcmp dq k1_memcmp_2610
    .strstr dq k1_strstr_2611

kpic_string_end:

kpic_win32api:

    .exit  dq kp_exit_2610
    .error dq kp_error_2611
    .quest dq kp_quest_2611
    .warn  dq kp_warn_2611
    .info  dq kp_info_2611

kpic_win32api_end:

    
section .data

    align 16

    ; 初始化标志
    initsign dq 0
    ; 初始化参数备份
    initoval dq 0

section .text

    align 16

; 目前必须传NULL一个参数，哪怕现在没用上，只能把返回零作为失败，千万不能检查成功返回值
kpicinit:

    test qword [initsign], -1
    jz   .init

    mov eax, 1
    ret

.init:

    ; mov [initsign],       rcx
    or qword [initsign], 1

    mov [initoval], rcx

    push rbx

    mov eax, 1
    cpuid
    bt  ecx, 28
    jnc .exit
    bt  ecx, 27
    jnc .exit

    mov eax, 7
    xor ecx, ecx
    cpuid
    bt  ebx, 5
    jnc .exit
    
    xor ecx, ecx
    xgetbv
    and eax, 6
    cmp eax, 6
    jne .exit

    ; apartinitfuc
    call .string

    mov eax, 1
    pop rbx
    ret

.exit:

    pop rbx
    xor eax, eax
    ret

.string:

    kslf kpic_string, strlen, k7_strlen_2610
    kslf kpic_string, strchr, k5_strchr_2610

    ret



kpicinit_end:




other_comment:

; 接下来就是喜闻乐见的更新日志：

    ; 骗你的我没写
    ; 骗你的我写了
    ; 好吧其实没写

; 放歌词在这应该没啥事：

    ; Playing：《月並みに輝け》-結束バンド_-BTR-S_FLAC

        ; 天才だって信じてた　バカみたいだ
        ; 小さな自信　溢れ落ちて割れた
        ; 偶然がなかったなら　わたしはまだ
        ; 孤独感と手を繋ぎ踊っていたかな
        
        ; いいな　いいなと　欲しがってたのに
        ; 夢は遠くて　現実ばっかで
        ; まだだ　まだだ　まだ足りないんだ
        ; 誰の胸にも届かない
        
        ; 一生存在証明　永遠（トワ）を超えていけ
        ; ちくしょう！どうやったって時は止まらない
        ; 間に合うかな　見知らぬ世界の果て
        ; いつか　どうか
        ; 秒速340mを超えていけ
        ; 誰も聞いたことない旋律は鳴り止まない
        ; 変われなくても　代わりはいないから
        ; 鏡を閉じて
        ; 革命寸前の未来を睨んだ
        
        ; 天才だって信じてた　気付かされた
        ; 違う音、呼吸重ね合わせ負けた
        ; 必然だって信じたい　わたしはもう
        ; 戻れないよ　無知で無敵だったヒーロー
        
        ; どうする？どうしよう？問いかけてみる
        ; わたしの中の　わたしが叫ぶ
        ; 「君は　君だ　誰かと同じ
        ; 未来なんて欲しくないでしょ」
        
        ; 一生全身全霊　限界を超えていけ
        ; 何回間違えたって　指を止めるなよ
        ; 叶わなくても　叶えたいと願って
        ; 奏で続ける
        ; 敗北宣言の未来を進んだ
        
        ; 「一生才能凡庸　天才じゃないからさ
        ; 何にもない何にもできない」なんて言い訳
        ; したくはないから　何度も挑んでやる
        ; ついてこいよ
        ; 秒速340mを超えていけ
        ; 誰も聞いたことない旋律は鳴り止まない
        ; 変われなくても　代わりはいないから
        ; 鏡を閉じて
        ; 革命寸前の未来だなんて
        ; 紛れもなく確かな希望だ
        
        ; 天才だって信じてた　それでもまだ

    ; 你还别说这波奇酱（其实是樋口愛）写的词是真牛逼

; 环境信息：

    ; 系统信息：

        ; 操作系统  : Windows 10 专业工作站版 (22H2, Build 19045)
        ; 系统类型  : 基于 x64 的电脑
        ; 主板型号  : Gigabyte B85M-D3H

        ; 处理器    : Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz
        ; 架构代号  : Haswell
        ; 核心/线程 : 4 核 4 线程 

            ; SSE2      : 支持
            ; SSE4.2    : 支持
            ; AVX       : 支持
            ; AVX2      : 支持
            ; AVX-512   : 不支持
            ; APX       : 不支持

    ; 构建工具：

        ; NASM version 2.16.03 compiled on Jun  3 2024

        ; gcc (Rev9, Built by MSYS2 project) 15.2.0
        ; Copyright (C) 2025 Free Software Foundation, Inc.
        ; This is free software; see the source for copying conditions.  There is NO
        ; warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

        ; Microsoft (R) C/C++ Optimizing Compiler Version 19.51.36257 for x64
        ; 版权所有(C) Microsoft Corporation。保留所有权利。

        ;  Microsoft (R) Macro Assembler (x64) Version 14.51.36257.0
        ; Copyright (C) Microsoft Corporation.  All rights reserved.   

        ; Microsoft (R) Incremental Linker Version 14.51.36257.0
        ; Copyright (C) Microsoft Corporation.  All rights reserved.

other_comment_end:

update_log:

; 更新日志：

    ; 为了让傻逼AI省点token ，我现在把日期写头头

; 2026年10月30日

    ; 新建这个文件和文件夹
    ; 移动了一堆文件并且挖新坑
    ; 然后敲了一会键盘写下这堆东西

; 2026年10月31日

    ; 今天给legacy_kpstdlib封板子
    ; 新增了kp_strchr、kp_memcmp、kw_exit，但和旧版行为不同
    ; 重新调整了调整表，以后的跳转表会有分类，文件内新增多个标号用来划分
    ; 架构再次重大调整更新，更加细分，但是又保证不会过于复杂
    ; 多文件的测试通过，条件kpic也通过，小小调整头文件，它还没做完
    ; 现在要求init强制传一个NULL哪怕目前不用，留给以后拓展

; 2026年11月1日

    ; 给我的VisualStudioCode加了个能显示背景图片的插件
    ; 现在背景里面有着喜多鬱代和山田涼的两个大头
    ; 基础宏kpstdinc现在有定义保护，方便以后重复包含
    ; 现在可以用kslf和ksjf的两个宏来写和管理跳转表和跳转导出函数
    ; 用新的宏重写了初始化函数和导出函数
    ; 以及诸多小小的改进，简单测试了三次
    ; 以后可能会有很多分开的文件，我觉得不合并可能更好，虽然文件会很杂很多
    ; 不太可能用二级文件夹来管理，那样只会更麻烦而且我用不上
    ; 必须注意的是：前缀比如kw之类的只能在ksjf那里指定
    ; 比如kp_strlen 这种必须在kslf里写成：kslf kpic_string, strlen, k7_strlen_2610
    ; 必须注意的是，宏的参数必须用', '（英文逗号，空格）来分割
    ; 宏kslf不用写kp之类的前缀，然后前缀会在ksjf里添加指定

; 2026年11月6日

    ; 重新设计了函数划分，现在所有核心函数都是kp开头，其DebugEdition为kd开头
    ; 保留许多前缀用来作为拓展名字，比如以后kb就是Bocchi拓展的函数
    ; 拓展函数的DebugEdition会重新设计一个前缀，或者直接tb开头，比如tb_bocchifuncname
    ; 新增kall，kpsh，kpop宏，但是还没有使用和测试
    ; 新加版本号标识，还有个没有任何意义的开发代号
    ; 准备提供头文件，用来开发C 代码

; 2026年11月7日

    ; 老年痴呆，我也忘了今天写了啥，反正很多
    ; 正式开始提供头文件，完善了说明和代码的头文件，新增kp_strstr
    ; 新写个cfgt.c的测试，我的C 代码就是一坨狗屎，这点东西写那么久

; 2026年11月8日

    ; 打算提供额外的参考文档和笔记
    ; 对库小修小补，基本就是规划上的
    ; 重新提供 launcher.asm 带有init

update_log_end:

file_end:

;到底了，就这么多~