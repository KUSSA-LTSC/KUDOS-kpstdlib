// test.c
//
// cl /nologo /W4 /utf-8 test.c kp_stdex.obj kpstdlib.obj /link kernel32.lib user32.lib

#include "kpstdlib.h"
#include "kp_zini.h"

#include <stdio.h>

static ux total = 0;
static ux passed = 0;

static void tcheck(ux cond, const char *name)
{
    total++;
    if (cond) {
        passed++;
        printf("[PASS] %s\n", name);
    } else {
        printf("[FAIL] %s\n", name);
    }
}

/* ---------- 合法配置 ---------- */

static uc ini_min[] =
    "{Kikuri}\n"
    ":Hiroi:\n"
    "<EnableConfiguration> = [0]\n"
    "/ENDL/\n"
    "/ENDS/\n";

static uc ini_full[] =
    "{Kikuri}\n"
    ":Hiroi:\n"
    "<EnableConfiguration> = [1]\n"
    "<AnotherKey> = [abc]\n"
    "/ENDL/\n"
    ":Bocchi:\n"
    "<Name> = [Kita]\n"
    "/ENDL/\n"
    "/ENDS/\n";

static uc ini_emptyval[] =
    "{Kikuri}\n"
    ":Hiroi:\n"
    "<EnableConfiguration> = [0]\n"
    "<Empty> = []\n"
    "/ENDL/\n"
    "/ENDS/\n";

/* ---------- 非法配置 ---------- */

static uc ini_empty[]       = "";
static uc ini_no_kikuri[]   = ":Hiroi:\n<EnableConfiguration> = [0]\n/ENDL/\n/ENDS/\n";
static uc ini_no_hiroi[]    = "{Kikuri}\n<EnableConfiguration> = [0]\n/ENDL/\n/ENDS/\n";
static uc ini_no_endl[]     = "{Kikuri}\n:Hiroi:\n<EnableConfiguration> = [0]\n/ENDS/\n";
static uc ini_no_ends[]     = "{Kikuri}\n:Hiroi:\n<EnableConfiguration> = [0]\n/ENDL/\n";
static uc ini_no_key[]      = "{Kikuri}\n:Hiroi:\n/ENDL/\n/ENDS/\n";

