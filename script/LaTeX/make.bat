@echo off

rem Define variables
set TEX=*.tex
set PDF=*.pdf
set PNG=*.png
set BIB=*.bib
set MAINTEX="PAPERNAME.tex"

rem Targets
if "%1"=="c" goto compile
if "%1"=="f" goto format
if "%1"=="m" goto merge
goto end

:compile
latexmk
goto end

:format
latexindent -w %MAINTEX%
del *.bak* *.log
goto end

:merge
latexpand.exe PAPERNAME.tex > output.tex

:end
