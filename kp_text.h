// kp_text.h

#ifndef KP_TEXT_H
#define KP_TEXT_H

#include "kpstddef.h"
// 打印数字
// （数字，目标）
// 目标剩余长度至少22字节
void kp_itoa(ux num, px dst);

// atou，十进制无符号解析
// （文本，长度）
// 长度给负数的话自动算（后果自负），长度给 0 或遇到非法字符会直接崩溃
// 调用前必须保证文本绝对合法，建议配合 kp_chks_atou 使用
// 返回解析后的无符号数字
ux kp_atou(uc *str, ux len);

// atou 的提前检查
// （文本，长度）
// 按照无符号解析，不允许负号。
// 长度给负数的话自动算。长度给 0 或大于 20 位，或包含非法字符，均返回失败。
//只能根据返回 0 判断失败
ux kp_chks_atou(uc *str, ux len);

// （文本，长度）
ix kp_atoi(uc *str, ux len);

#endif