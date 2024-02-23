@echo off
setlocal ENABLEDELAYEDEXPANSION

set LAN_CLAYNET=1
set LAN_PROJECT=0
set EXT=0

set ASK=
set CONFIRM=
set MOUNT_TO_DESKTOP=0

set IPADDRS=192.168.1.10 192.168.1.20
set PROJECTVOL=Z:
set EXT_DRIVE=x:
set CLAY=".__CLAY__"
set USERSDIR=".__USERS__"
set HOME_LOCAL=C:\Users\%USERNAME%
set HOME_EXT=%EXT_DRIVE%\%USERSDIR%\%USERNAME%

set PUBLIC="Public"
set HOME_LOCAL_PUB=C:\Users\%PUBLIC%
set HOME_EXT_PUB=%EXT_DRIVE%\%USERSDIR%\%PUBLIC%

set TEMPDIR="__TEMPDIR__"


set LAN_CLAYNET0=!LAN_CLAYNET!
set LAN_PROJECT0=!LAN_PROJECT!
set EXT0=!EXT!

cls
echo PROJECTVOL SETUP
echo ================
echo.


:ASKME
if !ASK! == 1 (
    
    cls
    echo PROJECTVOL SETUP
    echo ================
    echo.

    set /p LAN_CLAYNET="LAN CLAYNET (!LAN_CLAYNET!) ? "
    set /p LAN_PROJECT="LAN PROJECT (!LAN_PROJECT!) ? "
    set /p EXT="EXT (!EXT!) ? "
    set CONFIRM=1
    echo.

) else (
echo LAN CLAYNET = !LAN_CLAYNET!
echo LAN PROJECT = !LAN_PROJECT!
echo EXT = !EXT!
echo.
)


if NOT "!CONFIRM!" equ "" (
    set CONFIRM=
    set /p CONFIRM="confirm ? "

    if NOT "!CONFIRM!" equ "" (
        set LAN_CLAYNET=!LAN_CLAYNET0!
        set LAN_PROJECT=!LAN_PROJECT0!
        set EXT=!EXT0!
        set ASK=1
        goto ASKME
    )
    
)





:HEADER
cls
echo PROJECTVOL SETUP
echo ================

set /a "LAN=!LAN_PROJECT!+!LAN_CLAYNET!"

if !EXT! == 1 ( set DRIVE_MODE=EXT) else ( set DRIVE_MODE=NO_EXT)


echo | set /p=MODE : !DRIVE_MODE! 
if !LAN! gtr 0 (
  if !LAN_CLAYNET! == 1 ( set CLAYNET_USE= +CLAYNET) else ( set CLAYNET_USE=)
  if !LAN_PROJECT! == 1 ( set PROJECT_USE= +PROJECT) else ( set PROJECT_USE=)
  echo | set /p="!CLAYNET_USE!!PROJECT_USE!"
) 
echo.
echo.
echo LAN CLAYNET = !LAN_CLAYNET!
echo LAN PROJECT = !LAN_PROJECT!
echo EXT = !EXT!
echo.

if !EXT! == 1 (
  if not exist %EXT_DRIVE% (
    echo ^>^>^>^>^>^> ERROR - EXT : %EXT_DRIVE%\ DOES NOT AVAILABLE.
    echo.
    set /p USELOCAL="Use Internal Drive ? "
    if "!USELOCAL!" equ "" (
      set EXT=0
      goto :HEADER
    ) else (
      exit /b
    )
  )
)



