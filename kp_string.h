// kp_string.h

#ifndef KP_STRING_H

#define KP_STRING_H

#include "kpstddef.h"

ux kp_strlen(const uc *str);
// 返回找到的字符的索引+1（1-based）。如果要找的字符是 '\0'，则返回 strlen（如果 len 传入负数，则自动计算）。
// 返回 0 表示没找到。
ux kp_strchr(ux dust, const uc *str, ux strlen, uc ch);

#endif