@echo off
setlocal ENABLEDELAYEDEXPANSION

set LAN=1
set EXT=1
set IPADDRS="192.168.1.20" "192.168.1.10"
set IPADDR=""
set OK=0

set PROJECTVOL=Z:
set EXT_HDD=X:
set HOME_LOCAL=C:\Users\%USERNAME%
set HOME_EXT=%EXT_HDD%\__USERS__\%USERNAME%
set CHOME2=C:\Users\%USERNAME%
set CLAY=__CLAY__


set IPADDR="192.168.1.10"
set OK=1

if %OK% == 1 (
  set PROJECTVOL=Z:
  set EXT_HDD=X:
  set HOME_LOCAL=C:\Users\%USERNAME%
  set HOME_EXT=%EXT_HDD%\__USERS__\%USERNAME%
  set CHOME2=C:\Users\%USERNAME%
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





  if not exist %CHOME2% (
    mkdir %CHOME2% 
  ) 

) 

exit /b

:ERR
echo "ERROR"
pause