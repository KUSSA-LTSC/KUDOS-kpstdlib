// zinitest.c
// cl /nologo /W4 /utf-8 zinitest.c kp_stdex.obj kpstdlib.obj /link kernel32.lib user32.lib

#include "kpstdlib.h"
#include "kp_zini.h"

#include <stdio.h>
#include <string.h>

#define BUFSZ 1024

static uc bu[BUFSZ];

static void make_ok(void)
{
    FILE *fp = fopen("zini_ok.ini", "wt");
    if (!fp) return;
    fputs("{Kikuri}\n", fp);
    fputs(":Hiroi:\n", fp);
    fputs("<EnableConfiguration> = [0]\n", fp);
    fputs("/ENDL/\n", fp);
    fputs("/ENDS/\n", fp);
    fclose(fp);
}

static void make_bad(void)
{
    FILE *fp = fopen("zini_bad.ini", "wt");
    if (!fp) return;
    fputs("nothing useful here\n", fp);
    fclose(fp);
}

int main(void)
{
    ux r;

    kpicinit(0);
    make_ok();
    make_bad();

    printf("=== 1. ke_rini(buf=0) ===\n");
    r = ke_rini(0, L"zini_ok.ini", bu, 0);
    printf("ret = %llu (expect 0)\n\n", (unsigned long long)r);

    printf("=== 2. ke_rini(valid) ===\n");
    r = ke_rini(0, L"zini_ok.ini", bu, BUFSZ);
    printf("ret = %llu (expect 1)\n\n", (unsigned long long)r);

    printf("=== 3. ke_vini(valid) ===\n");
    r = ke_vini(bu, kp_strlen(bu));
    printf("ret = %llu (expect 1)\n\n", (unsigned long long)r);

    printf("=== 4. ke_aini ===\n");
    {
        uc *v = ke_aini(bu, "{Kikuri}", ":Hiroi:", "<EnableConfiguration>");
        if (v == 0) {
            printf("FAILED, returned 0\n");
        } else {
            printf("ptr = [%s]\n", (char *)v);
            printf("first char = '%c' (expect '0')\n", *v);
        }
    }
    printf("\n");

    printf("=== 5. ke_aini(missing section) ===\n");
    {
        uc *v = ke_aini(bu, "{NoSuchSection}", ":Hiroi:", "<EnableConfiguration>");
        printf("ptr = %p (expect 0)\n\n", (void *)v);
    }

    printf("=== 6. ke_rini(invalid) ===\n");
    printf("(a message box will pop up, click OK to continue)\n");
    r = ke_rini(0, L"zini_bad.ini", bu, BUFSZ);
    printf("ret = %llu (expect 0)\n\n", (unsigned long long)r);

    printf("=== 7. ke_rini(missing) ===\n");
    printf("(a message box will pop up, click OK to continue)\n");
    r = ke_rini(0, L"zini_nope.ini", bu, BUFSZ);
    printf("ret = %llu (expect 0)\n\n", (unsigned long long)r);

    printf("ALL DONE\n");
    return 0;
}