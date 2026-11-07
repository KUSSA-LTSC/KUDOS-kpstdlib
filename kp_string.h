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
// memcmp，不检查空指针
// 相等返回末尾指针，不相等返回0，并且往返回地址写偏移+1，没长度返回0 ,返回地址写0
// （源，源长，目标，返回值指针）
ux kp_memcmp(px src, ux srclen , px dst , px returnval);
// strstr，不检查空指针
// 返回索引+1，零代表没有找到
// 源长是负数就自动算，目标长必须填
// （源，源长，目标，目标长）
ux kp_strstr(px src, ux srclen, px dst, ux dstlen);

#endif