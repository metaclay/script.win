@echo off
setlocal ENABLEDELAYEDEXPANSION

set LAN=1
set EXT=1
set PROJECTVOL=Z:
set EXT_DRIVE=X:
set CLAY=__CLAY__
set USERSDIR="__USERS__"
set HOME_LOCAL=C:\Users\%USERNAME%
set HOME_EXT=%EXT_DRIVE%\%USERSDIR%\%USERNAME%

cls
echo PROJECTVOL SETUP v.1
if %EXT% == 1 ( echo | set /p=EXT MODE ) else (echo | set /p=LOCAL MODE  )
if %LAN% == 1 (
  echo + LAN
) 
echo.
echo.



if %LAN% == 1 (

  echo       CHECKING LAN
  echo -------------------------------------------------------------
  set IPADDRS=192.168.1.10 192.168.1.20
  (for %%a in (!IPADDRS!) do (
      echo | set /p=%%a 
      Call :IsPingable %%a && ( 
        echo --- OK
        echo. 
        set IPADDR=%%a
        goto :OK
        ) || (echo DOWN)
  )) 
  echo NO SERVER IS AVAILABLE ... CANNOT USE LAN !
  goto :ERR
) else ( 

  goto :OK
)

:IsPingable <comp>
ping -n 1 -w 3000 -4 -l 8 "%~1" | Find "TTL=">nul  
exit /b

:OK
echo.
echo       FOLDER SETUP
echo -------------------------------------------------------------


REM SETUP VARS

if %EXT% == 1 (
  set CLAY_HOME=%HOME_EXT%\%CLAY%
) else (
  set CLAY_HOME=%HOME_LOCAL%\%CLAY%
)
set PROJECTVOL_SRC=!CLAY_HOME!\PROJECTVOL_SRC


if %LAN% == 1 (
  set CLAYNET_SRC=\\!IPADDR!\CLAYNET
  set PROJECTS_SRC=!CLAYNET_SRC!\homes\%USERNAME%\projects
) else (
  set CLAYNET_SRC=!CLAY_HOME!\CLAYNET_SRC
  set PROJECTS_SRC=!CLAY_HOME!\PROJECTS_SRC
)


REM CREATE DIRS IF DO NOT EXIST

if %EXT% == 1 (
  if not exist %EXT_DRIVE%\%USERSDIR% (
    echo create folder - %EXT_DRIVE%\%USERSDIR%
    mkdir %EXT_DRIVE%\%USERSDIR% || goto :ERR
  ) else (
    echo %EXT_DRIVE%\%USERSDIR% ... OK
  )

  if not exist %HOME_EXT% (
    echo create folder - %HOME_EXT%
    mkdir %HOME_EXT% || goto :ERR
  ) else (
    echo %HOME_EXT% ... OK
  )

)

if not exist !CLAY_HOME! (
  echo create folder - !CLAY_HOME!
  mkdir !CLAY_HOME! || goto :ERR
) else (
  echo !CLAY_HOME! ... OK

)
if not exist !PROJECTVOL_SRC! (
  echo create folder - !PROJECTVOL_SRC!
  mkdir !PROJECTVOL_SRC! || goto :ERR
) else (
  echo !PROJECTVOL_SRC! ... OK
)

set folders=elements localized render
(for %%a in (%folders%) do ( 
  if not exist !PROJECTVOL_SRC!\%%a (
    echo create folder - !PROJECTVOL_SRC!\%%a
    mkdir !PROJECTVOL_SRC!\%%a || goto :ERR
  ) else (
    echo !PROJECTVOL_SRC!\%%a ... OK
  )
))

if %LAN% == 0 (
  if not exist !CLAYNET_SRC! (
    echo create folder - !CLAYNET_SRC!
    mkdir !CLAYNET_SRC! || goto :ERR
  ) else (
    echo !CLAYNET_SRC! ... OK
  )
  if not exist !PROJECTS_SRC! (
    echo create folder - !PROJECTS_SRC!
    mkdir !PROJECTS_SRC! || goto :ERR
  ) else (
    echo !PROJECTS_SRC! ... OK

  )
  
)   else (
  echo !CLAYNET_SRC! ... OK
  echo !PROJECTS_SRC! ... OK
)

echo.
echo.
echo       DELETE / CLEAN UP SYMLINK
echo -------------------------------------------------------------
echo.
if  exist %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\CLAYNET (
  echo remove folder - %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\CLAYNET
  rmdir %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\CLAYNET || goto :ERR
) else (
  echo not exist - %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\CLAYNET

)

if  exist %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\projects (
  echo remove folder - %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\projects
  rmdir %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\projects || goto :ERR
) else (
  echo not exist - %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\projects

)

REM ON LOCAL
if  exist %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\CLAYNET (
  echo remove folder - %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\CLAYNET
  rmdir %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\CLAYNET || goto :ERR
) else (
  echo not exist - %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\CLAYNET 
)

if  exist %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\projects (
  echo remove folder - %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\projects
  rmdir %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\projects || goto :ERR
) else (
  echo not exist - %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\projects
)


if  exist %PROJECTVOL% (
  echo remove %PROJECTVOL%
  subst %PROJECTVOL% /D || goto :ERR
)  else (
  echo not exist - %PROJECTVOL%
)

if  exist %HOME_LOCAL%\Desktop\PROJECTVOL (
  echo remove folder - %HOME_LOCAL%\Desktop\PROJECTVOL
  rmdir %HOME_LOCAL%\Desktop\PROJECTVOL || goto :ERR
) else (
  echo not exist - %HOME_LOCAL%\Desktop\PROJECTVOL
)




echo.
echo.
echo       CREATE SYMLINK
echo -------------------------------------------------------------
echo.
echo create symlink - mklink /D !PROJECTVOL_SRC!\CLAYNET !CLAYNET_SRC!
mklink /D !PROJECTVOL_SRC!\CLAYNET !CLAYNET_SRC!  || goto :ERR
echo.

echo create symlink - mklink /D  !PROJECTVOL_SRC!\projects !PROJECTS_SRC!
mklink /D !PROJECTVOL_SRC!\projects !PROJECTS_SRC!  || goto :ERR
echo.

echo create Z: - subst %PROJECTVOL% !PROJECTVOL_SRC!
subst %PROJECTVOL% !PROJECTVOL_SRC!  || goto :ERR
echo.
REM label %PROJECTVOL% PROJECTVOL

echo create Desktop symlink : mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL !PROJECTVOL_SRC!
mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL !PROJECTVOL_SRC!  || goto :ERR
echo.
echo.
echo       RESULT
echo -------------------------------------------------------------

subst | findstr "%PROJECTVOL%"
echo.
dir %PROJECTVOL%
echo.
echo.
echo -------------------------------------------------------------
echo       ALL GOOD :: Have a good day.
echo -------------------------------------------------------------
echo.

endlocal
exit /b

:ERR
echo.
echo ... ERROR
echo.
exit /b
