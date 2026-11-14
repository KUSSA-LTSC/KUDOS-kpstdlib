// kp_win32api.h

#ifndef KP_WIN32API_H
#define KP_WIN32API_H

#include "kpstddef.h"

void kp_exit(ux exitcode);

// 封装MsgboxW

// （句柄，错误信息）
ux kp_error(ux handle, wt *koto);
// （句柄，询问信息）
ux kp_yesno(ux handle, wt *koto);
// （句柄，警告信息）
ux kp_warn(ux handle, wt *koto);
// （句柄，提示信息）
ux kp_info(ux handle, wt *koto);
// （句柄，询问信息）
ux kp_okc(ux handle, wt *koto);

#endif