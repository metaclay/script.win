@echo off
setlocal ENABLEDELAYEDEXPANSION

set LAN_CLAYNET=1
set LAN_PROJECT=1
set EXT=0
set /a "LAN=%LAN_PROJECT%+%LAN_CLAYNET%"

set PROJECTVOL=Z:
set EXT_DRIVE=xs:
set CLAY=__CLAY__
set USERSDIR="__USERS__"
set HOME_LOCAL=C:\Users\%USERNAME%
set HOME_EXT=%EXT_DRIVE%\%USERSDIR%\%USERNAME%
set TEMPDIR="__TEMPDIR__"

cls
echo PROJECTVOL SETUP
echo ================

if %EXT% == 1 ( set DRIVE_MODE=EXT) else ( set DRIVE_MODE=LOCAL)
if %LAN% gtr 0 ( set LAN_MODE=+LAN) else ( set LAN_MODE=)


echo | set /p=MODE : !DRIVE_MODE! !LAN_MODE! 
if %LAN% gtr 0 (
  if %LAN_CLAYNET% == 1 ( set CLAYNET_USE= +CLAYNET) else ( set CLAYNET_USE=)
  if %LAN_PROJECT% == 1 ( set PROJECT_USE= +PROJECT) else ( set PROJECT_USE=)
  echo | set /p="(!CLAYNET_USE!!PROJECT_USE! )"
) 
echo.
echo.
echo.

if %EXT% == 1 (
  if not exist %EXT_DRIVE% (
    echo ERROR - EXT : %EXT_DRIVE%\ DOES NOT AVAILABLE.
    goto :ERR
  )
)



if %LAN% gtr 0 (

  echo       CHECKING LAN
  echo ------------------------------------------------------------------------
  set IPADDRS=192.168.1.10 192.168.1.20
  (for %%a in (!IPADDRS!) do (
      echo | set /p=%%a 
      Call :IsPingable %%a && ( 
        echo | set /p=" OK"
        
        set IPADDR=%%a

        if not exist %HOME_LOCAL%\%CLAY% (
            mkdir %HOME_LOCAL%\%CLAY% || goto :ERR
        )

        if exist %HOME_LOCAL%\%CLAY%\%TEMPDIR% (
            rmdir %HOME_LOCAL%\%CLAY%\%TEMPDIR% || goto :ERR
        )        

        set MOUNT_POINT=\\!IPADDR!\CLAYNET
        mklink /D %HOME_LOCAL%\%CLAY%\%TEMPDIR% !MOUNT_POINT! > nul 2>&1
        cd %HOME_LOCAL%\%CLAY%\%TEMPDIR% > nul 2>&1 && ( 
            echo  ---^> MOUNT POINT : !MOUNT_POINT! --- OK
            echo.
            echo.
            goto :OK
             ) || ( 
            echo  ---^> MOUNT POINT : !MOUNT_POINT! FAIL OR NOT AVAILABLE
            goto :ERR 
            )

        ) || (echo DOWN)
  )) 
  echo NO SERVER !
  goto :ERR
) else ( 

  goto :OK
)

:IsPingable <comp>
ping -n 1 -w 3000 -4 -l 8 "%~1" | Find "TTL=">nul  
exit /b

:OK

echo       FOLDER SETUP
echo ------------------------------------------------------------------------


REM SETUP VARS

if %EXT% == 1 (
  set CLAY_HOME=%HOME_EXT%\%CLAY%
) else (
  set CLAY_HOME=%HOME_LOCAL%\%CLAY%
)
set PROJECTVOL_SRC=!CLAY_HOME!\PROJECTVOL_SRC


if %LAN_CLAYNET% == 1 (
  set CLAYNET_SRC=\\!IPADDR!\CLAYNET
) else (
  set CLAYNET_SRC=!CLAY_HOME!\CLAYNET_SRC
)