int main(void)
{
    kpicinit(0);

    printf("=== kp_zini test ===\n\n");

    /* ---------- ke_stcdir ---------- */
    tcheck(ke_stcdir() == 1, "ke_stcdir");

    /* ---------- ke_vfyini ---------- */
    printf("\n--- ke_vfyini ---\n");
    tcheck(ke_vfyini(ini_empty, 0) == 0, "empty buffer");
    tcheck(ke_vfyini(ini_min, kp_strlen(ini_min)) == 1, "min valid");
    tcheck(ke_vfyini(ini_full, kp_strlen(ini_full)) == 1, "full valid");
    tcheck(ke_vfyini(ini_no_kikuri, kp_strlen(ini_no_kikuri)) == 0, "missing {Kikuri}");
    tcheck(ke_vfyini(ini_no_hiroi, kp_strlen(ini_no_hiroi)) == 0, "missing :Hiroi:");
    tcheck(ke_vfyini(ini_no_endl, kp_strlen(ini_no_endl)) == 0, "missing /ENDL/");
    tcheck(ke_vfyini(ini_no_ends, kp_strlen(ini_no_ends)) == 0, "missing /ENDS/");
    tcheck(ke_vfyini(ini_no_key, kp_strlen(ini_no_key)) == 0, "missing <EnableConfiguration>");
    tcheck(ke_vfyini(ini_min, 0) == 0, "zlen = 0");
    tcheck(ke_vfyini(ini_min, 10) == 0, "zlen too small");
    tcheck(ke_vfyini(ini_emptyval, kp_strlen(ini_emptyval)) == 1, "empty value still valid");

    /* ---------- ke_getval ---------- */
    printf("\n--- ke_getval ---\n");
    uc *v;

    v = ke_getval((px)ini_min, "{Kikuri}", ":Hiroi:", "<EnableConfiguration>");
    tcheck(v != 0 && v[0] == '0', "min -> 0 (delimited)");

    v = ke_getval((px)ini_min, "Kikuri", "Hiroi", "EnableConfiguration");
    tcheck(v != 0 && v[0] == '0', "min -> 0 (bare names)");

    v = ke_getval((px)ini_full, "{Kikuri}", ":Hiroi:", "<EnableConfiguration>");
    tcheck(v != 0 && v[0] == '1', "full -> 1");

    v = ke_getval((px)ini_full, "{Kikuri}", ":Hiroi:", "<AnotherKey>");
    tcheck(v != 0 && v[0] == 'a' && v[1] == 'b' && v[2] == 'c', "full -> abc");

    v = ke_getval((px)ini_full, "{Kikuri}", ":Bocchi:", "<Name>");
    tcheck(v != 0 && v[0] == 'K' && v[1] == 'i' && v[2] == 't' && v[3] == 'a',
           "full -> Kita (second label)");

    v = ke_getval((px)ini_min, "{Kikuri}", ":Bocchi:", "<Name>");
    tcheck(v == 0, "missing label");

    v = ke_getval((px)ini_min, "{Kikuri}", ":Hiroi:", "<NotExist>");
    tcheck(v == 0, "missing key");

    v = ke_getval((px)ini_min, "{NotFound}", ":Hiroi:", "<EnableConfiguration>");
    tcheck(v == 0, "missing section");

    /* ---------- cini ---------- */
    printf("\n--- cini ---\n");
    uc dst[64];
    uc *r;

    v = ke_getval((px)ini_min, "{Kikuri}", ":Hiroi:", "<EnableConfiguration>");
    r = cini(v, 0, dst, sizeof(dst));
    tcheck(r != 0 && dst[0] == '0' && dst[1] == 0, "copy \"0\"");

    v = ke_getval((px)ini_full, "{Kikuri}", ":Hiroi:", "<AnotherKey>");
    r = cini(v, 0, dst, sizeof(dst));
    tcheck(r != 0 && dst[0] == 'a' && dst[1] == 'b' && dst[2] == 'c' && dst[3] == 0,
           "copy \"abc\"");

    r = cini(v, 0, dst, 2);
    tcheck(r == 0, "dst too small");

    v = ke_getval((px)ini_emptyval, "{Kikuri}", ":Hiroi:", "<Empty>");
    r = cini(v, 0, dst, sizeof(dst));
    tcheck(r == 0, "empty value");

    /* ---------- ke_rdfini ---------- */
    printf("\n--- ke_rdfini ---\n");
    uc zone[1024];

    tcheck(ke_rdfini(0, L"settings.ini", zone, sizeof(zone)) == 1, "settings.ini");
    tcheck(ke_rdfini(0, L"not_exist.ini", zone, sizeof(zone)) == 0, "nonexistent file");
    tcheck(ke_rdfini(0, L"settings.ini", zone, 0) == 0, "buflen = 0");

    {
        FILE *fp = fopen("too_big.ini", "wb");
        if (fp) {
            int i;
            for (i = 0; i < 2000; i++) fputc('A', fp);
            fclose(fp);
            tcheck(ke_rdfini(0, L"too_big.ini", zone, 1024) == 0, "file too big");
            remove("too_big.ini");
        } else {
            printf("[SKIP] cannot create too_big.ini\n");
        }
    }

    /* ---------- settings.ini 完整链路 ---------- */
    printf("\n--- full pipeline: settings.ini ---\n");
    if (ke_rdfini(0, L"settings.ini", zone, sizeof(zone))) {
        ux len = kp_strlen(zone);
        tcheck(ke_vfyini(zone, len) == 1, "settings.ini valid");
        v = ke_getval(zone, "{Kikuri}", ":Hiroi:", "<EnableConfiguration>");
        tcheck(v != 0, "settings.ini ke_getval");
        if (v) {
            r = cini(v, 0, dst, sizeof(dst));
            tcheck(r != 0 && dst[0] == '0', "settings.ini value == \"0\"");
            printf("  EnableConfiguration = \"%s\"\n", dst);
        }
    } else {
        printf("[SKIP] settings.ini not found\n");
    }

    /* ---------- 总结 ---------- */
    printf("\n=== %u/%u passed ===\n", (unsigned)passed, (unsigned)total);
    if (passed == total) {
        kp_info(nl, L"All tests passed");
    } else {
        kp_error(nl, L"Some tests failed, see console");
    }

    return 0;
}