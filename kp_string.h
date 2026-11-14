// kp_string.h

// Copyright (c) 2026-8086 KUSSA. All rights reserved.

#ifndef KP_STRING_H

#define KP_STRING_H

#include "kpstddef.h"

// strlen
ux kp_strlen(rp str);
// strchr，从头开始找
// 返回找到的字符的索引+1。如果要找的字符是 '\0'，则返回 strlen（如果 strlen 传入负数，则自动计算）。
// （留空，源，源长，单字节字符）单位字节
// 返回 0 表示没找到。
ux kp_strchr(ux waste, rp str, ux strlen, uc ch);
// 标量memcmp，不检查空指针
// 相等返回非 0，不相等返回 0
// （源，源长，目标，保留参数）
// 保留参数目前给 0就行
// 不要比较返回值==true
ux kp_memcmp(rp src, ux srclen, rp dst, px bitmap);
// strstr，不检查空指针
// 返回索引+1，零代表没有找到
// 源长是负数就自动算，目标长必须填
// （源，源长，目标，目标长）
ux kp_strstr(rp src, ux srclen, rp dst, ux dstlen);
// 标量 movsb
// 同时适用于 ermsb，不是 memmove
// （源，源长，目标，目标长）
// 目标长给-1可以忽略检查，不推荐
// 不检查空指针，不补 0，仅失败返回 0
ux kp_movsb(rp src, ux srclen, px dst, ux dstlen);

#endif