// kpstdlib.h

// 版本：0.1.19.2611
// 开发代号：Horizon

/*
;KUSSA's standard library
;源码可见，仅供免费教育研究和学习
;Copyright (c) 2026-8086 KUSSA. All rights reserved.
*/

// kpstdlib的C 头文件の函数声明的总文件

/*
    版本号不一定和主文件同步，需要检查或者尝试编译
*/
#ifndef KPSTDLIB_H

#define KPSTDLIB_H

// 标准库 の 头文件
#include <stddef.h>
#include <iso646.h>

// kpstdlib の 头文件
#include "kpstddef.h"
#include "kp_string.h"
#include "kp_win32api.h"
#include "kp_text.h"

// 重新设置标志位，仅适用于虚拟机换 CPU的场景
// 一个参数，给 0就行，因为现在没有用上
// 这样不能把参数重置回标量，以后可能才会考虑提供标量重置
ux kpicrsts(ux value);

// 目前必须传NULL一个参数，哪怕现在没用上，只能把返回零作为失败，千万不能检查成功返回值
ux kpicinit(ux value);

#endif