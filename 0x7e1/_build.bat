@echo off

set PROJNAME=0x7e1

spgbld.exe -b spgbld.ini %PROJNAME%.spg -c 0
if exist %PROJNAME%.spg goto ok

:err
echo * ERROR! *

:ok
set ASMDIR=
set PROJNAME=


pause