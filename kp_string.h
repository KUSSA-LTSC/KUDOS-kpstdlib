// kp_string.h

#ifndef KP_STRING_H

#define KP_STRING_H

#include "kpstddef.h"

// strlen
ux kp_strlen(const uc *str);
// strchr，从头开始找
// 返回找到的字符的索引+1。如果要找的字符是 '\0'，则返回 strlen（如果 strlen 传入负数，则自动计算）。
// 返回 0 表示没找到。
ux kp_strchr(ux dust, const uc *str, ux strlen, uc ch);
// 标量memcmp，不检查空指针
// 相等返回非 0，不相等返回 0
// （源，源长，目标，保留参数）
// 保留参数目前给 0就行
ux *kp_memcmp(px src, ux srclen, px dst, px bitmap);
// strstr，不检查空指针
// 返回索引+1，零代表没有找到
// 源长是负数就自动算，目标长必须填
// （源，源长，目标，目标长）
ux kp_strstr(px src, ux srclen, px dst, ux dstlen);

#endif