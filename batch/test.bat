@echo off
set IPADDRS=192.168.1.20
set PROJECTVOL=Z:
set EXT_DRIVE=x:
set CLAY=".__CLAY__"
set USERSDIR=".__USERS__"
set HOME_LOCAL=C:\Users\%USERNAME%
set HOME_EXT=%EXT_DRIVE%\%USERSDIR%\%USERNAME%
set TEMPDIR="__TEMPDIR__"


set MOUNT_POINT=\\!IPADDR!\CLAYNET
mklink /D %HOME_LOCAL%\%CLAY%\%TEMPDIR% !MOUNT_POINT! 