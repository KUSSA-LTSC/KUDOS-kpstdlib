// cfgt.c

// 一个测试文件罢了

// cl /nologo /W4 /utf-8 cfgt.c kpstdlib.obj /link kernel32.lib user32.lib

// 或者（非常不推荐）

// gcc cfgt.c kpstdlib.obj -o cfgt.exe -lkernel32 -luser32 -w -std=gnu89

// 简单想法：

    // 我打算就是个纯文本吧，目前就叫settings.ini
    // 然后结构如下
    // {section}
    // ;label:
    // <key> = [value]
    // /endl/标签结束标志
    // /ends/段结束标志
    // 所有换行会被初始化变成0A
    // 不考虑动态内存，文件不能超过1KB
    // 必须要有结束标签
    // 只有<>[]{};:包含的值没有任何歧义

#include "kpstdlib.h"

#include <stdio.h>
#include <string.h>
#include <wchar.h>

#include <windows.h>

#define thesizeofbuffer 256
// 文件名缓冲区
wt filename[thesizeofbuffer];
// 配置文件缓冲区
#define thesizeofiniz 1024
uc iniz[thesizeofiniz];

// 存值
#define lval 256
ux lenofval = lval;
uc valz[lval];

// 主程序main
ux main(void)
{

    kpicinit(0);
    // 设置目录
    {
        // 强制临时变量
        // 获取文件名
        ux n = GetModuleFileNameW(nl, filename, thesizeofbuffer);
        // 处理
        { // 错误处理
            if (n == 0)
            {
                kp_error(nl, L"拿文件名字时候出错");
                return 1;
            }
            // 文件名太长
            if (n >= thesizeofbuffer)
            {
                kp_error(nl, L"文件名字太长");
                return 2;
            }
        }
        // 去掉文件名
        wt *p = wcsrchr(filename, L'\\');
        // 设置目录
        {
            if (p)
            {
                *(p + 1) = L'\0';
            }
            else
            {
                kp_error(nl, L"文件名字里面没有反斜杠");
                return 3;
            }
            // 设置目录
            if (SetCurrentDirectoryW(filename) == 0)
            {
                kp_error(nl, L"设置当前目录失败");
                return 4;
            }
        }
        // 成功设置
        kp_info(nl, L"设置当前目录成功");
    }
#undef thesizeofbuffer

    // 读配置文件
    {
        // 打开文件
        FILE *fp = _wfopen(L"settings.ini", L"rt");
        {
            if (fp == NULL)
            {
                kp_error(nl, L"打开文件失败");
                return 5;
            }
        }
        // 读文件
        size_t readsize = fread(iniz, 1, sizeof(iniz) - 1, fp);
        {
            ui ch = fgetc(fp);
            if (readsize == sizeof(iniz) - 1 && ch != EOF)
            {
                kp_error(nl, L"文件太大");
                fclose(fp);
                return 6;
            }
            ungetc(ch, fp);

            iniz[readsize] = '\0';
            fclose(fp);
        }
        // 成功提示
        kp_info(nl, L"读取文件成功");
        // 一堆错误处理
        {
            if (strstr(iniz, "{Kikuri}") == NULL)
            {
                kp_error(nl, L"没有找到 {Kikuri} ，可能不是正确的配置文件");
                return 7;
            }
            if (strstr(iniz, "/ENDS/") == NULL)
            {
                kp_error(nl, L"没有找到 /ENDS/ ，可能不是正确的配置文件");
                return 8;
            }

            ux kikuri = strstr(iniz, "{Kikuri}");

            kikuri = strchr(kikuri, '}') + 1;

            ux sectionend = strstr(kikuri, "/ENDS/");

            ux EnableConfigration = strstr(kikuri, "<EnableConfiguration>");

            if (EnableConfigration == NULL || EnableConfigration > sectionend)
            {
                kp_error(nl, L"没有找到 EnableConfiguration ，可能不是正确的配置文件");
                return 9;
            }

            ux equ = strchr(EnableConfigration, '>');
            equ++;
            equ = strchr(equ, '=');
            if (equ == NULL || equ > sectionend)
            {
                kp_error(nl, L"没有找到 EnableConfiguration 的等号 ，可能不是正确的配置文件");
                return 10;
            }

            equ++;

            ux lf = strchr(equ, '[');
            if (lf == NULL || lf > sectionend)
            {
                kp_error(nl, L"没有找到 EnableConfiguration 的 \'[\'，可能不是正确的配置文件");
                return 11;
            }
            lf++;

            ux rf = strchr(equ, ']');
            if (rf == NULL || rf > sectionend)
            {
                kp_error(nl, L"没有找到 EnableConfiguration 的 \']\' ，可能不是正确的配置文件");
                return 12;
            }

            ux vlen = rf - lf;
            if (vlen >= lval)
            {
                kp_error(nl, L"这个值太长啦");
                return 13;
            }
#undef lval

            strncpy(valz, lf, rf - lf);
            if (valz[0] == 0)
            {
                kp_error(nl, L"这个项是空的");
                return 14;
            }
            if (valz[0] == '0')
            {
                kp_warn(nl, L"配置文件：禁用");
                kp_info(nl, L"正常退出");
                return 0;
            }
            else
            {
                kp_info(nl, L"配置文件：启用");
            }
        }
        // ASCII显示
        MessageBoxA(nl,
                    valz,
                    "Value:",
                    nl);
        kp_info(nl, L"正常退出");
    }

    return 0;
}
