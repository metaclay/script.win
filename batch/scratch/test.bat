  (for %%a in (!IPADDRS!) do (
      echo Pinging %%a ...
      Call :IsPingable %%a && ( echo UP & echo. & echo SET SERVER TO : %%a & set IPADDR=%%a   & goto :OK) || (echo DOWN)
      echo.
  )) 




REM CREATE SYMLINK
echo.
echo       CREATE SYMLINK
echo -------------------------------------------------------------
echo.
echo create symlink - mklink /D !PROJECTVOL_SRC!\CLAYNET !CLAYNET_SRC!
mklink /D !PROJECTVOL_SRC!\CLAYNET !CLAYNET_SRC!  || goto :ERR
echo ... done
echo.

echo create symlink - mklink /D  !PROJECTVOL_SRC!\projects !PROJECTS_SRC!
mklink /D !PROJECTVOL_SRC!\projects !PROJECTS_SRC!  || goto :ERR
echo ... done
echo.

echo create Z: - subst %PROJECTVOL% !PROJECTVOL_SRC!
subst %PROJECTVOL% !PROJECTVOL_SRC!  || goto :ERR
echo ... done
echo.
REM label %PROJECTVOL% PROJECTVOL

echo create Desktop symlink : mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL !PROJECTVOL_SRC!
mklink /D %HOME_LOCAL%\Desktop\PROJECTVOL !PROJECTVOL_SRC!  || goto :ERR
echo ... done
echo.
echo.
echo ALL GOOD.
echo.
echo.

  
