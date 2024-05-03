@echo off
setlocal enabledelayedexpansion

set SRC=TechNote

if "%1"=="z" goto compile
if "%1"=="f" goto format
if "%1"=="o" goto open
if "%1"=="" goto end

:compile
typst.exe compile %SRC%.typ %SRC%.pdf
goto end

:format
for %%f in (*.typ) do (
    echo "%%f"
    typstyle.exe -i "%%f"
)
goto end

:open
start "" /max %SRC%.pdf
goto end

:end