if !LAN! gtr 0 (
    echo.
    echo       CHECKING LAN
    echo ------------------------------------------------------------------------
    
    (for %%a in (!IPADDRS!) do (
        echo | set /p=%%a 
        Call :IsPingable %%a && ( 
        echo | set /p=" OK"
        
        set IPADDR=%%a

        if not exist %HOME_LOCAL%\%CLAY% (
            mkdir %HOME_LOCAL%\%CLAY% || goto :ERR
        )

        if not exist %HOME_LOCAL_PUB%\%CLAY% (
            mkdir %HOME_LOCAL_PUB%\%CLAY% || goto :ERR
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
    echo.
    echo ^>^>^>^>^>^> NO SERVER !
    echo.
  
    set /p SKIPLAN="skip LAN ? "
    if "!SKIPLAN!" equ "" (
        set LAN_CLAYNET=0
        set LAN_PROJECT=0
        goto :HEADER
    ) else (
        exit /b
    )




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

if !EXT! == 1 (
  set CLAY_HOME=%HOME_EXT%\%CLAY%
  set CLAY_HOME_PUB=%HOME_EXT_PUB%\%CLAY%
) else (
  set CLAY_HOME=%HOME_LOCAL%\%CLAY%
  set CLAY_HOME_PUB=%HOME_LOCAL_PUB%\%CLAY%
)
set PROJECTVOL_SRC=!CLAY_HOME!\PROJECTVOL_SRC


if !LAN_CLAYNET! == 1 (
  set CLAYNET_SRC=\\!IPADDR!\CLAYNET
) else (
  set CLAYNET_SRC=!CLAY_HOME_PUB!\CLAYNET_SRC
)

if !LAN_PROJECT! == 1 (
set PROJECTS_SRC=\\!IPADDR!\CLAYNET\homes\%USERNAME%\projects
) else (
set PROJECTS_SRC=!CLAY_HOME!\PROJECTS_SRC
)


set LOCALIZED_CLAYNET_SRC=!CLAY_HOME_PUB!\CLAYNET_SRC


REM CREATE DIRS IF DO NOT EXIST

if !EXT! == 1 (
  if not exist %EXT_DRIVE%\%USERSDIR% (
    echo create folder - %EXT_DRIVE%\%USERSDIR%
    mkdir %EXT_DRIVE%\%USERSDIR% || goto :ERR
    attrib +h %EXT_DRIVE%\%USERSDIR%
  ) else (
    echo %EXT_DRIVE%\%USERSDIR% ... OK
  )

  if not exist %HOME_EXT% (
    echo create folder - %HOME_EXT%
    mkdir %HOME_EXT% || goto :ERR
  ) else (
    echo %HOME_EXT% ... OK
  )

  if not exist %HOME_EXT_PUB% (
    echo create folder - %HOME_EXT_PUB%
    mkdir %HOME_EXT_PUB% || goto :ERR
  ) else (
    echo %HOME_EXT_PUB% ... OK
  )  

)

if not exist !CLAY_HOME! (
  echo create folder - !CLAY_HOME!
  mkdir !CLAY_HOME! || goto :ERR
  attrib +h !CLAY_HOME!
) else (
  echo !CLAY_HOME! ... OK

)


if not exist !CLAY_HOME_PUB! (
  echo create folder - !CLAY_HOME_PUB!
  mkdir !CLAY_HOME_PUB! || goto :ERR
  attrib +h !CLAY_HOME_PUB!
) else (
  echo !CLAY_HOME_PUB! ... OK

)

if not exist !PROJECTVOL_SRC! (
  echo create folder - !PROJECTVOL_SRC!
  mkdir !PROJECTVOL_SRC! || goto :ERR
) else (
  echo !PROJECTVOL_SRC! ... OK
)


if not exist !LOCALIZED_CLAYNET_SRC! (
  echo create folder - !LOCALIZED_CLAYNET_SRC!
  mkdir !LOCALIZED_CLAYNET_SRC! || goto :ERR
) else (
  echo !LOCALIZED_CLAYNET_SRC! ... OK
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

if !LAN_CLAYNET! == 0 (
  if not exist !CLAYNET_SRC! (
    echo create folder - !CLAYNET_SRC!
    mkdir !CLAYNET_SRC! || goto :ERR
  ) else (
    echo !CLAYNET_SRC! ... OK
  )  
)   else (
  echo !CLAYNET_SRC! ... OK
)


if !LAN_PROJECT! == 0 (
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


REM SET FOLDER TO INVISIBLE
if exist %HOME_LOCAL%\%CLAY% (
  attrib +h %HOME_LOCAL%\%CLAY% || goto :ERR
)

if exist %HOME_LOCAL_PUB%\%CLAY% (
  attrib +h %HOME_LOCAL_PUB%\%CLAY% || goto :ERR
)

if exist %EXT_DRIVE%\%USERSDIR% (
  attrib +h %EXT_DRIVE%\%USERSDIR% || goto :ERR
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


REM mount z:/projectvol to desktop

if %MOUNT_TO_DESKTOP% == 1 (
    if  exist %HOME_LOCAL%\Desktop\PROJECTVOL (
      echo remove folder - %HOME_LOCAL%\Desktop\PROJECTVOL
      rmdir %HOME_LOCAL%\Desktop\PROJECTVOL || goto :ERR
    ) else (
      echo not exist - %HOME_LOCAL%\Desktop\PROJECTVOL
    )
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

if %MOUNT_TO_DESKTOP% == 1 (
    echo create Desktop symlink : mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL !PROJECTVOL_SRC!
    mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL !PROJECTVOL_SRC!  || goto :ERR
)
echo.
echo.
echo.
echo.

echo ------------------------------------------------------------------------

echo | set /p=".     RESULT : !DRIVE_MODE! "

if !LAN! gtr 0 (
  echo | set /p="!CLAYNET_USE!!PROJECT_USE! ( !IPADDR! )"
) 
echo.
echo ------------------------------------------------------------------------
echo.
subst | findstr "%PROJECTVOL%"

FOR /f "tokens=4,5,*" %%A IN ('dir %%PROJECTVOL%%\localized\Z_ /AL ^| findstr "CLAYNET"') DO ( 
    SET LOCALIZED_RESULT=%%~A %%~B %%~C 
    )

echo %PROJECTVOL%\localized\Z_\!LOCALIZED_RESULT!

REM dir %PROJECTVOL% | findstr "CLAYNET projects"

for /f "tokens=4,5,*" %%A in ('dir %PROJECTVOL% /AL ^| findstr CLAYNET ^| findstr /v projects') do (echo %%~A %%~B %%~C)

for /f "tokens=4,5,*" %%A in ('dir %PROJECTVOL% /AL ^| findstr projects') do (echo %%~A %%~B %%~C)

dir /b %PROJECTVOL% | findstr "elements render"
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
