@echo off
set PROJNAME=bla-bla

rem copy /b *.pal all.pal

:: spgbld.exe -b spgbld.ini %PROJNAME%.spg
spgbld.exe -b spgbld.ini %PROJNAME%.spg -c 0
if exist %PROJNAME%.spg goto ok


:err
echo * ERROR! *

:ok
set ASMDIR=
set PROJNAME=


pause