// kp_zini.h

#ifndef KP_ZINI_H

#define KP_ZINI_H

#include "kpstdlib.h"

#include <stdio.h>
#include <string.h>
#include <wchar.h>

#include <windows.h>

// 打开配置文件函数
// 默认已经设置了目录或者提供了完整的文件名
// （标志，文件名，缓冲区，缓冲区长度）
// 标志默认填 0就好，失败返回 0
ux ke_rini(ux bitmap, wt *filename, uc *bu, ux buflen);

// 检查配置文件函数
// （缓冲区指针，字符串长）
// 合法 Kikuri 配置文件返回 1，非法返回 0
ux ke_vini(const uc *zone, ux zlen);

// 解配置文件函数
// （缓冲区，段名，标签，键名）
// 返回文本指针，失败返回 0
uc *ke_aini(px zone, px section, px label, px key);

#endif