if %LAN_PROJECT% == 1 (
set PROJECTS_SRC=\\!IPADDR!\CLAYNET\homes\%USERNAME%\projects
) else (
set PROJECTS_SRC=!CLAY_HOME!\PROJECTS_SRC
)


set LOCALIZED_CLAYNET_SRC=!CLAY_HOME!\CLAYNET_SRC


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

if %LAN_CLAYNET% == 0 (
  if not exist !CLAYNET_SRC! (
    echo create folder - !CLAYNET_SRC!
    mkdir !CLAYNET_SRC! || goto :ERR
  ) else (
    echo !CLAYNET_SRC! ... OK
  )  
)   else (
  echo !CLAYNET_SRC! ... OK
)


if %LAN_PROJECT% == 0 (
  if not exist !PROJECTS_SRC! (
    echo create folder - !PROJECTS_SRC!
    mkdir !PROJECTS_SRC! || goto :ERR
  ) else (
    echo !PROJECTS_SRC! ... OK
  )
)   else (
  echo !PROJECTS_SRC! ... OK
)






if not exist !PROJECTVOL_SRC!\localized\Z_\CLAYNET (
  echo create folder - !PROJECTVOL_SRC!\localized\Z_\CLAYNET
  mkdir !PROJECTVOL_SRC!\localized\Z_\CLAYNET || goto :ERR
) else (
  echo !PROJECTVOL_SRC!\localized\Z_\CLAYNET ... OK
)




echo.
echo.
echo       DELETE / CLEAN UP SYMLINK
echo ------------------------------------------------------------------------
echo.

REM ON EXT
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

if  exist %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\localized\Z_\CLAYNET (
  echo remove folder - %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\localized\Z_\CLAYNET
  rmdir %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\localized\Z_\CLAYNET || goto :ERR
) else (
  echo not exist - %HOME_EXT%\%CLAY%\PROJECTVOL_SRC\localized\Z_\CLAYNET

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

if  exist %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\localized\Z_\CLAYNET (
  echo remove folder - %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\localized\Z_\CLAYNET
  rmdir %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\localized\Z_\CLAYNET || goto :ERR
) else (
  echo not exist - %HOME_LOCAL%\%CLAY%\PROJECTVOL_SRC\localized\Z_\CLAYNET
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
echo ------------------------------------------------------------------------
echo.
echo create symlink - mklink /D !PROJECTVOL_SRC!\CLAYNET !CLAYNET_SRC!
mklink /D !PROJECTVOL_SRC!\CLAYNET !CLAYNET_SRC!  || goto :ERR
echo.

echo create symlink - mklink /D  !PROJECTVOL_SRC!\localized\Z_\CLAYNET !LOCALIZED_CLAYNET_SRC!
mklink /D !PROJECTVOL_SRC!\localized\Z_\CLAYNET !LOCALIZED_CLAYNET_SRC!  || goto :ERR
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
echo.
echo.

echo ------------------------------------------------------------------------
echo | set /p=".      RESULT : !DRIVE_MODE! !LAN_MODE! SERVER: !IPADDR! "

if %LAN% gtr 0 (
  echo | set /p="(!CLAYNET_USE!!PROJECT_USE! )"
) 
echo.
echo ------------------------------------------------------------------------
echo.
subst | findstr "%PROJECTVOL%"
echo.

FOR /F "tokens=* USEBACKQ" %%F IN (`dir /al %PROJECTVOL%\localized\Z_ ^| findstr "CLAYNET"`) DO (
SET LOCALIZED_RESULT=%%F
)

echo %PROJECTVOL%\localized\Z_ : !LOCALIZED_RESULT!

echo.
dir %PROJECTVOL% | findstr "CLAYNET projects"
dir %PROJECTVOL% | findstr "elements render"
echo.
echo.
echo ------------------------------------------------------------------------
echo       ALL GOOD :: Have a good day.
echo ------------------------------------------------------------------------
echo.

endlocal
exit /b

:ERR
echo.
echo ^>^>^>^>^>^>^>^> ERROR
echo.
exit /b
