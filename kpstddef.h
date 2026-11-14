// kpstddef.h

// Copyright (c) 2026-8086 KUSSA. All rights reserved.

#ifndef KPSTDDEF_H

#define KPSTDDEF_H

#define nl 0

typedef unsigned long long ux;
typedef signed long long ix;
typedef void *px;
typedef const void *rp;

typedef unsigned int ui;
typedef signed int ii;

typedef unsigned char uc;
typedef signed char ic;

typedef wchar_t wt;

typedef unsigned short us;
typedef signed short is;

typedef struct kpstruct
{
    ix kbol;
    ix koto;
}kp;


#define kk void

// #define lq *(ux*)
// #define lb *(uc*)
// #define lw *(us*)
// #define ld *(ui*)

#endif