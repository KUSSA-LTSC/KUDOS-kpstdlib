// kp_zini.c

#ifndef KP_ZINI_C

#define KP_ZINI_C

#include "kpstdlib.h"

#include <stdio.h>
#include <string.h>
#include <wchar.h>

#include <windows.h>

// 自我包含
#include "kp_zini.h"

// 打开配置文件函数
// 默认已经设置了目录或者提供了完整的文件名
// （标志，文件名，缓冲区，缓冲区长度）
// 标志默认填 0就好，失败返回 0
ux ke_rini(ux bitmap, wt *filename, uc *bu, ux buflen)
{
    if (not buflen)
    {
        return 0;
    }
    FILE *fp = _wfopen(filename, L"rt");
    {
        if (fp == NULL)
        {
            kp_error(nl, L"打开文件失败");
            return 0;
        }
    }
    size_t readsize = fread(bu, 1, buflen - 1, fp);
    {
        ui ch = fgetc(fp);
        if (readsize == buflen - 1 && ch != EOF)
        {
            kp_error(nl, L"文件太大");
            fclose(fp);
            return 0;
        }
        ungetc(ch, fp);

        bu[readsize] = '\0';
        fclose(fp);
    }
    if (not ke_vini(bu, kp_strlen(bu)))
    {
        kp_error(nl, L"错误的配置文件");
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
uc *ke_aini(px zone, px section, px label, px key)
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

#endif