@echo off


:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

::ENTER YOUR CODE BELOW:

setlocal enabledelayedexpansion
set LAN=1
set IPADDRS="192.168.1.20" "192.168.1.10"
set IPADDR=""
set OK=0


set IPADDR="192.168.1.10"
set OK=1

if %OK% == 1 (
  rmdir Z:\CLAYNET
  rmdir Z:\projects

  if %LAN% ==1 (
    mklink /D Z:\CLAYNET \\%IPADDR%\CLAYNET
    mklink /D Z:\projects \\%IPADDR%\CLAYNET\homes\andi\projects
  ) else (
    mklink /D Z:\CLAYNET Z:\__CLAY__\CLAYNET_SRC
    mklink /D Z:\projects Z:\__CLAY__\PROJECTS_SRC
  )


  if not exist Z:\elements (
    mkdir Z:\elements
  ) 

  if not exist Z:\localized (
    mkdir Z:\localized
  ) 

  if not exist Z:\render (
    mkdir Z:\render
  ) 
) 
pause