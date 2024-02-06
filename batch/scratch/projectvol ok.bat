@echo off
setlocal ENABLEDELAYEDEXPANSION

set LAN=1
set EXT=1
set IPADDRS="192.168.1.20" "192.168.1.10"
set IPADDR=""
set OK=0

set PROJECTVOL=Z:
set EXT_HDD=X:
set CLAY=__CLAY__
set HOME_LOCAL=C:\Users\%USERNAME%
set HOME_EXT=%EXT_HDD%\__USERS__\%USERNAME%

if %EXT% == 1 (
  set CLAY_HOME=%HOME_EXT%
) else (
  set CLAY_HOME=%HOME_LOCAL%\%CLAY%
)


set IPADDR="192.168.1.10"
set OK=1

if %OK% == 1 (


  cls
  echo PROJECTVOL SETUP v.1
  echo Programmed by Andi

  if %EXT% == 1 ( echo | set /p=EXT MODE ) else (echo | set /p=LOCAL MODE  )
  if %LAN% == 1 (
    echo --- LAN // SERVER : %IPADDR%
  ) 

  echo.
  echo.



  REM FOLDER SETUP

  echo.
  echo       FOLDER SETUP
  echo -------------------------------------------------------------
  set PROJECTVOL_SRC=%CLAY_HOME%\PROJECTVOL_SRC
  if %LAN% == 1 (
    set CLAYNET_SRC=\\%IPADDR%\CLAYNET
    set PROJECTS_SRC=%CLAYNET_SRC%\homes\%USERNAME%\projects
  ) else (
    set CLAYNET_SRC=%CLAY_HOME%\CLAYNET_SRC
    set PROJECTS_SRC=%CLAY_HOME%\PROJECTS_SRC
  )

  if not exist %CLAY_HOME% (
    echo create folder - %CLAY_HOME%
    mkdir %CLAY_HOME% || goto :ERR
  ) else (
    echo %CLAY_HOME% ... OK

  )
  if not exist %PROJECTVOL_SRC% (
    echo create folder - %PROJECTVOL_SRC%
    mkdir %PROJECTVOL_SRC% || goto :ERR
  ) else (
    echo %PROJECTVOL_SRC% ... OK
  )

  set folders=elements localized render
  (for %%a in (%folders%) do ( 
    if not exist %PROJECTVOL_SRC%\%%a (
      echo create folder - %PROJECTVOL_SRC%\%%a
      mkdir %PROJECTVOL_SRC%\%%a || goto :ERR
    ) else (
      echo %PROJECTVOL_SRC%\%%a ... OK
    )
  ))

  if %LAN% == 0 (
    if not exist %CLAYNET_SRC% (
      echo create folder - %CLAYNET_SRC%
      mkdir %CLAYNET_SRC% || goto :ERR
    ) else (
      echo %CLAYNET_SRC% ... OK
    )
    if not exist %PROJECTS_SRC% (
      echo create folder - %PROJECTS_SRC%
      mkdir %PROJECTS_SRC% || goto :ERR
    ) else (
      echo %PROJECTS_SRC% ... OK

    )
    
  )   else (
    echo %CLAYNET_SRC% ... OK
    echo %PROJECTS_SRC% ... OK
  )
  echo.
  echo ... done
  echo.
  echo.



  REM SYMLINK CLEAN UP
  REM ON EXT
  echo.
  echo       DELETE / CLEAN UP SYMLINK
  echo -------------------------------------------------------------
  echo.
  if  exist %HOME_EXT%\PROJECTVOL_SRC\CLAYNET (
    echo remove folder - %HOME_EXT%\PROJECTVOL_SRC\CLAYNET
    rmdir %HOME_EXT%\PROJECTVOL_SRC\CLAYNET || goto :ERR
  ) else (
    echo not exist - %HOME_EXT%\PROJECTVOL_SRC\CLAYNET

  )

  if  exist %HOME_EXT%\PROJECTVOL_SRC\projects (
    echo remove folder - %HOME_EXT%\PROJECTVOL_SRC\projects
    rmdir %HOME_EXT%\PROJECTVOL_SRC\projects || goto :ERR
  ) else (
    echo not exist - %HOME_EXT%\PROJECTVOL_SRC\projects

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
  echo ... done
  echo.
  echo.




  REM CREATE SYMLINK
  echo.
  echo       CREATE SYMLINK
  echo -------------------------------------------------------------
  echo.
  echo create symlink - mklink /D %PROJECTVOL_SRC%\CLAYNET %CLAYNET_SRC%
  mklink /D %PROJECTVOL_SRC%\CLAYNET %CLAYNET_SRC%  || goto :ERR
  echo ... done
  echo.

  echo create symlink - mklink /D  %PROJECTVOL_SRC%\projects %PROJECTS_SRC%
  mklink /D %PROJECTVOL_SRC%\projects %PROJECTS_SRC%  || goto :ERR
  echo ... done
  echo.

  echo create Z: - subst %PROJECTVOL% %PROJECTVOL_SRC%
  subst %PROJECTVOL% %PROJECTVOL_SRC%  || goto :ERR
  echo ... done
  echo.
  REM label %PROJECTVOL% PROJECTVOL

  echo create Desktop symlink : mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL %PROJECTVOL_SRC%
  mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL %PROJECTVOL_SRC%  || goto :ERR
  echo ... done
  echo.
  echo.
  echo ... done
  echo.
  echo.

    



) 

exit /b

:ERR
echo.
echo "ERROR"
echo.
pause