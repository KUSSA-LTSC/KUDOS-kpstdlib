// kp_zini.c

// Copyright (c) 2026-8086 KUSSA. All rights reserved.

#ifndef KP_ZINI_C

#define KP_ZINI_C

#include "kpstdlib.h"

#include <stdio.h>
#include <string.h>
#include <wchar.h>

#include <windows.h>

// 自我包含
#include "kp_zini.h"

// 设置当前目录函数
// 初始化时候可以用，禁止多线程
// 只能判断返回 0为失败！
ux ke_stcdir(void)
{

    wt filename[MAX_PATH];

    // 强制临时变量
    // 获取文件名
    ux n = GetModuleFileNameW(nl, filename, MAX_PATH);
    // 处理
    { // 错误处理
        if (n == 0)
        {
            // kp_error(nl, L"拿文件名字时候出错");
            return 0;
        }
        // 文件名太长
        if (n >= MAX_PATH)
        {
            // kp_error(nl, L"文件名或路径太长");
            return 0;
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
            // kp_error(nl, L"文件名字里面没有反斜杠");
            return 0;
        }
        // 设置目录
        if (SetCurrentDirectoryW(filename) == 0)
        {
            // kp_error(nl, L"设置当前目录失败");
            return 0;
        }
    }

    return 1;
}

// 打开配置文件函数
// 默认已经设置了目录或者提供了完整的文件名
// （标志，文件名，缓冲区，缓冲区长度）
// 标志默认填 0就好，失败返回 0
ux ke_rini(ux bitmap, const wt *filename, uc *bu, ux buflen)
{
    (void)bitmap;
    if (not buflen)
    {
        return 0;
    }
    FILE *fp = _wfopen(filename, L"rt");
    {
        if (fp == NULL)
        {
            // kp_error(nl, L"打开文件失败");
            return 0;
        }
    }
    size_t readsize = fread(bu, 1, buflen - 1, fp);
    {
        ui ch = fgetc(fp);
        if (readsize == buflen - 1 && ch != EOF)
        {
            // kp_error(nl, L"文件太大");
            fclose(fp);
            return 0;
        }
        // ungetc(ch, fp);

        bu[readsize] = '\0';
        fclose(fp);
    }
    if (not ke_vini(bu, kp_strlen(bu)))
    {
        // kp_error(nl, L"错误的配置文件");
        return 0;
    }
    return 1;
}

// 检查配置文件函数
// （缓冲区指针，字符串长）
// 合法 Kikuri 配置文件返回 1，非法返回 0
ux ke_vini(const uc *zone, ux zlen)
{
    if (*zone == 0)
    {
        return 0;
    }
    ux a = kp_strstr("{Kikuri}", (ux)-1, zone, zlen);
    if (a == 0)
    {
        return 0;
    }
    ux b = kp_strstr("/ENDS/", (ux)-1, (uc *)((ux)zone) + a, zlen - a);
    if (b == 0)
    {
        return 0;
    }
    ux c = kp_strstr(":Hiroi:", (ux)-1, (uc *)((ux)zone + a), b);
    if (c == 0)
    {
        return 0;
    }
    b = b - c;
    a = a + c;
    b = kp_strstr("/ENDL/", (ux)-1, (uc *)((ux)zone) + a, b);
    if (b == 0)
    {
        return 0;
    }
    c = kp_strstr("<EnableConfiguration>", (ux)-1, (uc *)((ux)zone + a), b);
    if (c == 0)
    {
        return 0;
    }
    return 1;
}

// 解配置文件函数
// （缓冲区，段名，标签，键名）
// 返回文本指针，失败返回 0
uc *ke_aini(rp zone, rp section, rp label, rp key)
{
    ux zlen = kp_strlen(zone);
    ux a = kp_strstr(section, (ux)-1, zone, zlen);
    if (a == 0)
    {
        return 0;
    }
    zlen = kp_strstr("/ENDS/", (ux)-1, (uc *)((ux)zone + a), zlen - a);
    if (zlen == 0)
    {
        return 0;
    }
    ux b = kp_strstr(label, (ux)-1, (uc *)((ux)zone + a), zlen);
    if (b == 0)
    {
        return 0;
    }
    zlen = zlen - b;
    a = a + b - 1;
    zlen = kp_strstr("/ENDL/", (ux)-1, (uc *)((ux)zone + a), zlen);
    if (zlen == 0)
    {
        return 0;
    }
    ux c = kp_strstr(key, (ux)-1, (uc *)((ux)zone + a), zlen);
    if (c == 0)
    {
        return 0;
    }
    a = a + c;
    zlen = zlen - c;
    b = kp_strchr(0, (uc *)((ux)zone + a), zlen, '=');
    if (b == 0)
    {
        return 0;
    }
    zlen = zlen - b;
    a = a + b;
    c = kp_strchr(0, (uc *)((ux)zone + a), zlen, '[');
    if (c == 0)
    {
        return 0;
    }
    return (uc *)((ux)zone + a + c);
}

// 找到键值后复制
// （键值指针，标志，目标缓冲区，目标缓冲区长度）
// 标志目前给 0就可以
// 成功返回指针，失败或空内容返回 0
uc *ke_cini(const uc *src, ux bitmap, uc *dst, ux dstlen)
{
    (void)bitmap;
    ux a = kp_strchr(0, src, (ux)-1, ']') - 1;
    if (a == (ux)-1 or a == 0 or a >= dstlen)
    {
        return 0;
    }
    kp_movsb(src, a, dst, dstlen);
    dst[a] = 0;
    return (uc *)((ux)src + a);
}

#endif