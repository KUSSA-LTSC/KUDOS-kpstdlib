// kp_zini.h

// Copyright (c) 2026-8086 KUSSA. All rights reserved.

#ifndef KP_ZINI_H

#define KP_ZINI_H

#include "kpstdlib.h"

#include <stdio.h>
#include <string.h>
#include <wchar.h>

#include <windows.h>

// 设置当前目录函数
// 初始化时候可以用，禁止多线程
// 只能判断返回 0为失败！
ux ke_stcdir(void);

// 打开配置文件函数
// 默认已经设置了目录或者提供了完整的文件名
// （标志，文件名，缓冲区，缓冲区长度）
// 标志默认填 0就好，失败返回 0
ux ke_rini(ux bitmap, const wt *filename, uc *bu, ux buflen);

// 检查配置文件函数
// （缓冲区指针，字符串长）
// 合法 Kikuri 配置文件返回 1，非法返回 0
ux ke_vini(const uc *zone, ux zlen);

// 解配置文件函数
// （缓冲区，段名，标签，键名）
// 返回文本指针，失败返回 0
uc *ke_aini(rp zone, rp section, rp label, rp key);


// 找到键值后复制
// （键值指针，标志，目标缓冲区，目标缓冲区长度）
// 标志目前给 0就可以
// 成功返回指针，失败或空内容返回 0
uc *ke_cini(const uc *src, ux bitmap, uc *dst, ux dstlen);

#endif