@echo off
setlocal enabledelayedexpansion

set MAIN=TechNote

if "%1"=="z" goto build
if "%1"=="o" goto open

:build
typst compile %MAIN%.typ %MAIN%.pdf
goto end

:open
start "" /max %MAIN%.pdf
goto end

:end
