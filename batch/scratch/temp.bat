@echo off




set LAN=1
set EXT=0
set IPADDRS="192.168.1.20" "192.168.1.10"
set IPADDR=""
set OK=0


set IPADDR="192.168.1.10"
set OK=1

if %OK% == 1 (
  set PROJECTVOL=Z:
  set EXT_HDD=Z:
  set HOME_LOCAL=C:\Users\%USERNAME%
  set HOME_EXT=%EXT_HDD%\__USERS__\%USERNAME%
  set CLAY=__CLAY__

  cls
  echo PROJECTVOL SETUP
  if %LAN% == 1 (
    echo SERVER : %IPADDR%
    set LANSTATE=+LAN
  ) 
  if %EXT% == 1 ( echo EXT MODE %LANSTATE%) else (echo LOCAL MODE %LANSTATE% )

  echo.
  echo.



  REM FOLDER SETUP
  if %EXT% == 1 (
    set HOME=%HOME_EXT%
  ) else (
    set HOME=%HOME_LOCAL%\%CLAY%
  )

  set PROJECTVOL_SRC=%HOME%\PROJECTVOL_SRC
  if %LAN% == 1 (
    set CLAYNET_SRC=\\%IPADDR%\CLAYNET
    set PROJECTS_SRC=%CLAYNET_SRC%\homes\%USERNAME%\projects
  ) else (
    set CLAYNET_SRC=%HOME%\CLAYNET_SRC
    set PROJECTS_SRC=%HOME%\PROJECTS_SRC
  )

  if not exist %HOME% (
    echo create folder - %HOME%
    mkdir %HOME% || goto :ERR
  ) else (
    echo %HOME% ... OK

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
  echo ------ FOLDER SETUP ... done
  echo.
  echo.



  REM SYMLINK CLEAN UP
  REM ON EXT
  if  exist %HOME_EXT%\PROJECTVOL_SRC\CLAYNET (
    echo remove folder - %HOME_EXT%\PROJECTVOL_SRC\CLAYNET
    rmdir %HOME_EXT%\PROJECTVOL_SRC\CLAYNET || goto :ERR
  )

  if  exist %HOME_EXT%\PROJECTVOL_SRC\projects (
    echo remove folder - %HOME_EXT%\PROJECTVOL_SRC\projects
    rmdir %HOME_EXT%\PROJECTVOL_SRC\projects || goto :ERR
  )

  REM ON LOCAL
  if  exist %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\CLAYNET (
    echo remove folder - %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\CLAYNET
    rmdir %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\CLAYNET || goto :ERR
  )

  if  exist %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\projects (
    echo remove folder - %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\projects
    rmdir %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\projects || goto :ERR
  )

  if  exist %PROJECTVOL%\XX (
    echo remove folder - %PROJECTVOL%\XX
    rmdir %PROJECTVOL%\XX || goto :ERR
  )  

  if  exist %HOME_LOCAL%\Desktop\PROJECTVOL (
    echo remove folder - %HOME_LOCAL%\Desktop\PROJECTVOL
    rmdir %HOME_LOCAL%\Desktop\PROJECTVOL || goto :ERR
  ) 

  echo.
  echo ------ DELETE SYMLINK ... done
  echo.
  echo.




  REM CREATE SYMLINK
  mklink /D %PROJECTVOL_SRC%\CLAYNET %CLAYNET_SRC%
  mklink /D %PROJECTVOL_SRC%\projects %PROJECTS_SRC%
  mklink /D %PROJECTVOL%\XX %PROJECTVOL_SRC%
  mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL %PROJECTVOL_SRC%
  echo.
  echo ------ CREATE SYMLINK ... done
  echo.
  echo.

    



) 

exit /b

:ERR
echo "ERROR"
pause