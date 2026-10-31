@echo off

chcp 65001 >nul

echo === 汇编 ===
nasm -f win64 .\kpstdlib.asm -o .\kpstdlib.obj
if errorlevel 1 goto :fail

echo === 编译链接 C ===
cl /nologo /utf-8 test.c kpstdlib.obj /link kernel32.lib user32.lib
if errorlevel 1 goto :fail

echo === 成功 ===
pause
goto :eof

:fail
echo === 失败 ===
pause
exit /b 1