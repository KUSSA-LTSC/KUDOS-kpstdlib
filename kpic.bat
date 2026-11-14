@echo off

chcp 65001 >nul

echo === 1. 汇编核心库 ===
nasm -f win64 .\kpstdlib.asm -o .\kpstdlib.obj
if errorlevel 1 goto :fail

echo === 2. 编译 C 拓展库  ===
cl /nologo /utf-8 /c kp_stdex.c /W4
if errorlevel 1 goto :fail

::echo === 3. 编译业务代码并链接生成 test.exe ===
:: 注意这里只有 test.c，以及两个 obj 文件
::cl /nologo /utf-8 test.c kp_stdex.obj kpstdlib.obj /link kernel32.lib user32.lib gdi32.lib
::if errorlevel 1 goto :fail

echo === 全部成功 ===
pause
goto :eof

:fail
echo === 构建失败，请检查报错 ===
pause
exit /b 1