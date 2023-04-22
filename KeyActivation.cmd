@setlocal DisableDelayedExpansion
@echo off

::  discord.gg/clusiive
::  kadee#6307

::============================================================================
::  
::     __ __        __              ___      __  _           __          
::    / //_/__ ____/ /__ ___ ___   / _ |____/ /_(_)  _____ _/ /____  ____
::   / ,< / _ `/ _  / -_) -_|_-<  / __ / __/ __/ / |/ / _ `/ __/ _ \/ __/
::  /_/|_|\_,_/\_,_/\__/\__/___/ /_/ |_\__/\__/_/|___/\_,_/\__/\___/_/   
::  
::============================================================================




::========================================================================================================================================

:: Re-launch the script with x64 process if it was initiated by x86 process on x64 bit Windows
:: or with ARM64 process if it was initiated by x86/ARM32 process on ARM64 Windows

set "_cmdf=%~f0"
for %%# in (%*) do (
if /i "%%#"=="r1" set r1=1
if /i "%%#"=="r2" set r2=1
)

if exist %SystemRoot%\Sysnative\cmd.exe if not defined r1 (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* r1"
exit /b
)

:: Re-launch the script with ARM32 process if it was initiated by x64 process on ARM64 Windows

if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 if not defined r2 (
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %* r2"
exit /b
)

::  Set Path variable, it helps if it is misconfigured in the system

set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "PATH=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%PATH%"
)

::  Check LF line ending

pushd "%~dp0"
>nul findstr /rxc:".*" "%~nx0"
if not %errorlevel%==0 (
echo:
echo Error: Script either has LF line ending issue, or it failed to read itself.
echo:
popd
ping 127.0.0.1 -n 6 > nul
exit /b
)
popd

::========================================================================================================================================

cls
color 09
title  Windows Activation .gg/clusiive

set _args=
set _elev=
set _MASunattended=

set _args=%*
if defined _args set _args=%_args:"=%
if defined _args (
for %%A in (%_args%) do (
if /i "%%A"=="-el"                    set _elev=1
)
)

if defined _args echo "%_args%" | find /i "/" >nul && set _MASunattended=1

::========================================================================================================================================

set winbuild=1
set "nul=>nul 2>&1"
set psc=powershell.exe
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G

set _NCS=1
if %winbuild% LSS 10586 set _NCS=0
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 2>nul | find /i "0x0" 1>nul && (set _NCS=0)

call :_colorprep

set "nceline=echo: &echo ==== ERROR ==== &echo:"
set "eline=echo: &call :_color %Red% "==== ERROR ====" &echo:"

::========================================================================================================================================

if %winbuild% LSS 7600 (
%nceline%
echo Unsupported OS version detected.
echo Supported only for Windows 7/8/8.1/10/11 and their Server equivalent.
goto MASend
)

for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" (
%nceline%
echo Unable to find powershell.exe in the system.
echo Aborting...
goto MASend
)

::========================================================================================================================================

::  Fix for the special characters limitation in path name

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

set _PSarg="""%~f0""" -el %_args%

set "_ttemp=%temp%"

setlocal EnableDelayedExpansion

::========================================================================================================================================

echo "!_batf!" | find /i "!_ttemp!" 1>nul && (
if /i not "!_work!"=="!_ttemp!" (
%nceline%
echo Script is launched from the temp folder,
echo Most likely you are running the script directly from the archive file.
echo:
echo Extract the archive file and launch the script from the extracted folder.
goto MASend
)
)

::========================================================================================================================================

::  Elevate script as admin and pass arguments and preventing loop

>nul fltmc || (
if not defined _elev %nul% %psc% "start cmd.exe -arg '/c \"!_PSarg:'=''!\"' -verb runas" && exit /b
%nceline%
echo This script require administrator privileges.
echo To do so, right click on this script and select 'Run as administrator'.
goto MASend
)

if not exist "%SystemRoot%\Temp\" mkdir "%SystemRoot%\Temp" 1>nul 2>nul

::========================================================================================================================================

::  Run script with parameters in unattended mode

set _elev=
if defined _args echo "%_args%" | find /i "/S" %nul% && (set "_silent=%nul%") || (set _silent=)
if defined _args echo "%_args%" | find /i "/" %nul% && (
echo "%_args%" | find /i "/HWID"   %nul% && (setlocal & (call :HWIDActivation   %_args% %_silent%) & cls & endlocal)
echo "%_args%" | find /i "/Insert" %nul% && (setlocal & (call :insert_hwidkey   %_args% %_silent%) & cls & endlocal)
exit /b
)

::========================================================================================================================================

setlocal DisableDelayedExpansion

::  Check desktop location

set _desktop_=
for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop') do call set "_desktop_=%%b"
if not defined _desktop_ for /f "delims=" %%a in ('%psc% "& {write-host $([Environment]::GetFolderPath('Desktop'))}"') do call set "_desktop_=%%a"

set "_pdesk=%_desktop_:'=''%"
setlocal EnableDelayedExpansion

::========================================================================================================================================

:MainMenu

cls
color 09
title  Windows Activation .gg/clusiive
mode 76, 30
set "mastemp=%SystemRoot%\Temp\__MAS"
if exist "%mastemp%\.*" rmdir /s /q "%mastemp%\" %nul%

echo:
echo:
echo:
echo:
echo:
echo:       ______________________________________________________________
echo:
echo:                 Activation Methods:
echo:
echo:             [1] HWID        ^|  Windows           ^|   Permanent
echo:             __________________________________________________      
echo:
echo:             [2] Activation Status
echo:             [3] Discord
echo:       ______________________________________________________________
echo:
choice /C:12345670 /N
set _erl=%errorlevel%

if %_erl%==3 start https://discord.gg/clusiive & goto :MainMenu
if %_erl%==2 setlocal & call :_Check_Status_wmi & cls & endlocal & goto :MainMenu
if %_erl%==1 setlocal & call :HWIDActivation    & cls & endlocal & goto :MainMenu
goto :MainMenu

:+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

:HWIDActivation
@setlocal DisableDelayedExpansion
@echo off

::  To activate, run the script with "/HWID" parameter or change 0 to 1 in below line
set _act=0

::  To disable changing edition if current edition doesn't support HWID activation, change the value to 1 from 0 or run the script with "/HWID-NoEditionChange" parameter
set _NoEditionChange=0

::  If value is changed in above lines or parameter is used then script will run in unattended mode



::========================================================================================================================================

cls
color 09
title  HWID Activation

set _args=
set _elev=
set _unattended=0

set _args=%*
if defined _args set _args=%_args:"=%
if defined _args (
for %%A in (%_args%) do (
if /i "%%A"=="/HWID"                  set _act=1
if /i "%%A"=="/HWID-NoEditionChange"  set _NoEditionChange=1
if /i "%%A"=="-el"                    set _elev=1
)
)

for %%A in (%_act% %_NoEditionChange%) do (if "%%A"=="1" set _unattended=1)

::========================================================================================================================================

set winbuild=1
set "nul=>nul 2>&1"
set psc=powershell.exe
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G

set _NCS=1
if %winbuild% LSS 10586 set _NCS=0
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 2>nul | find /i "0x0" 1>nul && (set _NCS=0)

if %_NCS% EQU 1 (
for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"
set     "Red="41;97m""
set    "Gray="100;97m""
set   "Green="42;97m""
set "Magenta="45;97m""
set  "_White="40;37m""
set  "_Green="40;92m""
set "_Yellow="40;93m""
) else (
set     "Red="Red" "white""
set    "Gray="Darkgray" "white""
set   "Green="DarkGreen" "white""
set "Magenta="Darkmagenta" "white""
set  "_White="Black" "Gray""
set  "_Green="Black" "Green""
set "_Yellow="Black" "Yellow""
)

set "nceline=echo: &echo ==== ERROR ==== &echo:"
set "eline=echo: &call :dk_color %Red% "==== ERROR ====" &echo:"
if %~z0 GEQ 200000 (set "_exitmsg=Go back") else (set "_exitmsg=Exit")

::========================================================================================================================================

if %winbuild% LSS 10240 (
%eline%
echo Unsupported OS version detected.
echo HWID Activation is supported only for Windows 10/11.
goto dk_done
)

if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-Server*Edition~*.mum" (
%eline%
echo HWID Activation is not supported for Windows Server.
goto dk_done
)

::========================================================================================================================================

::  Fix for the special characters limitation in path name

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

set _PSarg="""%~f0""" -el %_args%

set "_ttemp=%temp%"

setlocal EnableDelayedExpansion

::========================================================================================================================================

cls
mode 102, 34
title  HWID Activation

echo:
echo Initializing...
call :dk_product
call :dk_ckeckwmic

::  Show info for potential script stuck scenario

sc start sppsvc %nul%
if %errorlevel% NEQ 1056 if %errorlevel% NEQ 0 (
echo:
echo Error code: %errorlevel%
echo: Failed to start sppsvc service, rest of the process may take a long time...
echo:
)

::========================================================================================================================================

::  Check if system is permanently activated or not

call :dk_checkperm
if defined _perm (
cls
echo ___________________________________________________________________________________________
echo:
echo: Checking: %winos% is Permanently Activated.
echo: Activation is not required.
echo ___________________________________________________________________________________________
if %_unattended%==1 goto dk_done
echo:
choice /C:10 /N /M ">    [1] Activate [0] %_exitmsg% : "
if errorlevel 2 exit /b
)
cls

::========================================================================================================================================

::  Check Evaluation version

if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-*EvalEdition~*.mum" (
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2>nul | find /i "Eval" 1>nul && (
%eline%
echo [%winos% ^| %winbuild%]
echo:
echo Evaluation Editions cannot be activated. 
echo You need to install full version of %winos%
echo:
echo Download it from here,
echo https://massgrave.dev/genuine-installation-media.html
goto dk_done
)
)

::========================================================================================================================================

::  Check SKU value / Check in multiple places to find Edition change corruption

set osSKU=
set regSKU=
set wmiSKU=

for /f "tokens=3 delims=." %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\ProductOptions" /v OSProductPfn 2^>nul') do set "regSKU=%%a"
if %_wmic% EQU 1 for /f "tokens=2 delims==" %%a in ('"wmic Path Win32_OperatingSystem Get OperatingSystemSKU /format:LIST" 2^>nul') do if not errorlevel 1 set "wmiSKU=%%a"
if %_wmic% EQU 0 for /f "tokens=1" %%a in ('%psc% "([WMI]'Win32_OperatingSystem=@').OperatingSystemSKU" 2^>nul') do if not errorlevel 1 set "wmiSKU=%%a"

set osSKU=%wmiSKU%
if not defined osSKU set osSKU=%regSKU%

if not defined osSKU (
%eline%
echo SKU value was not detected properly. Aborting...
goto dk_done
)

::========================================================================================================================================

set error=

cls
echo:
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set arch=%%b
echo Checking OS Info                        [%winos% ^| %winbuild% ^| %arch%]

::  Check Internet connection

set _int=
for %%a in (l.root-servers.net resolver1.opendns.com download.windowsupdate.com google.com) do if not defined _int (
for /f "delims=[] tokens=2" %%# in ('ping -n 1 %%a') do (if not [%%#]==[] set _int=1)
)

if not defined _int (
%psc% "If([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet){Exit 0}Else{Exit 1}"
if !errorlevel!==0 set _int=1
)

if defined _int (
echo Checking Internet Connection            [Connected]
) else (
set error=1
call :dk_color %Red% "Checking Internet Connection            [Not Connected]"
)

::========================================================================================================================================

::  Check Windows Script Host

set _WSH=1
reg query "HKCU\SOFTWARE\Microsoft\Windows Script Host\Settings" /v Enabled 2>nul | find /i "0x0" 1>nul && (set _WSH=0)
reg query "HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings" /v Enabled 2>nul | find /i "0x0" 1>nul && (set _WSH=0)

if %_WSH% EQU 0 (
reg add "HKLM\Software\Microsoft\Windows Script Host\Settings" /v Enabled /t REG_DWORD /d 1 /f %nul%
reg add "HKCU\Software\Microsoft\Windows Script Host\Settings" /v Enabled /t REG_DWORD /d 1 /f %nul%
if not "%arch%"=="x86" reg add "HKLM\Software\Microsoft\Windows Script Host\Settings" /v Enabled /t REG_DWORD /d 1 /f /reg:32 %nul%
echo Enabling Windows Script Host            [Successful]
)

::========================================================================================================================================

echo Initiating Diagnostic Tests...

set "_serv=ClipSVC wlidsvc sppsvc KeyIso LicenseManager Winmgmt wuauserv"

::  Client License Service (ClipSVC)
::  Microsoft Account Sign-in Assistant
::  Software Protection
::  CNG Key Isolation
::  Windows License Manager Service
::  Windows Management Instrumentation
::  Windows Update

call :dk_errorcheck

::  Check Windows updates and store app blockers

set updatesblock=
echo: %serv_ste% | findstr /i "wuauserv" %nul% && set updatesblock=1
for /f "skip=2 tokens=2*" %%a in ('reg query HKLM\SYSTEM\CurrentControlSet\Services\UsoSvc /v Start 2^>nul') do if /i %%b equ 0x4 set updatesblock=1
if exist "%SystemRoot%\System32\WaaSMedicSvc.dll" (
for /f "skip=2 tokens=2*" %%a in ('reg query HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc /v Start 2^>nul') do if /i %%b equ 0x4 set updatesblock=1
)

reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer /v SettingsPageVisibility 2>nul | find /i "windowsupdate" %nul% && set updatesblock=1
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdateSysprepInProgress %nul% && set updatesblock=1
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /s 2>nul | findstr /i "NoAutoUpdate DisableWindowsUpdateAccess" %nul% && set updatesblock=1

if defined updatesblock (
call :dk_color %Gray% "Checking Windows Update Blockers        [Found]"
if defined applist echo: %serv_e% | find /i "wuauserv" %nul% && (
call :dk_color %Magenta% "Windows Update Service [wuauserv] is not working. Enable it incase if you have disabled it."
)
)

reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v DisableStoreApps 2>nul | find /i "0x1" %nul% && (
call :dk_color %Gray% "Checking Store App Blocker              [Found]"
)

::========================================================================================================================================

::  Detect Key

set key=
set altkey=
set changekey=
set curedition=
set altedition=
set notworking=
set actidnotfound=

for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v BuildBranch 2^>nul') do set "branch=%%b"

if defined applist call :hwiddata key attempt1
if not defined key call :hwiddata key attempt2

if defined notworking call :hwidfallback
if not defined key call :hwidfallback

if defined altkey (set key=%altkey%&set changekey=1&set notworking=)

if defined notworking if defined notfoundaltactID (
call :dk_color %Red% "Checking Alternate Edition For HWID     [%altedition% Activation ID Not Found]"
if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-*EvalEdition~*.mum" (
call :dk_color %Magenta% "Evaluation Windows Found. Install Full version of %winos%"
call :dk_color %Magenta% "Download it from https://massgrave.dev/genuine-installation-media.html"
)
)

if not defined key (
%eline%
echo [%winos% ^| %winbuild% ^| SKU:%osSKU%]
echo Unable to find this product in the supported product list.
echo Make sure you are using updated version of the script.
echo xxx
echo:
goto dk_done
)

if defined notworking set error=1

::========================================================================================================================================

::  Install key

echo:
if defined changekey (
call :dk_color %Magenta% "[%altedition%] Edition product key will be used to enable HWID activation."
echo:
)

if %_wmic% EQU 1 wmic path SoftwareLicensingService where __CLASS='SoftwareLicensingService' call InstallProductKey ProductKey="%key%" %nul%
if %_wmic% EQU 0 %psc% "(([WMISEARCHER]'SELECT Version FROM SoftwareLicensingService').Get()).InstallProductKey('%key%')" %nul%
if not %errorlevel%==0 cscript //nologo %windir%\system32\slmgr.vbs /ipk %key% %nul%
set errorcode=%errorlevel%
cmd /c exit /b %errorcode%
if %errorcode% NEQ 0 set "errorcode=[0x%=ExitCode%]"

if %errorcode% EQU 0 (
call :dk_refresh
echo Installing Generic Product Key          [%key%] [Successful]
) else (
call :dk_color %Red% "Installing Generic Product Key          [%key%] [Failed] %errorcode%"
if not defined error (
call :dk_color %Magenta% "In MAS, Goto Troubleshoot and run Fix Licensing option."
if defined actidnotfound call :dk_color %Red% "Activation ID not found for this key. Make sure you are using updated version of MAS."
set showfix=1
)
set error=1
)

::========================================================================================================================================

::  Change Windows region to USA to avoid activation issues as Windows store license is not available in many countries 

for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Control Panel\International\Geo" /v Name 2^>nul') do set "name=%%b"
for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Control Panel\International\Geo" /v Nation 2^>nul') do set "nation=%%b"

set regionchange=
if not "%name%"=="US" (
set regionchange=1
%psc% "Set-WinHomeLocation -GeoId 244" %nul%
if !errorlevel! EQU 0 (
echo Changing Windows Region To USA          [Successful]
) else (
call :dk_color %Red% "Changing Windows Region To USA          [Failed]"
)
)

::==========================================================================================================================================

::  Generate GenuineTicket.xml and apply
::  In some cases clipup -v -o method fails and in some cases service restart method fails as well
::  To maximize success rate and get better error details, script will install tickets two times (service restart + clipup -v -o)

set "tdir=%ProgramData%\Microsoft\Windows\ClipSVC\GenuineTicket"
if not exist "%tdir%\" md "%tdir%\" %nul%

if exist "%tdir%\Genuine*" del /f /q "%tdir%\Genuine*" %nul%
if exist "%tdir%\*.xml" del /f /q "%tdir%\*.xml" %nul%
if exist "%ProgramData%\Microsoft\Windows\ClipSVC\Install\Migration\*" del /f /q "%ProgramData%\Microsoft\Windows\ClipSVC\Install\Migration\*" %nul%

call :hwiddata ticket

copy /y /b "%tdir%\GenuineTicket" "%tdir%\GenuineTicket.xml" %nul%

if not exist "%tdir%\GenuineTicket.xml" (
call :dk_color %Red% "Generating GenuineTicket.xml            [Failed]"
echo [%encoded%]
if exist "%tdir%\Genuine*" del /f /q "%tdir%\Genuine*" %nul%
goto :dl_final
) else (
echo Generating GenuineTicket.xml            [Successful]
)

set "_xmlexist=if exist "%tdir%\GenuineTicket.xml""

%_xmlexist% (
net stop ClipSVC /y %nul%
net start ClipSVC /y %nul%
%_xmlexist% timeout /t 2 %nul%
%_xmlexist% timeout /t 2 %nul%

%_xmlexist% (
set error=1
if exist "%tdir%\*.xml" del /f /q "%tdir%\*.xml" %nul%
call :dk_color %Red% "Installing GenuineTicket.xml            [Failed With ClipSVC Service Restart, Wait...]"
)
)

copy /y /b "%tdir%\GenuineTicket" "%tdir%\GenuineTicket.xml" %nul%
clipup -v -o

set rebuildinfo=

%_xmlexist% (
set error=1
set rebuildinfo=1
call :dk_color %Red% "Installing GenuineTicket.xml            [Failed With clipup -v -o]"
)

if exist "%ProgramData%\Microsoft\Windows\ClipSVC\Install\Migration\*.xml" (
set error=1
set rebuildinfo=1
call :dk_color %Red% "Checking Ticket Migration               [Failed]"
)

if defined applist if not defined showfix if defined rebuildinfo (
set showfix=1
call :dk_color %Magenta% "In MAS, Goto Troubleshoot and run Fix Licensing option."
)

if exist "%tdir%\Genuine*" del /f /q "%tdir%\Genuine*" %nul%

::==========================================================================================================================================

call :dk_product

echo:
echo Activating...

call :dk_act
call :dk_checkperm
if defined _perm (
echo:
call :dk_color %Green% "%winos% is permanently activated with a digital license."
goto :dl_final
)

::  Extended licensing servers tests incase error not found and activation failed

set resfail=
if not defined error (

ipconfig /flushdns %nul%
set "tls=$Tls12 = [Enum]::ToObject([System.Net.SecurityProtocolType], 3072); [System.Net.ServicePointManager]::SecurityProtocol = $Tls12;"

for %%# in (
login.live.com/ppsecure/deviceaddcredential.srf
purchase.mp.microsoft.com/v7.0/users/me/orders
) do if not defined resfail (
set "d1=Add-Type -AssemblyName System.Net.Http;"
set "d1=!d1! $client = [System.Net.Http.HttpClient]::new();"
set "d1=!d1! $response = $client.GetAsync('https://%%#').GetAwaiter().GetResult();"
set "d1=!d1! $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()"
%psc% "!tls! !d1!" 2>nul | findstr /i "PurchaseFD DeviceAddResponse" 1>nul || set resfail=1
)

if not defined resfail (
%psc% "!tls! irm https://licensing.mp.microsoft.com/v7.0/licenses/content -Method POST" | find /i "traceId" 1>nul || set resfail=1
)

if defined resfail (
set error=1
echo:
call :dk_color %Red% "Checking Licensing Servers              [Failed To Connect]"
call :dk_color2 %Magenta% "Check this page for help" %_Yellow% " https://massgrave.dev/licensing-servers-issue"
)
)

::  Clear store ID related registry to fix activation incase error not found

if not defined error (
echo:
set "_ident=HKU\S-1-5-19\SOFTWARE\Microsoft\IdentityCRL"
reg delete "!_ident!" /f %nul%
reg query "!_ident!" %nul% && (
call :dk_color %Red% "Deleting a Registry                     [Failed] [!_ident!]"
) || (
echo Deleting a Registry                     [Successful] [!_ident!]
)

REM Refresh some services and license status

for %%# in (wlidsvc LicenseManager sppsvc) do (net stop %%# /y %nul% & net start %%# /y %nul%)
call :dk_refresh
call :dk_act
call :dk_checkperm
)

echo:
if defined _perm (
call :dk_color %Green% "%winos% is permanently activated with a digital license."
) else (
call :dk_color %Red% "Activation Failed %error_code%"
if defined notworking (
call :dk_color %Magenta% "At the time of writing this, HWID Activation was not supported for this product."
) else (
if not defined error call :dk_color %Magenta% "In MAS, Goto Troubleshoot and run Fix Licensing option."
call :dk_color2 %Magenta% "Check this page for help" %_Yellow% " https://massgrave.dev/troubleshoot"
)
)

::========================================================================================================================================

:dl_final

echo:

if defined regionchange (
%psc% "Set-WinHomeLocation -GeoId %nation%" %nul%
if !errorlevel! EQU 0 (
echo Restoring Windows Region                [Successful]
) else (
call :dk_color %Red% "Restoring Windows Region                [Failed] [%name% - %nation%]"
)
)

if %osSKU%==175 call :dk_color %Red% "%winos% does not support activation on non-azure platforms."

goto :dk_done

::========================================================================================================================================

::  Get Windows permanent activation status

:dk_checkperm

if %_wmic% EQU 1 wmic path SoftwareLicensingProduct where (LicenseStatus='1' and GracePeriodRemaining='0' and PartialProductKey is not NULL) get Name /value 2>nul | findstr /i "Windows" 1>nul && set _perm=1||set _perm=
if %_wmic% EQU 0 %psc% "(([WMISEARCHER]'SELECT Name FROM SoftwareLicensingProduct WHERE LicenseStatus=1 AND GracePeriodRemaining=0 AND PartialProductKey IS NOT NULL').Get()).Name | %% {echo ('Name='+$_)}" 2>nul | findstr /i "Windows" 1>nul && set _perm=1||set _perm=
exit /b

::  Refresh license status

:dk_refresh

if %_wmic% EQU 1 wmic path SoftwareLicensingService where __CLASS='SoftwareLicensingService' call RefreshLicenseStatus %nul%
if %_wmic% EQU 0 %psc% "$null=(([WMICLASS]'SoftwareLicensingService').GetInstances()).RefreshLicenseStatus()" %nul%
exit /b

::  Activation command

:dk_act

set error_code=
if %_wmic% EQU 1 wmic path SoftwareLicensingProduct where "ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f' and PartialProductKey<>null" call Activate %nul%
if %_wmic% EQU 0 %psc% "(([WMISEARCHER]'SELECT ID FROM SoftwareLicensingProduct WHERE ApplicationID=''55c92734-d682-4d71-983e-d6ec3f16059f'' AND PartialProductKey IS NOT NULL').Get()).Activate()" %nul%
if not %errorlevel%==0 cscript //nologo %windir%\system32\slmgr.vbs /ato %nul%
set error_code=%errorlevel%
cmd /c exit /b %error_code%
if %error_code% NEQ 0 (set "error_code=[Error Code: 0x%=ExitCode%]") else (set error_code=)
exit /b

::  Get Windows Activation IDs

:dk_actids

set applist=
if %_wmic% EQU 1 set "chkapp=for /f "tokens=2 delims==" %%a in ('"wmic path SoftwareLicensingProduct where (ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f') get ID /VALUE" 2^>nul')"
if %_wmic% EQU 0 set "chkapp=for /f "tokens=2 delims==" %%a in ('%psc% "(([WMISEARCHER]'SELECT ID FROM SoftwareLicensingProduct WHERE ApplicationID=''55c92734-d682-4d71-983e-d6ec3f16059f''').Get()).ID ^| %% {echo ('ID='+$_)}" 2^>nul')"
%chkapp% do (if defined applist (call set "applist=!applist! %%a") else (call set "applist=%%a"))
exit /b

::  Check wmic.exe

:dk_ckeckwmic

set _wmic=0
for %%# in (wmic.exe) do @if not "%%~$PATH:#"=="" (
wmic path Win32_ComputerSystem get CreationClassName /value 2>nul | find /i "computersystem" 1>nul && set _wmic=1
)
exit /b

::  Get Product name (WMI/REG methods are not reliable in all conditions, hence winbrand.dll method is used)

:dk_product

call :dk_reflection

set d1=%ref% $meth = $TypeBuilder.DefinePInvokeMethod('BrandingFormatString', 'winbrand.dll', 'Public, Static', 1, [String], @([String]), 1, 3);
set d1=%d1% $meth.SetImplementationFlags(128); $TypeBuilder.CreateType()::BrandingFormatString('%%WINDOWS_LONG%%')

set winos=
for /f "delims=" %%s in ('"%psc% %d1%"') do if not errorlevel 1 (set winos=%%s)
echo "%winos%" | find /i "Windows" 1>nul || (
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "winos=%%b"
if %winbuild% GEQ 22000 (
set winos=!winos:Windows 10=Windows 11!
)
)
exit /b

::  Common lines used in PowerShell reflection code

:dk_reflection

set ref=$AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly(4, 1);
set ref=%ref% $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule(2, $False);
set ref=%ref% $TypeBuilder = $ModuleBuilder.DefineType(0);
exit /b

::========================================================================================================================================

:dk_errorcheck

::  Check disabled services

set serv_ste=
for %%# in (%_serv%) do (
set serv_dis=
reg query HKLM\SYSTEM\CurrentControlSet\Services\%%# /v ImagePath %nul% || set serv_dis=1
for /f "skip=2 tokens=2*" %%a in ('reg query HKLM\SYSTEM\CurrentControlSet\Services\%%# /v Start 2^>nul') do if /i %%b equ 0x4 set serv_dis=1
sc start %%# %nul%
if !errorlevel! EQU 1058 set serv_dis=1
sc query %%# %nul% || set serv_dis=1
if defined serv_dis (if defined serv_ste (set "serv_ste=!serv_ste! %%#") else (set "serv_ste=%%#"))
)

::  Change disabled services startup type to default

set serv_csts=
set serv_cste=

if defined serv_ste (
for %%# in (%serv_ste%) do (
if /i %%#==ClipSVC        (reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%#" /v "Start" /t REG_DWORD /d "3" /f %nul% & sc config %%# start= demand %nul%)
if /i %%#==wlidsvc        sc config %%# start= demand %nul%
if /i %%#==sppsvc         (reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%#" /v "Start" /t REG_DWORD /d "2" /f %nul% & sc config %%# start= delayed-auto %nul%)
if /i %%#==KeyIso         sc config %%# start= demand %nul%
if /i %%#==LicenseManager sc config %%# start= demand %nul%
if /i %%#==Winmgmt        sc config %%# start= auto %nul%
if /i %%#==wuauserv       sc config %%# start= demand %nul%
if !errorlevel!==0 (
if defined serv_csts (set "serv_csts=!serv_csts! %%#") else (set "serv_csts=%%#")
) else (
if defined serv_cste (set "serv_cste=!serv_cste! %%#") else (set "serv_cste=%%#")
)
)
)

if defined serv_csts call :dk_color %Gray% "Enabling Disabled Services              [Successful] [%serv_csts%]"

if defined serv_cste (
set error=1
call :dk_color %Red% "Enabling Disabled Services              [Failed] [%serv_cste%]"
)

::========================================================================================================================================

::  Check if the services are able to run or not
::  Workarounds are added to get correct status and error code because sc query doesn't output correct results in some conditions

set serv_e=
for %%# in (%_serv%) do (
set errorcode=
set checkerror=
net start %%# /y %nul%
set errorcode=!errorlevel!
sc query %%# | find /i "4  RUNNING" %nul% || set checkerror=1

sc start %%# %nul%
if !errorlevel! NEQ 1056 if !errorlevel! NEQ 0 (set errorcode=!errorlevel!&set checkerror=1)
if defined checkerror if defined serv_e (set "serv_e=!serv_e!, %%#-!errorcode!") else (set "serv_e=%%#-!errorcode!")
)

if defined serv_e (
set error=1
call :dk_color %Red% "Starting Services                       [Failed] [%serv_e%]"
echo %serv_e% | findstr /i "ClipSVC-1058 sppsvc-1058" %nul% && (
call :dk_color %Magenta% "Restart the system to fix disabled service error 1058."
)
)

::========================================================================================================================================

::  Various error checks

if defined safeboot_option (
set error=1
call :dk_color2 %Red% "Checking Boot Mode                      " %Magenta% "[System is running in safe mode. Run in normal mode.]"
)


reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State" 2>nul | find /i "IMAGE_STATE_COMPLETE" 1>nul || (
set error=1
call :dk_color2 %Red% "Checking Audit Mode                     " %Magenta% "[System is running in Audit mode. Run in normal mode.]"
)


reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE" /v InstRoot %nul% && (
set error=1
call :dk_color2 %Red% "Checking WinPE                          " %Magenta% "[System is running in WinPE mode. Run in normal mode.]"
)


for %%# in (wmic.exe) do @if "%%~$PATH:#"=="" (
call :dk_color %Gray% "Checking WMIC.exe                       [Not Found]"
)


%psc% $ExecutionContext.SessionState.LanguageMode 2>nul | find /i "Full" 1>nul || (
set error=1
call :dk_color %Red% "Checking Powershell                     [Not Responding]"
)


set wmifailed=
if %_wmic% EQU 1 wmic path Win32_ComputerSystem get CreationClassName /value 2>nul | find /i "computersystem" 1>nul
if %_wmic% EQU 0 %psc% "Get-CIMInstance -Class Win32_ComputerSystem | Select-Object -Property CreationClassName" 2>nul | find /i "computersystem" 1>nul
if %errorlevel% NEQ 0 (
set error=1
set wmifailed=1
call :dk_color %Red% "Checking WMI                            [Not Responding] %_wmic%"
call :dk_color %Magenta% "In MAS, Goto Troubleshoot and run Fix WMI option."
)


if not "%regSKU%"=="%wmiSKU%" (
call :dk_color %Red% "Checking WMI/REG SKU                    [Difference Found - WMI:%wmiSKU% Reg:%regSKU%]"
)


DISM /English /Online /Get-CurrentEdition %nul%
set error_code=%errorlevel%
cmd /c exit /b %error_code%
if %error_code% NEQ 0 set "error_code=[0x%=ExitCode%]"
if %error_code% NEQ 0 (
call :dk_color %Red% "Checking DISM                           [Not Responding] %error_code%"
)


if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-*EvalEdition~*.mum" (
set error=1
call :dk_color %Red% "Checking Eval Packages                  [Non-Eval Licenses are installed in Eval Windows]"
)


cscript //nologo %windir%\system32\slmgr.vbs /dlv %nul%
set error_code=%errorlevel%
cmd /c exit /b %error_code%
if %error_code% NEQ 0 set "error_code=0x%=ExitCode%"
if %error_code% NEQ 0 (
set error=1
call :dk_color %Red% "Checking slmgr /dlv                     [Not Responding] %error_code%"
)


reg query "HKU\S-1-5-20\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\PersistedTSReArmed" %nul% && (
set error=1
call :dk_color2 %Red% "Checking Rearm                          " %Magenta% "[System Restart Is Required]"
)


reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ClipSVC\Volatile\PersistedSystemState" %nul% && (
set error=1
call :dk_color2 %Red% "Checking ClipSVC                        " %Magenta% "[System Restart Is Required]"
)


for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v "SkipRearm" 2^>nul') do if /i %%b NEQ 0x0 (
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v "SkipRearm" /t REG_DWORD /d "0" /f %nul%
call :dk_color %Red% "Checking SkipRearm                      [Default 0 Value Not Found, Changing To 0]"
net stop sppsvc /y %nul%
net start sppsvc /y %nul%
set error=1
)


reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\Plugins\Objects\msft:rm/algorithm/hwid/4.0" /f ba02fed39662 /d %nul% || (
call :dk_color %Red% "Checking SPP Registry Key               [Incorrect ModuleId Found]"
set error=1
)


call :dk_actids
if not defined applist (
net stop sppsvc /y %nul%
cscript //nologo %windir%\system32\slmgr.vbs /rilc %nul%
if !errorlevel! NEQ 0 cscript //nologo %windir%\system32\slmgr.vbs /rilc %nul%
call :dk_refresh
call :dk_actids
if not defined applist (
set error=1
call :dk_color %Red% "Checking Activation IDs                 [Not Found]"
)
)


set tokenstore=
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v TokenStore 2^>nul') do call set "tokenstore=%%b"
if not exist "%tokenstore%\" (
set error=1
call :dk_color %Red% "Checking SPP Token Folder               [Not Found] [%tokenstore%\]"
)


if exist "%tokenstore%\" if not exist "%tokenstore%\tokens.dat" (
set error=1
call :dk_color %Red% "Checking SPP tokens.dat                 [Not Found] [%tokenstore%\]"
)


if not exist %ProgramData%\Microsoft\Windows\ClipSVC\tokens.dat (
set error=1
call :dk_color %Red% "Checking ClipSVC tokens.dat             [Not Found]"
)


if not exist %SystemRoot%\system32\sppsvc.exe (
set error=1
call :dk_color %Red% "Checking sppsvc.exe File                [Not Found]"
)


::  Below checks are performed if required services are not disabled + slmgr /dlv errorlevel is not Zero + Rearm restart is not required + WMI is working fine

set showfix=
set wpaerror=
set permerror=
if not defined serv_cste if /i not %error_code%==0 if /i not %error_code%==0xC004D302 if not defined wmifailed (

REM  This code checks for invalid registry keys in HKLM\SYSTEM\WPA. This issue may appear even on healthy systems.

if %winbuild% GEQ 14393 (
set /a count=0
for /f %%a in ('reg query "HKLM\SYSTEM\WPA" 2^>nul') do set /a count+=1
for /L %%# in (1,1,!count!) do (
reg query "HKLM\SYSTEM\WPA\8DEC0AF1-0341-4b93-85CD-72606C2DF94C-7P-%%#" /ve /t REG_BINARY %nul% || set wpaerror=1
)
if defined wpaerror call :dk_color %Red% "Checking WPA Registry Keys              [Error Found] [Registry Count - !count!]"
)

REM  This code checks if NT SERVICE\sppsvc has permission access to tokens folder and required registry keys. It's often caused by gaming spoofers. 

if not exist "%tokenstore%\" set permerror=1

for %%# in (
"%tokenstore%"
"HKLM:\SYSTEM\WPA"
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
) do if not defined permerror (
%psc% "$acl = Get-Acl '%%#'; if ($acl.Access.Where{ $_.IdentityReference -eq 'NT SERVICE\sppsvc' -and $_.AccessControlType -eq 'Deny' -or $acl.Access.IdentityReference -notcontains 'NT SERVICE\sppsvc'}) {Exit 2}" %nul%
if !errorlevel!==2 set permerror=1
)
if defined permerror call :dk_color %Red% "Checking SPP Permissions                [Error Found]"

set showfix=1
call :dk_color %Magenta% "In MAS, Goto Troubleshoot and run Fix Licensing option."
if not defined permerror call :dk_color %Magenta% "If activation still fails then run Fix WPA Registry option."
)

exit /b

::========================================================================================================================================

:dk_color

if %_NCS% EQU 1 (
echo %esc%[%~1%~2%esc%[0m
) else (
%psc% write-host -back '%1' -fore '%2' '%3'
)
exit /b

:dk_color2

if %_NCS% EQU 1 (
echo %esc%[%~1%~2%esc%[%~3%~4%esc%[0m
) else (
%psc% write-host -back '%1' -fore '%2' '%3' -NoNewline; write-host -back '%4' -fore '%5' '%6'
)
exit /b

::========================================================================================================================================

:dk_done

echo:
if %_unattended%==1 timeout /t 2 & exit /b
call :dk_color %_Yellow% "Press any key to %_exitmsg%..."
pause >nul
exit /b

::========================================================================================================================================

::  1st column = Activation ID
::  2nd column = Generic Retail/OEM/MAK Key
::  3rd column = SKU ID
::  4th column = Key part number
::  5th column = Ticket signature value. It's as it is, it's not encoded. (Check https://massgrave.dev/hwid.html#Manual_Activation to see how it's generated)
::  6th column = 1 = activation is not working (at the time of writing this), 0 = activation is working
::  7th column = Key Type
::  8th column = WMI Edition ID
::  9th column = Version name incase same Edition ID is used in different OS versions with different key
::  Separator  = _


:hwiddata

set f=
for %%# in (
8b351c9c-f398-4515-9900-09df49427262_XGV%f%PP-NM%f%H47-7TT%f%HJ-W3%f%FW7-8H%f%V2C___4_X19-99683_X9J5T0gPQprYpz2euPvoJGlkurIO9h6N8ypE0KWYVpy0nbCKYnqSUCD7u8ReXAmc085jX2uM5PKurSee9Yq/PxesgiysQHDBsOhr98MXZZiIgy4ssnz2gZF70KB8tO3X7kk9LHwxXfz3rlquYPod9swe90nqvVaJMWCpQK0InUw_0_OEM:NONSLP_Enterprise
c83cef07-6b72-4bbc-a28f-a00386872839_3V6%f%Q6-NQ%f%XCX-V8Y%f%XR-9Q%f%CYV-QP%f%FCT__27_X19-98746_WFZBjlVtHQumoaVE28/NHsRvv1lgkkfav6NPHqr6OC2u4vxkjjJkkl9OTF6DpHJu0IFrrQv+HYcdZ/WC5EzhOMqMxcujTBSAN7xLIVEbs72Db0Bi5iDAbOltJpk8QKKe18otQJ6vajW5WOPXjbgSJfDFaZQfiwvIJ1ICXt+stog_0_Volume:MAK_EnterpriseN
4de7cb65-cdf1-4de9-8ae8-e3cce27b9f2c_VK7%f%JG-NP%f%HTM-C97%f%JM-9M%f%PGT-3V%f%66T__48_X19-98841_K3qev/5gQpX1RK1F9M9beEWWv/di1GsRF7OUcEMGTGDTYnaRenRcJaO8zOHQQvKDc57fon/v77ZpHQHT/jWWhWnLm7Ssory+s8tOs72fPjivVBDwpSPIEC1v+8Vpb4a3XCZet2e/Z5wmpCq9XDkowys3IcxYM0mHWBaNPu8gIe4_0_____Retail_Professional
9fbaf5d6-4d83-4422-870d-fdda6e5858aa_2B8%f%7N-8K%f%FHP-DKV%f%6R-Y2%f%C8J-PK%f%CKT__49_X19-98859_WcAcor6kQgxgkTRzcoxnb8UIoo5/ueYeaOKqy9/xAzlruHAKxhatXeGtSI58lXcCK5hxXkDmcyrRFwWSwdvg0txwTi7VusYcTNCLdmNWU/62iDrBhzMrCYtuhW9EV/g4+TlbjSm4PBJ0HMlI4YzAEnyJiBgKPDgBQ8Gj9LRbEgU_0_____Retail_ProfessionalN
f742e4ff-909d-4fe9-aacb-3231d24a0c58_4CP%f%RK-NM%f%3K3-X6X%f%XQ-RX%f%X86-WX%f%CHW__98_X19-98877_MBDSEqlayxtVVEgIeAl8milgjS/BVHow6+MmpCyh9nweuctlT1+LbEHmDlnqDeLr9FQrN2FpEJtNr26rE0niMdvcAP51MfJsREyhWOEbrWwWyMH0KwDAci2WxWZTJp/SEZnq5HYYT1pPPLMWAkKRHJksJJFtg4zBtoyHvLjc35c_0_____Retail_CoreN
1d1bac85-7365-4fea-949a-96978ec91ae0_N24%f%34-X9%f%D7W-8PF%f%6X-8D%f%V9T-8T%f%YMD__99_X19-99652_mpjCoh6soA/rwJutsjekZpA9vDUD8znR20V/c8FwSjuCcSbPhmP6bpJR9rfptAZqpagliMxA/OUZsx0Knt0n/hgOy2mv8pr24gI9uYXK8EfhG74bVdsyvZz1tyA6CaVR02ZahQvbKYzCmXUvsI+Wge3bHbKbVpn9Mvl+itn2a4g_0_____Retail_CoreCountrySpecific
3ae2cc14-ab2d-41f4-972f-5e20142771dc_BT7%f%9Q-G7%f%N6G-PGB%f%YW-4Y%f%WX6-6F%f%4BT_100_X19-99661_KaUs6KwvtthPOsxd3x0tU/baKSv1DWSFOqbq7PbU/uYEY95p0Skzv3y4aXq+xVmfwSt8STL/4vSfFIAlsaRh7Vnq6Y/Ael8joeqI8hBN461fykoHxSELRMJ+eed50T0cJUS79ol6OTBOCCVeHgmtGVbHuL88TMWW69fGNdIMM3U_0_____Retail_CoreSingleLanguage
2b1f36bb-c1cd-4306-bf5c-a0367c2d97d8_YTM%f%G3-N6%f%DKC-DKB%f%77-7M%f%9GH-8H%f%VX7_101_X19-98868_NpHxrAtA+GL6kawAP5Z2UdfUVcKFvf9UzEe6FIV/HztZqxpMBDFv2hdxCjD9+T8PKcW8j3n04McelOAgr3lD37Fu+wrvJIGX0dG3xEtU/MG9L9X5baBS8H6AmC6rq2+w5NUY8EchK9W2oatBflFb8IcfCSeAyOfsJei6bdu4mp8_0_____Retail_Core
2a6137f3-75c0-4f26-8e3e-d83d802865a4_XKC%f%NC-J2%f%6Q9-KFH%f%D2-FK%f%THY-KD%f%72Y_119_X19-99606_gtywgqIP3j+bliKdunuseeZWtsOzWhj+DmSBq7nqeNarHutgbWEwvcRiGo+nwxONt9Ak/VyuO76ZWH/db3iRVTk1y61vFv15gVlOy1ovLjVHBvmPVdQXIne2N+pIMb0eBhZWHRX63mYdkZRZ0wg/+bj4xsjJv+qLpWhVCzNMge4_0_OEM:NONSLP_PPIPro
e558417a-5123-4f6f-91e7-385c1c7ca9d4_YNM%f%GQ-8R%f%YV3-4PG%f%Q3-C8%f%XTP-7C%f%FBY_121_X19-98886_VuBmoSUdF63Cvwm9wNlc2yhD2tP9B72iVVWFNcbAwDGXF6o06oNMsIJ0VqGJDdBzZjVGw2wHokMabxZNDyIl90CO7trwgV8S0lLJVLymxyUaE3ThvN3YUsi9Q3H+5Kr0RpsojCWb+UQd/GY4bSXfyStXFylj6im7yv0db/ZWGbw_0_____Retail_Education
c5198a66-e435-4432-89cf-ec777c9d0352_84N%f%GF-MH%f%BT6-FXB%f%X8-QW%f%JK7-DR%f%R8H_122_X19-98892_jQ6S2bbNoVrp/zvi8BEUwCf7fge1nAdspcjXyTeTySUiR+hXPiKQEWgyLqAdZ5Or+X2JGT/LZN1/eZ9P+REmzG/WQotZ+fyyPguoSsES+d312RkfmQoI5gVanEkGjZSU4YohREM/Vyf9MOO7dbH9MMEpFm2mje6OnhyJo2gux0g_0_____Retail_EducationN
cce9d2de-98ee-4ce2-8113-222620c64a27_KCN%f%VH-YK%f%WX8-GJJ%f%B9-H9%f%FDT-6F%f%7W2_125_X22-66075_wJ/BPDFz+13PVJtBqBo+E4LCm3LoMVALCQUun9kXGBULr7V8FQ5nKUudUGHDLNNVIIicdw9Uh26BKAt0/hnE7BpBkzwdi4qAdZgKXQ1t06Ek4+zXmoT225NvpaHsuhDkE687TtCB1ZWvAulA8G9ehE3HTJSoNm4wCFOQyIQQtqQ_1_Volume:MAK_EnterpriseS_VB
d06934ee-5448-4fd1-964a-cd077618aa06_43T%f%BQ-NH%f%92J-XKT%f%M7-KT%f%3KK-P3%f%9PB_125_X21-83233_V+y0SFmAnGwRwgNz+0sO0mj+XxSjbdRDpom1Iqx2BJcsf96Q5ittJOcMhKiNswyKuq5suM5vy60tA/AUdb1mrnnrnXfmz7nFam/BIOOfa18GA7vd1aNFufhpmCiMWxoGSewH/T1pnCZrsvGYIj//qC7aiQVKYBngO7UYWGaytgc_0_OEM:NONSLP_EnterpriseS_RS5
706e0cfd-23f4-43bb-a9af-1a492b9f1302_NK9%f%6Y-D9%f%CD8-W44%f%CQ-R8%f%YTK-DY%f%JWX_125_X21-05035_U2DIv+LAhSGz0rNbTiMQYaP3M41+0+ZioF7vh0COeeJSIruDFCZ3Li7ZM3dSleg6QTCxG04uZ3i3r1bCZv0+WAfU9rG+3BqLAwKlJS/31rETeRWvrxB1UK4mTMHwAJc9txDAc15ureqF+2b9pIIpwLljmFer6fI7z0iI6I/ZuTU_0_OEM:NONSLP_EnterpriseS_RS1
faa57748-75c8-40a2-b851-71ce92aa8b45_FWN%f%7H-PF%f%93Q-4GG%f%P8-M8%f%RF3-MD%f%WWW_125_X19-99617_0frpwr4N/wBVRA/nOvAMqkxmRj6Vv9mA+jVNtnurAL1TjkPN/y+6YVUd5MP/Y4As4kddHoHiZXI+2siKHJsaV95ppXoHKR8d7FRVitr1F+82TbB7OVvdCclGrRZymnq25HvtSC3BROHt7ZXTgSCWMyB7MlbLiqHiTymOj5OMX1g_0_OEM:NONSLP_EnterpriseS_TH
2c060131-0e43-4e01-adc1-cf5ad1100da8_RQF%f%NW-9T%f%PM3-JQ7%f%3T-QV%f%4VQ-DV%f%9PT_126_X22-66108_UeA6O2iIW6zFMJzLMCQjVA7gUHOGRTiFB6LPrgjhgfJEXSZnDjxw8wsR+tp+JQWeaQDsVt06c2byH3z7Ft2wNk8n3gcXUknIjlcCckNjw05WDI64/wCqz+gtf1RajMEoV/mODpBx7rdLtCg03FyV7Z9LOib4/WLSmnxjDPKMG7s_1_Volume:MAK_EnterpriseSN_VB
e8f74caa-03fb-4839-8bcc-2e442b317e53_M33%f%WV-NH%f%Y3C-R7F%f%PM-BQ%f%GPT-23%f%9PG_126_X21-83264_NtP6sMWmOTCdABAbgIZfxZzRs8zaqzfaabLeFXQJvfJvQPLQPk2UxMliASJG+7YwwbTD8pyhUoQqUYrlCzJZ6jDSDyUTJkXgo9akR4fBOg6Z5wn5fW8NGAMDcLND5d9XxHl0gWH/HZNIs/GZaPJsCVVqPr7X8bk/y0DeIofxICU_1_Volume:MAK_EnterpriseSN_RS5
3d1022d8-969f-4222-b54b-327f5a5af4c9_2DB%f%W3-N2%f%PJG-MVH%f%W3-G7%f%TDK-9H%f%KR4_126_X21-04921_WeNSkuiC3iyNT9tDqlj6KvM17UYMsYjEelyyMEyPEXSAbYA08lYtYJjCzxSE9T30p9dxqPIuj370OwHhAxG8a51/HoLNWR0grj08HmdOXUA8Ap4clEivxKM0zRvwPR6L2M2HQP0nN54c9It7ikzweJ0X2HHOb58oEw9LbMeUM/Y_0_Volume:MAK_EnterpriseSN_RS1
60c243e1-f90b-4a1b-ba89-387294948fb6_NTX%f%6B-BR%f%YC2-K67%f%86-F6%f%MVQ-M7%f%V2X_126_X19-98770_QLG40WW/TtUqtir9K6FJCQXU1mfn27uutdOunHJ3gXk6v0Mbxaqu9GKqpg5xFzdFiOPb/8Bmk/ylwceXgoaUx1nKcBGb/Bg+jICiNMEYIbGyMuYiHb0iJeVbjbBLLfWuAAuUPftfnKPH3dAu1YvhaS5nv7a5wICrXdJWeVNpBxk_0_Volume:MAK_EnterpriseSN_TH
eb6d346f-1c60-4643-b960-40ec31596c45_DXG%f%7C-N3%f%6C4-C4H%f%TG-X4%f%T3X-2Y%f%V77_161_X21-43626_vHO/5UEtrsDzGC30A2Ya5DYXlNMs7hVYiLvM7X31xkaFMxogbiy3ZDxBbjRku3VXyW+TYsFX/D/wdJgFmMrhsNrObkxqzYMMRjx+BpwOx2PspKpS2RyzovyRl8v93SvHB5IyoO2/3pm2YqJDK1hXLhms6+DDPuiofQt36q47reQ_0_____Retail_ProfessionalWorkstation
89e87510-ba92-45f6-8329-3afa905e3e83_WYP%f%NQ-8C%f%467-V2W%f%6J-TX%f%4WX-WT%f%2RQ_162_X21-43644_phlxNLr+sk8cCCmAVU3k3XrtD6sFDeoaODc+21soKqePbVQbzPHgokS73ccok6/gDfu/u5UKc7omL8pm2IhIhf70oC+8M/FFp0zRFeC/ZFXdF2tL23oKWI9kZbvcaoZBiqaDGc1bNYi5KAZYaJU8wwqw16ZnohQJZ7QR9cgUfFQ_0_____Retail_ProfessionalWorkstationN
62f0c100-9c53-4e02-b886-a3528ddfe7f6_8PT%f%T6-RN%f%W4C-6V7%f%J2-C2%f%D3X-MH%f%BPB_164_X21-04955_Px7QWdfy0esrMzQoydKlmIcGdfV0pQvbnumyrh4evDNF9gpENm8OIfZfljIynury0qZAkw4AG3uGyp+5IxZGIh6U3dz41uNVfEcA9NZ34OEBXMtjEOU1ZbJ8wp8JecQKwlORclvsri9OOi0GbGc0TYRanlci2jJL/3x/gSuWXCs_0_____Retail_ProfessionalEducation
13a38698-4a49-4b9e-8e83-98fe51110953_GJT%f%YN-HD%f%MQY-FRR%f%76-HV%f%GC7-QP%f%F8P_165_X21-04956_GRSYno4+yqU/JMxHLDKdvdFWRz1uT90n5JkTvSqztDvXMf/mBhSV/OpppJWGo6UL0FwqYcu9oXl+Vx336pLAE5/EDzQHh+QCwOCDJiTKnd3hW/zrGMe6Sb0OAIkNNML9gcOBbr1IHFWhN99r8ZWl5JjpzMs2nPjejB1Ec8NCcpE_0_____Retail_ProfessionalEducationN
df96023b-dcd9-4be2-afa0-c6c871159ebe_NJC%f%F7-PW%f%8QT-332%f%4D-68%f%8JX-2Y%f%V66_175_X21-41295_kkJyX1AwYgDYcGK1eIRdocybkbAfEtQkDxhRUhY89X2i2PSD9jcsGQgHWyD3KUKWb3bzR8QkDS3MTeieOw3EzD0RyAQhHc6lRR+rk18lh5UOVCgrZ6byxn29Ur+jAh0LJXImggC9JMGb2cTYaZckxzm3ICoAKwrmI9JnrzBTVmY_0_____Retail_ServerRdsh
d4ef7282-3d2c-4cf0-9976-8854e64a8d1e_V3W%f%VW-N2%f%PV2-CGW%f%C3-34%f%QGF-VM%f%J2C_178_X21-32983_YIMgXu2dZ9x1r1NLs3egTc/8EYc1RndYDvoX7QquQQLnhnhbSNBw3hmlqrQ0zNsTLut3EKpGZK2CwPspJJWE60lecdxI4211K748P6vkuqHPL4uFqXyKxTG3qRrtDIra5nnMn4GqG2fWuguzTXaumu8cJU3H1uTOsR1E/DQnJJ0_0_____Retail_Cloud
af5c9381-9240-417d-8d35-eb40cd03e484_NH9%f%J3-68%f%WK7-6FB%f%93-4K%f%3DF-DJ%f%4F6_179_X21-32987_H0qrFdf+FQxcSRJDtEwd8OfwC4iH/25Q01jz3QuB9yhEqB0W1i83u0WDpVK04pvU1EDCCRRI/DhXynbkWpLC0chdTOW4k5jIy+aa0cD3fccz9ChSjVHMzyTg3abEVFAvy9rttUyxcFIOKcINXHTxTRp5cZPwOa393tlJyBiliAo_0_____Retail_CloudN
8ab9bdd1-1f67-4997-82d9-8878520837d9_XQQ%f%YW-NF%f%FMW-XJP%f%BH-K8%f%732-CK%f%FFD_188_X21-99378_Bwx3E7qmE6M8UR6+KPqLnnavI6ThNHHUO717RJY9di2YI9rzC3O0LceXOHjshSKwfwxosqFsD/p/inrJmabed1yA/ZWwISyGtAIGTtRgpuSE4TAfW6KEW0v7rcr2wwwDq7DHSuz4QN4odEGe9bvtx4zIZKufQzzN4TN2rd/BJkE_0_____OEM:DM_IoTEnterprise
ed655016-a9e8-4434-95d9-4345352c2552_QPM%f%6N-7J%f%2WJ-P88%f%HH-P3%f%YRH-YY%f%74H_191_X21-99682_lE8qL1p4m68mv9wcxU2sdKZPIccybtOjr+aMAdV+sLHs9wzE26oz5GiSZ3UzpU7yoYrNMqwGkKX6mrCEGRLh+XR2Ricp7ELA1PkzaGm0FLUqaK2GNVQ00i+s6KcA2XRr/gWOhhGTqSCjpSi9cMiqMbftf9Bo/BJVK3ib9xU4OQw_0_OEM:NONSLP_IoTEnterpriseS_VB
d4bdc678-0a4b-4a32-a5b3-aaa24c3b0f24_K9V%f%KN-3B%f%GWV-Y62%f%4W-MC%f%RMQ-BH%f%DCD_202_X22-53884_hPcIn0dF9Dq6zlXd3RxBqVDPDnf5sTasTjUqhD6lGc9IkTc8476NHd1PV1Ds++VO34/dw2H2PWk33LT5Es6PnUi32Ypva4POy4QJo5W3qyduiJiHUOM5GS9yAkKfdHFgUXaUVwopYKq+EwmgxFmEvHYdWgREHgIMyNoKAZQK0Ok_0_____Retail_CloudEditionN
92fb8726-92a8-4ffc-94ce-f82e07444653_KY7%f%PN-VR%f%6RX-83W%f%6Y-6D%f%DYQ-T6%f%R4W_203_X22-53847_DCP6QzPj+BD1EEmlBelBt7x9AmvQOfd7kdkUB0b0x6/TNHRnZtdyix3pNX2IDQtJbLnNLc2ZlMmupbZQrtyxe3xl8+xlCnHByXZpzFty9sGzq3MozHHA9u9WsJEf5R7tnFDplNM1UitlTVTAyuCGk83brY4zjmz/52pUQyQHzjI_0_____Retail_CloudEdition
d4f9b41f-205c-405e-8e08-3d16e88e02be_J7N%f%JW-V6%f%KBM-CC8%f%RW-Y2%f%9Y4-HQ%f%2MJ_205_X23-15027_U9eyfIBXrs++lyP6OjHHaF/wjieAxQeSKwzSkGBeTTpyCDcenq8t4cKvqDHnauSZzaVPWNoVcASkMCdlJi3EkR29KSgvx9/K2OB8LVH2PPpqvwjm1ZZdrvLMGhW83A/KRrtN9AOx7bnPC8MNLErnzbRRS9/aOrmp4Uzo8EIVagI_0_OEM:NONSLP_IoTEnterpriseSK
) do (
for /f "tokens=1-10 delims=_" %%A in ("%%#") do (

if %1==key if %osSKU%==%%C (

REM Detect key attempt 1

if "%2"=="attempt1" if not defined key (
echo "!applist!" | find /i "%%A" 1>nul && (
if %%F==1 set notworking=1
set key=%%B
)
)

REM Detect key attempt 2

if "%2"=="attempt2" if not defined key (
set actidnotfound=1
set 9th=%%I
if not defined 9th (
if %%F==1 set notworking=1
set key=%%B
) else (
echo "%branch%" | find /i "%%I" 1>nul && (
if %%F==1 set notworking=1
set key=%%B
)
)
)
)

REM Generate ticket

if %1==ticket if "%key%"=="%%B" (
set "string=OSMajorVersion=5;OSMinorVersion=1;OSPlatformId=2;PP=0;Pfn=Microsoft.Windows.%%C.%%D_8wekyb3d8bbwe;DownlevelGenuineState=1;$([char]0)"
for /f "tokens=* delims=" %%i in ('%psc% [conv%f%ert]::ToBas%f%e64String([Text.En%f%coding]::Uni%f%code.GetBytes("""!string!"""^)^)') do set "encoded=%%i"
echo "!encoded!" | find "AAAA" 1>nul || exit /b

<nul set /p "=<?xml version="1.0" encoding="utf-8"?><genuineAuthorization xmlns="http://www.microsoft.com/DRM/SL/GenuineAuthorization/1.0"><version>1.0</version><genuineProperties origin="sppclient"><properties>OA3xOriginalProductId=;OA3xOriginalProductKey=;SessionId=!encoded!;TimeStampClient=2022-10-11T12:00:00Z</properties><signatures><signature name="clientLockboxKey" method="rsa-sha256">%%E=</signature></signatures></genuineProperties></genuineAuthorization>" >"%tdir%\GenuineTicket"
)

)
)
exit /b

::========================================================================================================================================

::  Below code is used to get alternate edition name and key if current edition doesn't support HWID activation

::  ProfessionalCountrySpecific won't be converted because it's not a good idea to change CountrySpecific editions

::  1st column = Current SKU ID
::  2nd column = Current Edition Name
::  3rd column = Current Edition Activation ID
::  4th column = Alternate Edition Activation ID
::  5th column = Alternate Edition HWID Key
::  6th column = Alternate Edition Name
::  Separator  = _


:hwidfallback

set notfoundaltactID=
if %_NoEditionChange%==1 exit /b

for %%# in (
125_EnterpriseS-2021___________cce9d2de-98ee-4ce2-8113-222620c64a27_ed655016-a9e8-4434-95d9-4345352c2552_QPM%f%6N-7J2%f%WJ-P8%f%8HH-P3Y%f%RH-YY%f%74H_IoTEnterpriseS-2021
191_IoTEnterpriseS-Win11_______59eb965c-9150-42b7-a0ec-22151b9897c5_d4f9b41f-205c-405e-8e08-3d16e88e02be_J7N%f%JW-V6K%f%BM-CC%f%8RW-Y29%f%Y4-HQ%f%2MJ_IoTEnterpriseSK-Win11
138_ProfessionalSingleLanguage_a48938aa-62fa-4966-9d44-9f04da3f72f2_4de7cb65-cdf1-4de9-8ae8-e3cce27b9f2c_VK7%f%JG-NPH%f%TM-C9%f%7JM-9MP%f%GT-3V%f%66T_Professional
) do (
for /f "tokens=1-6 delims=_" %%A in ("%%#") do if %osSKU%==%%A (
echo "!applist!" | find /i "%%C" 1>nul && (
echo "!applist!" | find /i "%%D" 1>nul && (
set altkey=%%E
set curedition=%%B
set altedition=%%F
) || (
set altedition=%%F
set notfoundaltactID=1
)
)
)
)
exit /b

:+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

:_Check_Status_wmi

@setlocal DisableDelayedExpansion
@echo off
mode con cols=100 lines=32
>nul 2>&1 powershell "&{$W=$Host.UI.RawUI.WindowSize;$B=$Host.UI.RawUI.BufferSize;$W.Height=31;$B.Height=300;$Host.UI.RawUI.WindowSize=$W;$Host.UI.RawUI.BufferSize=$B;}"
color 07
title Check Activation Status [wmi]

set WMI_VBS=0
@cls
set "_cmdf=%~f0"
set wspp=SoftwareLicensingProduct
set wsps=SoftwareLicensingService
set ospp=OfficeSoftwareProtectionProduct
set osps=OfficeSoftwareProtectionService
set winApp=55c92734-d682-4d71-983e-d6ec3f16059f
set o14App=59a52881-a989-479d-af46-f275c6370663
set o15App=0ff1ce15-a989-479d-af46-f275c6370663
for %%# in (spp_get,ospp_get,cW1nd0ws,sppw,c0ff1ce15,sppo,osppsvc,ospp14,ospp15) do set "%%#="
for /f "tokens=6 delims=[]. " %%# in ('ver') do set winbuild=%%#
set "spp_get=Description, DiscoveredKeyManagementServiceMachineName, DiscoveredKeyManagementServiceMachinePort, EvaluationEndDate, GracePeriodRemaining, ID, KeyManagementServiceMachine, KeyManagementServicePort, KeyManagementServiceProductKeyID, LicenseStatus, LicenseStatusReason, Name, PartialProductKey, ProductKeyID, VLActivationInterval, VLRenewalInterval"
set "ospp_get=%spp_get%"
if %winbuild% GEQ 9200 set "spp_get=%spp_get%, KeyManagementServiceLookupDomain, VLActivationTypeEnabled"
if %winbuild% GEQ 9600 set "spp_get=%spp_get%, DiscoveredKeyManagementServiceMachineIpAddress, ProductKeyChannel"
set "_work=%~dp0"
set "_batf=%~f0"
set "_batp=%_batf:'=''%"
set "_Local=%LocalAppData%"
set _Identity=0
setlocal EnableDelayedExpansion
dir /b /s /a:-d "!_Local!\Microsoft\Office\Licenses\*1*" 1>nul 2>nul && set _Identity=1
dir /b /s /a:-d "!ProgramData!\Microsoft\Office\Licenses\*1*" 1>nul 2>nul && set _Identity=1
pushd "!_work!"
setlocal DisableDelayedExpansion
if %winbuild% LSS 9200 if not exist "%SystemRoot%\servicing\Packages\Microsoft-Windows-PowerShell-WTR-Package~*.mum" set _Identity=0

set "SysPath=%SystemRoot%\System32"
set "Path=%SystemRoot%\System32;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "SysPath=%SystemRoot%\Sysnative"
set "Path=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\Wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%Path%"
)

set _cwmi=0
for %%# in (wmic.exe) do @if not "%%~$PATH:#"=="" (
wmic path Win32_ComputerSystem get CreationClassName /value 2>nul | find /i "ComputerSystem" 1>nul && set _cwmi=1
)

if %_cwmi% EQU 0 (
echo:
echo Error: WMI is not responding in the system.
echo:
echo In MAS, Goto Troubleshoot and run Fix WMI option.
echo:
echo Press any key to go back...
pause >nul
exit /b
)

set "line2=************************************************************"
set "line3=____________________________________________________________"
set "_psc=powershell"

set _prsh=1
for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" set _prsh=0
set "_csg=cscript.exe //NoLogo //Job:WmiMulti "%~nx0?.wsf""
set "_csq=cscript.exe //NoLogo //Job:WmiQuery "%~nx0?.wsf""
set "_csx=cscript.exe //NoLogo //Job:XPDT "%~nx0?.wsf""
if %_cwmi% EQU 0 set WMI_VBS=1
if %WMI_VBS% EQU 0 (
set "_zz1=wmic path"
set "_zz2=where"
set "_zz3=get"
set "_zz4=/value"
set "_zz5=("
set "_zz6=)"
set "_zz7="wmic path"
set "_zz8=/value""
) else (
set "_zz1=%_csq%"
set "_zz2="
set "_zz3="
set "_zz4="
set "_zz5=""
set "_zz6=""
set "_zz7=%_csq%"
set "_zz8="
)
set _WSH=0
set OsppHook=1
sc query osppsvc >nul 2>&1
if %errorlevel% EQU 1060 set OsppHook=0

net start sppsvc /y >nul 2>&1
call :casWpkey %wspp% %winApp% cW1nd0ws sppw
if %winbuild% GEQ 9200 call :casWpkey %wspp% %o15App% c0ff1ce15 sppo
if %OsppHook% NEQ 0 (
net start osppsvc /y >nul 2>&1
call :casWpkey %ospp% %o14App% osppsvc ospp14
if %winbuild% LSS 9200 call :casWpkey %ospp% %o15App% osppsvc ospp15
)

echo %line2%
echo ***                   Windows Status                     ***
echo %line2%
if not defined cW1nd0ws (
echo.
echo Error: product key not found.
goto :casWcon
)
set winID=1
set "_qr=%_zz7% %wspp% %_zz2% %_zz5%ApplicationID='%winApp%' and PartialProductKey is not null%_zz6% %_zz3% ID %_zz8%"
for /f "tokens=2 delims==" %%# in ('%_qr%') do (
  set "chkID=%%#"
  call :casWdet "%wspp%" "%wsps%" "%spp_get%"
  call :casWout
  echo %line3%
  echo.
)

:casWcon
set winID=0
set verbose=1
if not defined c0ff1ce15 (
if defined osppsvc goto :casWospp
goto :casWend
)
echo %line2%
echo ***                   Office Status                      ***
echo %line2%
set "_qr=%_zz7% %wspp% %_zz2% %_zz5%ApplicationID='%o15App%' and PartialProductKey is not null%_zz6% %_zz3% ID %_zz8%"
for /f "tokens=2 delims==" %%# in ('%_qr%') do (
  set "chkID=%%#"
  call :casWdet "%wspp%" "%wsps%" "%spp_get%"
  call :casWout
  echo %line3%
  echo.
)
set verbose=0
if defined osppsvc goto :casWospp
goto :casWend

:casWospp
if %verbose% EQU 1 (
echo %line2%
echo ***                   Office Status                      ***
echo %line2%
)
set "_qr=%_zz7% %ospp% %_zz2% %_zz5%ApplicationID='%o15App%' and PartialProductKey is not null%_zz6% %_zz3% ID %_zz8%"
if defined ospp15 for /f "tokens=2 delims==" %%# in ('%_qr%') do (
  set "chkID=%%#"
  call :casWdet "%ospp%" "%osps%" "%ospp_get%"
  call :casWout
  echo %line3%
  echo.
)
set "_qr=%_zz7% %ospp% %_zz2% %_zz5%ApplicationID='%o14App%' and PartialProductKey is not null%_zz6% %_zz3% ID %_zz8%"
if defined ospp14 for /f "tokens=2 delims==" %%# in ('%_qr%') do (
  set "chkID=%%#"
  call :casWdet "%ospp%" "%osps%" "%ospp_get%"
  call :casWout
  echo %line3%
  echo.
)
goto :casWend

:casWpkey
set "_qr=%_zz1% %1 %_zz2% %_zz5%ApplicationID='%2' and PartialProductKey is not null%_zz6% %_zz3% ID %_zz4%"
%_qr% 2>nul | findstr /i ID 1>nul && (set %3=1&set %4=1)
exit /b

:casWdet
for %%# in (%~3) do set "%%#="
if /i %~1==%ospp% for %%# in (DiscoveredKeyManagementServiceMachineIpAddress, KeyManagementServiceLookupDomain, ProductKeyChannel, VLActivationTypeEnabled) do set "%%#="
set "cKmsClient="
set "cTblClient="
set "cAvmClient="
set "ExpireMsg="
set "_xpr="
set "_qr="wmic path %~1 where ID='%chkID%' get %~3 /value" ^| findstr ^="
if %WMI_VBS% NEQ 0 set "_qr=%_csg% %~1 "ID='%chkID%'" "%~3""
for /f "tokens=* delims=" %%# in ('%_qr%') do set "%%#"

set /a _gpr=(GracePeriodRemaining+1440-1)/1440
echo %Description%| findstr /i VOLUME_KMSCLIENT 1>nul && (set cKmsClient=1&set _mTag=Volume)
echo %Description%| findstr /i TIMEBASED_ 1>nul && (set cTblClient=1&set _mTag=Timebased)
echo %Description%| findstr /i VIRTUAL_MACHINE_ACTIVATION 1>nul && (set cAvmClient=1&set _mTag=Automatic VM)
cmd /c exit /b %LicenseStatusReason%
set "LicenseReason=%=ExitCode%"
set "LicenseMsg=Time remaining: %GracePeriodRemaining% minute(s) (%_gpr% day(s))"
if %_gpr% GEQ 1 if %_WSH% EQU 1 (
for /f "tokens=* delims=" %%# in ('%_csx% %GracePeriodRemaining%') do set "_xpr=%%#"
)
if %_gpr% GEQ 1 if %_prsh% EQU 1 if not defined _xpr (
for /f "tokens=* delims=" %%# in ('%_psc% "$([DateTime]::Now.addMinutes(%GracePeriodRemaining%)).ToString('yyyy-MM-dd HH:mm:ss')" 2^>nul') do set "_xpr=%%#"
title Check Activation Status [wmi]
)

if %LicenseStatus% EQU 0 (
set "License=Unlicensed"
set "LicenseMsg="
)
if %LicenseStatus% EQU 1 (
set "License=Licensed"
set "LicenseMsg="
if %GracePeriodRemaining% EQU 0 (
  if %winID% EQU 1 (set "ExpireMsg=The machine is permanently activated.") else (set "ExpireMsg=The product is permanently activated.")
  ) else (
  set "LicenseMsg=%_mTag% activation expiration: %GracePeriodRemaining% minute(s) (%_gpr% day(s))"
  if defined _xpr set "ExpireMsg=%_mTag% activation will expire %_xpr%"
  )
)
if %LicenseStatus% EQU 2 (
set "License=Initial grace period"
if defined _xpr set "ExpireMsg=Initial grace period ends %_xpr%"
)
if %LicenseStatus% EQU 3 (
set "License=Additional grace period (KMS license expired or hardware out of tolerance)"
if defined _xpr set "ExpireMsg=Additional grace period ends %_xpr%"
)
if %LicenseStatus% EQU 4 (
set "License=Non-genuine grace period."
if defined _xpr set "ExpireMsg=Non-genuine grace period ends %_xpr%"
)
if %LicenseStatus% EQU 6 (
set "License=Extended grace period"
if defined _xpr set "ExpireMsg=Extended grace period ends %_xpr%"
)
if %LicenseStatus% EQU 5 (
set "License=Notification"
  if "%LicenseReason%"=="C004F200" (set "LicenseMsg=Notification Reason: 0xC004F200 (non-genuine)."
  ) else if "%LicenseReason%"=="C004F009" (set "LicenseMsg=Notification Reason: 0xC004F009 (grace time expired)."
  ) else (set "LicenseMsg=Notification Reason: 0x%LicenseReason%"
  )
)
if %LicenseStatus% GTR 6 (
set "License=Unknown"
set "LicenseMsg="
)
if not defined cKmsClient exit /b

if %KeyManagementServicePort%==0 set KeyManagementServicePort=1688
set "KmsReg=Registered KMS machine name: %KeyManagementServiceMachine%:%KeyManagementServicePort%"
if "%KeyManagementServiceMachine%"=="" set "KmsReg=Registered KMS machine name: KMS name not available"

if %DiscoveredKeyManagementServiceMachinePort%==0 set DiscoveredKeyManagementServiceMachinePort=1688
set "KmsDns=KMS machine name from DNS: %DiscoveredKeyManagementServiceMachineName%:%DiscoveredKeyManagementServiceMachinePort%"
if "%DiscoveredKeyManagementServiceMachineName%"=="" set "KmsDns=DNS auto-discovery: KMS name not available"

set "_qr="wmic path %~2 get ClientMachineID, KeyManagementServiceHostCaching /value" ^| findstr ^="
if %WMI_VBS% NEQ 0 set "_qr=%_csg% %~2 "ClientMachineID, KeyManagementServiceHostCaching""
for /f "tokens=* delims=" %%# in ('%_qr%') do set "%%#"
if /i %KeyManagementServiceHostCaching%==True (set KeyManagementServiceHostCaching=Enabled) else (set KeyManagementServiceHostCaching=Disabled)

if %winbuild% LSS 9200 exit /b
if /i %~1==%ospp% exit /b

if "%KeyManagementServiceLookupDomain%"=="" set "KeyManagementServiceLookupDomain="

if %VLActivationTypeEnabled% EQU 3 (
set VLActivationType=Token
) else if %VLActivationTypeEnabled% EQU 2 (
set VLActivationType=KMS
) else if %VLActivationTypeEnabled% EQU 1 (
set VLActivationType=AD
) else (
set VLActivationType=All
)

if %winbuild% LSS 9600 exit /b
if "%DiscoveredKeyManagementServiceMachineIpAddress%"=="" set "DiscoveredKeyManagementServiceMachineIpAddress=not available"
exit /b

:casWout
echo.
echo Name: %Name%
echo Description: %Description%
echo Activation ID: %ID%
echo Extended PID: %ProductKeyID%
if defined ProductKeyChannel echo Product Key Channel: %ProductKeyChannel%
echo Partial Product Key: %PartialProductKey%
echo License Status: %License%
if defined LicenseMsg echo %LicenseMsg%
if not %LicenseStatus%==0 if not %EvaluationEndDate:~0,8%==16010101 echo Evaluation End Date: %EvaluationEndDate:~0,4%-%EvaluationEndDate:~4,2%-%EvaluationEndDate:~6,2% %EvaluationEndDate:~8,2%:%EvaluationEndDate:~10,2% UTC
if not defined cKmsClient (
if defined ExpireMsg echo.&echo.    %ExpireMsg%
exit /b
)
if defined VLActivationTypeEnabled echo Configured Activation Type: %VLActivationType%
echo.
if not %LicenseStatus%==1 (
echo Please activate the product in order to update KMS client information values.
exit /b
)
echo Most recent activation information:
echo Key Management Service client information
echo.    Client Machine ID (CMID): %ClientMachineID%
echo.    %KmsDns%
echo.    %KmsReg%
if defined DiscoveredKeyManagementServiceMachineIpAddress echo.    KMS machine IP address: %DiscoveredKeyManagementServiceMachineIpAddress%
echo.    KMS machine extended PID: %KeyManagementServiceProductKeyID%
echo.    Activation interval: %VLActivationInterval% minutes
echo.    Renewal interval: %VLRenewalInterval% minutes
echo.    KMS host caching: %KeyManagementServiceHostCaching%
if defined KeyManagementServiceLookupDomain echo.    KMS SRV record lookup domain: %KeyManagementServiceLookupDomain%
if defined ExpireMsg echo.&echo.    %ExpireMsg%
exit /b

:casWend
if %_Identity% EQU 1 if %_prsh% EQU 1 (
echo %line2%
echo ***                  Office vNext Status                 ***
echo %line2%
setlocal EnableDelayedExpansion
%_psc% "$f=[IO.File]::ReadAllText('!_batp!') -split ':vNextDiag\:.*';iex ($f[1])"
title Check Activation Status [wmi]
echo %line3%
echo.
)
echo.
call :_color %_Yellow% "Press any key to go back..."
pause >nul
exit /b

:vNextDiag:
function PrintModePerPridFromRegistry
{
	$vNextRegkey = "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Licensing\LicensingNext"
	$vNextPrids = Get-Item -Path $vNextRegkey -ErrorAction Ignore | Select-Object -ExpandProperty 'property' | Where-Object -FilterScript {$_.ToLower() -like "*retail" -or $_.ToLower() -like "*volume"}
	If ($vNextPrids -Eq $null)
	{
		Write-Host "No registry keys found."
		Return
	}
	$vNextPrids | ForEach `
	{
		$mode = (Get-ItemProperty -Path $vNextRegkey -Name $_).$_
		Switch ($mode)
		{
			2 { $mode = "vNext"; Break }
			3 { $mode = "Device"; Break }
			Default { $mode = "Legacy"; Break }
		}
		Write-Host $_ = $mode
	}
}
function PrintSharedComputerLicensing
{
	$scaRegKey = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
	$scaValue = Get-ItemProperty -Path $scaRegKey -ErrorAction Ignore | Select-Object -ExpandProperty "SharedComputerLicensing" -ErrorAction Ignore
	$scaRegKey2 = "HKLM:\SOFTWARE\Microsoft\Office\16.0\Common\Licensing"
	$scaValue2 = Get-ItemProperty -Path $scaRegKey2 -ErrorAction Ignore | Select-Object -ExpandProperty "SharedComputerLicensing" -ErrorAction Ignore
	$scaPolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Licensing"
	$scaPolicyValue = Get-ItemProperty -Path $scaPolicyKey -ErrorAction Ignore | Select-Object -ExpandProperty "SharedComputerLicensing" -ErrorAction Ignore
	If ($scaValue -Eq $null -And $scaValue2 -Eq $null -And $scaPolicyValue -Eq $null)
	{
		Write-Host "No registry keys found."
		Return
	}
	$scaModeValue = $scaValue -Or $scaValue2 -Or $scaPolicyValue
	If ($scaModeValue -Eq 0)
	{
		$scaMode = "Disabled"
	}
	If ($scaModeValue -Eq 1)
	{
		$scaMode = "Enabled"
	}
	Write-Host "SharedComputerLicensing" = $scaMode
	Write-Host
	$tokenFiles = $null
	$tokenPath = "${env:LOCALAPPDATA}\Microsoft\Office\16.0\Licensing"
	If (Test-Path $tokenPath)
	{
		$tokenFiles = Get-ChildItem -Path $tokenPath -Recurse -File -Filter "*authString*"
	}
	If ($tokenFiles.length -Eq 0)
	{
		Write-Host "No tokens found."
		Return
	}
	$tokenFiles | ForEach `
	{
		$tokenParts = (Get-Content -Encoding Unicode -Path $_.FullName).Split('_')
		$output = [PSCustomObject] `
			@{
				ACID = $tokenParts[0];
				User = $tokenParts[3]
				NotBefore = $tokenParts[4];
				NotAfter = $tokenParts[5];
			} | ConvertTo-Json
		Write-Host $output
	}
}
function PrintLicensesInformation
{
	Param(
		[ValidateSet("NUL", "Device")]
		[String]$mode
	)
	If ($mode -Eq "NUL")
	{
		$licensePath = "${env:LOCALAPPDATA}\Microsoft\Office\Licenses"
	}
	ElseIf ($mode -Eq "Device")
	{
		$licensePath = "${env:PROGRAMDATA}\Microsoft\Office\Licenses"
	}
	$licenseFiles = $null
	If (Test-Path $licensePath)
	{
		$licenseFiles = Get-ChildItem -Path $licensePath -Recurse -File
	}
	If ($licenseFiles.length -Eq 0)
	{
		Write-Host "No licenses found."
		Return
	}
	$licenseFiles | ForEach `
	{
		$license = (Get-Content -Encoding Unicode $_.FullName | ConvertFrom-Json).License
		$decodedLicense = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($license)) | ConvertFrom-Json
		$licenseType = $decodedLicense.LicenseType
		If ($null -Ne $decodedLicense.ExpiresOn)
		{
			$expiry = [DateTime]::Parse($decodedLicense.ExpiresOn, $null, 48)
		}
		Else
		{
			$expiry = New-Object DateTime
		}
		$licenseState = $null
		If ((Get-Date) -Gt (Get-Date $decodedLicense.MetaData.NotAfter))
		{
			$licenseState = "RFM"
		}
		ElseIf ((Get-Date) -Lt (Get-Date $expiry))
		{
			$licenseState = "Licensed"
		}
		Else
		{
			$licenseState = "Grace"
		}
		if ($mode -Eq "NUL")
		{
			$output = [PSCustomObject] `
			@{
				Version = $_.Directory.Name
				Type = "User|${licenseType}";
				Product = $decodedLicense.ProductReleaseId;
				Acid = $decodedLicense.Acid;
				LicenseState = $licenseState;
				EntitlementStatus = $decodedLicense.Status;
				EntitlementExpiration = $decodedLicense.ExpiresOn;
				ReasonCode = $decodedLicense.ReasonCode;
				NotBefore = $decodedLicense.Metadata.NotBefore;
				NotAfter = $decodedLicense.Metadata.NotAfter;
				NextRenewal = $decodedLicense.Metadata.RenewAfter;
				TenantId = $decodedLicense.Metadata.TenantId;
			} | ConvertTo-Json
		}
		ElseIf ($mode -Eq "Device")
		{
			$output = [PSCustomObject] `
			@{
				Version = $_.Directory.Name
				Type = "Device|${licenseType}";
				Product = $decodedLicense.ProductReleaseId;
				Acid = $decodedLicense.Acid;
				DeviceId = $decodedLicense.Metadata.DeviceId;
				LicenseState = $licenseState;
				EntitlementStatus = $decodedLicense.Status;
				EntitlementExpiration = $decodedLicense.ExpiresOn;
				ReasonCode = $decodedLicense.ReasonCode;
				NotBefore = $decodedLicense.Metadata.NotBefore;
				NotAfter = $decodedLicense.Metadata.NotAfter;
				NextRenewal = $decodedLicense.Metadata.RenewAfter;
				TenantId = $decodedLicense.Metadata.TenantId;
			} | ConvertTo-Json
		}
		Write-Output $output
	}
}
	Write-Host
	Write-Host "========== Mode per ProductReleaseId =========="
	Write-Host
PrintModePerPridFromRegistry
	Write-Host
	Write-Host "========== Shared Computer Licensing =========="
	Write-Host
PrintSharedComputerLicensing
	Write-Host
	Write-Host "========== vNext licenses =========="
	Write-Host
PrintLicensesInformation -Mode "NUL"
	Write-Host
	Write-Host "========== Device licenses =========="
	Write-Host
PrintLicensesInformation -Mode "Device"
:vNextDiag:

:+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

:change_edition
@setlocal DisableDelayedExpansion
@echo off

::  To stage current edition while changing edition with CBS Upgrade Method, change 0 to 1 in below line
set _stg=0

cls
color 07
title  Change Windows Edition

set _elev=
if /i "%~1"=="-el" set _elev=1

set winbuild=1
set "nul=>nul 2>&1"
set psc=powershell.exe
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G

set _NCS=1
if %winbuild% LSS 10586 set _NCS=0
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 2>nul | find /i "0x0" 1>nul && (set _NCS=0)

if %_NCS% EQU 1 (
for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"
set     "Red="41;97m""
set    "Gray="100;97m""
set   "Green="42;97m""
set "Magenta="45;97m""
set  "_White="40;37m""
set  "_Green="40;92m""
set "_Yellow="40;93m""
) else (
set     "Red="Red" "white""
set    "Gray="Darkgray" "white""
set   "Green="DarkGreen" "white""
set "Magenta="Darkmagenta" "white""
set  "_White="Black" "Gray""
set  "_Green="Black" "Green""
set "_Yellow="Black" "Yellow""
)

set "nceline=echo: &echo ==== ERROR ==== &echo:"
set "eline=echo: &call :dk_color %Red% "==== ERROR ====" &echo:"
set "line=echo ___________________________________________________________________________________________"
if %~z0 GEQ 200000 (set "_exitmsg=Go back") else (set "_exitmsg=Exit")

::========================================================================================================================================

::  Fix for the special characters limitation in path name

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

set _PSarg="""%~f0""" -el %_args%

set "_ttemp=%temp%"

setlocal EnableDelayedExpansion

::========================================================================================================================================

cls
mode 98, 30

echo:
echo Initializing...
echo:
call :dk_product
call :dk_ckeckwmic

::  Show info for potential script stuck scenario

sc start sppsvc %nul%
if %errorlevel% NEQ 1056 if %errorlevel% NEQ 0 (
echo:
echo Error code: %errorlevel%
call :dk_color %Red% "Failed to start [sppsvc] service, rest of the process may take a long time..."
echo:
)

::========================================================================================================================================

::  Check Activation IDs

call :dk_actids

if not defined applist (
%eline%
echo Activation IDs not found. Aborting...
echo:
echo Check this page for help. https://massgrave.dev/troubleshoot
goto ced_done
)

::  Check Windows Edition

set osedition=
for /f "tokens=3 delims=: " %%a in ('DISM /English /Online /Get-CurrentEdition 2^>nul ^| find /i "Current Edition :"') do set "osedition=%%a"

if "%osedition%"=="" (
%eline%
DISM /English /Online /Get-CurrentEdition %nul%
cmd /c exit /b !errorlevel!
echo DISM command failed [Error Code - 0x!=ExitCode!]
echo OS Edition was not detected properly. Aborting...
echo:
echo Check this page for help. https://massgrave.dev/troubleshoot
goto ced_done
)

::  Check SKU value

set osSKU=
set regSKU=
set wmiSKU=

for /f "tokens=3 delims=." %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\ProductOptions" /v OSProductPfn 2^>nul') do set "regSKU=%%a"
if %_wmic% EQU 1 for /f "tokens=2 delims==" %%a in ('"wmic Path Win32_OperatingSystem Get OperatingSystemSKU /format:LIST" 2^>nul') do if not errorlevel 1 set "wmiSKU=%%a"
if %_wmic% EQU 0 for /f "tokens=1" %%a in ('%psc% "([WMI]'Win32_OperatingSystem=@').OperatingSystemSKU" 2^>nul') do if not errorlevel 1 set "wmiSKU=%%a"

set osSKU=%wmiSKU%
if not defined osSKU set osSKU=%regSKU%

if not defined osSKU (
%eline%
echo SKU value was not detected properly. Aborting...
goto ced_done
)

set branch=
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v BuildBranch 2^>nul') do set "branch=%%b"

::  Check PowerShell

%psc% $ExecutionContext.SessionState.LanguageMode 2>nul | find /i "Full" 1>nul || (
%eline%
echo PowerShell is not responding properly. Aborting...
goto ced_done
)

::========================================================================================================================================

::  Get Target editions list

set _target=
set _dtarget=
set _ptarget=
set _ntarget=

if %winbuild% GEQ 10240 for /f "tokens=4" %%a in ('dism /online /english /Get-TargetEditions ^| findstr /i /c:"Target Edition : "') do (if defined _dtarget (set "_dtarget=!_dtarget! %%a") else (set "_dtarget=%%a"))
for /f "tokens=4" %%a in ('%psc% "$f=[io.file]::ReadAllText('!_batp!') -split ':cbsxml\:.*';& ([ScriptBlock]::Create($f[1])) -GetTargetEditions;" ^| findstr /i /c:"Target Edition : "') do (if defined _ptarget (set "_ptarget=!_ptarget! %%a") else (set "_ptarget=%%a"))

::========================================================================================================================================

::  Block the change to/from CountrySpecific and CloudEdition editions

for %%# in (99 139 202 203) do if %osSKU%==%%# (
%eline%
echo [%winos% ^| SKU:%osSKU% ^| %winbuild%]
echo It's not recommended to change this installed edition to any other.
echo Aborting...
goto ced_done
)

for %%# in ( %_dtarget% %_ptarget% ) do (
echo "!_target!" | find /i " %%# " 1>nul || set "_target=!_target! %%# "
)

if defined _target (
for %%# in (%_target%) do (
echo %%# | findstr /i "CountrySpecific CloudEdition" %nul% || (set "_ntarget=!_ntarget! %%#")
)
)

if not defined _ntarget (
%line%
echo:
call :dk_color %Gray% "Target Edition not found."
echo Current Edition [%osedition% ^| %winbuild%] can not be changed to any other Edition.
%line%
goto ced_done
)

::========================================================================================================================================

:cedmenu2

cls
mode 98, 30
set inpt=
set note=
set counter=0
set verified=0
set targetedition=

%line%
echo:
call :dk_color %Gray% "You can change the Edition [%osedition%] [%winbuild%] to one of the following."
%line%
echo:

for %%A in (%_ntarget%) do (
set /a counter+=1
if %winbuild% GEQ 10240 (
echo "%_ptarget%" | find /i "%%A" 1>nul && (
set note=1
call :dk_color2 %_White% "[!counter!]  " %Magenta% "%%A"
) || (
echo [!counter!]  %%A
)
) else (
echo [!counter!]  %%A
)
set targetedition!counter!=%%A
)

%line%
echo:
echo [0]  %_exitmsg%
echo:
if defined note (
echo Note: CBS Upgrade Method is available for Purple colored editions.
echo:
)
call :dk_color %_Green% "Enter option number in keyboard, and press "Enter":"
set /p inpt=
if "%inpt%"=="" goto cedmenu2
if "%inpt%"=="0" exit /b
for /l %%i in (1,1,%counter%) do (if "%inpt%"=="%%i" set verified=1)
set targetedition=!targetedition%inpt%!
if %verified%==0 goto cedmenu2

::========================================================================================================================================

cls
if %winbuild% GEQ 10240 (
echo "%_ptarget%" | find /i "%targetedition%" 1>nul && (
echo "%_dtarget%" | find /i "%targetedition%" 1>nul && (
echo:
%line%
echo:
if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-Server*Edition~*.mum" (
echo  [1] DISM Method             [Recommended]
) else (
echo  [1] Changepk Method         [Recommended]
)
echo:
echo  [2] CBS Upgrade Method      [Alternative]
echo:
echo  [0] Go back
%line%
echo:
echo  Enter a menu option in the Keyboard:
choice /C:120 /N
set _el=!errorlevel!
if !_el!==3 goto :cedmenu2
if !_el!==2 goto :cbsmethod
if !_el!==1 REM
)
)
) else (
goto :cbsmethod
)

echo "%_ptarget%" | find /i "%targetedition%" 1>nul && (
echo "%_dtarget%" | find /i "%targetedition%" 1>nul || (
goto :cbsmethod
)
)

if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-Server*Edition~*.mum" (
goto :ced_change_server
)

cls
set key=
set _chan=
set _changepk=0

::  Check if changepk.exe or slmgr.vbs is required for edition upgrade

if not exist "%SystemRoot%\System32\spp\tokens\skus\%targetedition%\" (
set _changepk=1
)

if /i "%osedition:~0,4%"=="Core" (
if /i not "%targetedition:~0,4%"=="Core" (
set _changepk=1
)
)

if %_changepk%==1 (
set "keyflow=Retail Volume:MAK Volume:GVLK OEM:NONSLP OEM:DM"
) else (
set "keyflow=Retail OEM:NONSLP OEM:DM Volume:MAK Volume:GVLK"
)

if not defined key call :ced_targetSKU %targetedition%
if not defined key if defined targetSKU call :ced_windowskey
if defined key if defined pkeychannel set _chan=%pkeychannel%
if not defined key call :changeeditiondata

if not defined key (
%eline%
echo [%targetedition% ^| %winbuild%]
echo Unable to get product key from pkeyhelper.dll
echo Make sure you are using updated version of the script.
echo https://massgrave.dev
goto ced_done
)

::========================================================================================================================================

%line%

::  Changing from Core to Non-Core & Changing editions in Windows build older than 17134 requires "changepk /productkey" method and restart
::  In other cases, editions can be changed instantly with "slmgr /ipk"

cls
if %_changepk%==1 (
echo "%_chan%" | find /i "OEM" >NUL && (
%eline%
echo [%osedition%] can not be changed to [%targetedition%] Edition due to lack of non OEM keys.
echo Non-OEM keys are required to change from Core to Non-Core Editions.
goto ced_done
)
)

:ced_loop

cls
if %_changepk%==1 (
for %%a in (l.root-servers.net resolver1.opendns.com download.windowsupdate.com google.com) do (
for /f "delims=[] tokens=2" %%# in ('ping -n 1 %%a') do (
if not [%%#]==[] (
%eline%
echo Internet needs to be disconnected to change edition [%osedition%] to [%targetedition%]
echo Disconnect the Internet and then press any key...
pause >nul
goto ced_loop
)
)
)
)

echo:
echo Changing the Current Edition [%osedition%] to [%targetedition%]
echo:

if %_changepk%==1 (
call :dk_color %Magenta% "Notes-"
echo:
echo  - You can safely ignore if error appears in the upgrade Window,
echo    but in that case you must manually reboot the system.
echo:
echo  - Save your work before continue, system will auto restart.
echo  - You can connect to Internet after the system restart.
echo:
echo  - You will need to activate with HWID option once the edition is changed.
echo:
choice /C:21 /N /M "[1] Continue [2] %_exitmsg% : "
if !errorlevel!==1 exit /b
)

::========================================================================================================================================

if %_changepk%==0 (
echo Installing %_chan% Key [%key%]
echo:
if %_wmic% EQU 1 wmic path SoftwareLicensingService where __CLASS='SoftwareLicensingService' call InstallProductKey ProductKey="%key%" %nul%
if %_wmic% EQU 0 %psc% "(([WMISEARCHER]'SELECT Version FROM SoftwareLicensingService').Get()).InstallProductKey('%key%')" %nul%
if not !errorlevel!==0 cscript //nologo %windir%\system32\slmgr.vbs /ipk %key% %nul%

set error_code=!errorlevel!
cmd /c exit /b !error_code!
if !error_code! NEQ 0 set "error_code=[0x!=ExitCode!]"

if !error_code! EQU 0 (
call :dk_refresh
call :dk_color %Green% "[Successful]"
echo:
call :dk_color %Gray% "Reboot is required to properly change the Edition."
) else (
call :dk_color %Red% "[Unsuccessful] [Error Code: 0x!=ExitCode!]"
)
)

if %_changepk%==1 (
echo:
echo Applying the command with %_chan% Key
echo start changepk.exe /ProductKey %key%
start changepk.exe /ProductKey %key%
)
%line%

goto ced_done

::========================================================================================================================================

:cbsmethod

cls
mode con cols=105 lines=32
%nul% %psc% "&{$W=$Host.UI.RawUI.WindowSize;$B=$Host.UI.RawUI.BufferSize;$W.Height=31;$B.Height=200;$Host.UI.RawUI.WindowSize=$W;$Host.UI.RawUI.BufferSize=$B;}"

echo:
echo Changing the Current Edition [%osedition%] to [%targetedition%]
echo:
call :dk_color %Magenta% "Important - Save your work before continue, system will auto reboot."
if %winbuild% GEQ 17034 if %targetedition%==Professional echo           - Enterprise Key will be installed instead of Pro, you can quickly change to Pro later. 
echo:
choice /C:01 /N /M "[1] Continue [0] %_exitmsg% : "
if %errorlevel%==1 exit /b

echo:
echo Initializing...
echo:

if %_stg%==0 (set stage=) else (set stage=-StageCurrent)
%psc% "$f=[io.file]::ReadAllText('!_batp!') -split ':cbsxml\:.*';& ([ScriptBlock]::Create($f[1])) -SetEdition %targetedition% %stage%;"

echo:
%line%
goto ced_done

::========================================================================================================================================

:ced_change_server

cls
mode con cols=105 lines=32
%nul% %psc% "&{$W=$Host.UI.RawUI.WindowSize;$B=$Host.UI.RawUI.BufferSize;$W.Height=31;$B.Height=200;$Host.UI.RawUI.WindowSize=$W;$Host.UI.RawUI.BufferSize=$B;}"

set key=
set pkeychannel=
set "keyflow=Volume:GVLK Retail Volume:MAK OEM:NONSLP OEM:DM"
call :changeeditionserverdata

if not defined key call :ced_targetSKU %targetedition%
if not defined key if defined targetSKU call :ced_windowskey
if defined key if not defined pkeychannel call :dk_pkeychannel %key%

if not defined key (
%eline%
echo [%targetedition% ^| %winbuild%]
echo Unable to get product key from pkeyhelper.dll
echo Make sure you are using updated version of the script.
echo https://massgrave.dev
goto ced_done
)

::========================================================================================================================================

cls
echo:
echo Changing the Current Edition [%osedition%] to [%targetedition%]
echo:
echo Applying the command with %pkeychannel% Key
echo DISM /online /Set-Edition:%targetedition% /ProductKey:%key% /AcceptEula
DISM /online /Set-Edition:%targetedition% /ProductKey:%key% /AcceptEula

call :dk_color %Magenta% "Make sure to restart the system."

::========================================================================================================================================

:ced_done

echo:
call :dk_color %_Yellow% "Press any key to %_exitmsg%..."
pause >nul
exit /b

::========================================================================================================================================

:ced_windowskey

for %%# in (pkeyhelper.dll) do @if "%%~$PATH:#"=="" exit /b
for %%# in (%keyflow%) do (
call :dk_pkey %targetSKU% '%%#'
if defined pkey call :dk_pkeychannel !pkey!
if /i [!pkeychannel!]==[%%#] (
set key=!pkey!
exit /b
)
)
exit /b

::========================================================================================================================================

:ced_targetSKU

set k=%1
set targetSKU=
for %%# in (pkeyhelper.dll) do @if "%%~$PATH:#"=="" exit /b

call :dk_reflection

set d1=%ref% [void]$TypeBuilder.DefinePInvokeMethod('GetEditionIdFromName', 'pkeyhelper.dll', 'Public, Static', 1, [int], @([String], [int].MakeByRefType()), 1, 3);
set d1=%d1% $out = 0; [void]$TypeBuilder.CreateType()::GetEditionIdFromName('%k%', [ref]$out); $out

for /f %%a in ('%psc% "%d1%"') do if not errorlevel 1 (set targetSKU=%%a)
if "%targetSKU%"=="0" set targetSKU=
exit /b

::========================================================================================================================================

::  

:cbsxml:[
param (
    [Parameter()]
    [String]$SetEdition,

    [Parameter()]
    [Switch]$GetTargetEditions,

    [Parameter()]
    [Switch]$StageCurrent
)

function Get-AssemblyIdentity {
    param (
        [String]$PackageName
    )

    $PackageName = [String]$PackageName
    $packageData = ($PackageName -split '~')

    if($packageData[3] -eq '') {
        $packageData[3] = 'neutral'
    }

    return "<assemblyIdentity name=`"$($packageData[0])`" version=`"$($packageData[4])`" processorArchitecture=`"$($packageData[2])`" publicKeyToken=`"$($packageData[1])`" language=`"$($packageData[3])`" />"
}

function Get-SxsName {
    param (
        [String]$PackageName
    )

    $name = ($PackageName -replace '[^A-z0-9\-\._]', '')

    if($name.Length -gt 40) {
        $name = ($name[0..18] -join '') + '\.\.' + ($name[-19..-1] -join '')
    }

    return $name.ToLower()
}

function Find-EditionXmlInSxs {
    param (
        [String]$Edition
    )

    $candidates = @($Edition, 'Client', 'Server')
    $winSxs = $Env:SystemRoot + '\WinSxS'
    $allInSxs = Get-ChildItem -Path $winSxs | select Name

    foreach($candidate in $candidates) {
        $name = Get-SxsName -PackageName "Microsoft-Windows-Editions-$candidate"
        $packages = $allInSxs | where name -Match ('^.*_'+$name+'_31bf3856ad364e35')

        if($packages.Length -eq 0) {
            continue
        }

        $package = $packages[-1].Name
        $testPath = $winSxs + "\$package\" + $Edition + 'Edition.xml'

        if(Test-Path -Path $testPath -PathType Leaf) {
            return $testPath
        }
    }

    return $null
}

function Find-EditionXml {
    param (
        [String]$Edition
    )

    $servicingEditions = $Env:SystemRoot + '\servicing\Editions'
    $editionXml = $Edition + 'Edition.xml'

    $editionXmlInServicing = $servicingEditions + '\' + $editionXml

    if(Test-Path -Path $editionXmlInServicing -PathType Leaf) {
        return $editionXmlInServicing
    }

    return Find-EditionXmlInSxs -Edition $Edition
}

function Write-UpgradeCandidates {
    param (
        [HashTable]$InstallCandidates
    )

    $editionCount = 0
    Write-Host 'Editions that can be upgraded to:'
    foreach($candidate in $InstallCandidates.Keys) {
        Write-Host "Target Edition : $candidate"
        $editionCount++
    }

    if($editionCount -eq 0) {
        Write-Host '(no editions are available)'
    }
}

function Write-UpgradeXml {
    param (
        [Array]$RemovalCandidates,
        [Array]$InstallCandidates,
        [Boolean]$Stage
    )

    $removeAction = 'remove'
    if($Stage) {
        $removeAction = 'stage'
    }

    Write-Output '<?xml version="1.0"?>'
    Write-Output '<unattend xmlns="urn:schemas-microsoft-com:unattend">'
    Write-Output '<servicing>'

    foreach($package in $InstallCandidates) {
        Write-Output '<package action="install">'
        Write-Output (Get-AssemblyIdentity -PackageName $package)
        Write-Output '</package>'
    }

    foreach($package in $RemovalCandidates) {
        Write-Output "<package action=`"$removeAction`">"
        Write-Output (Get-AssemblyIdentity -PackageName $package)
        Write-Output '</package>'
    }

    Write-Output '</servicing>'
    Write-Output '</unattend>'
}

function Write-Usage {
    Get-Help $script:MyInvocation.MyCommand.Path -detailed
}

$version = '1.0'
$getTargetsParam = $GetTargetEditions.IsPresent
$stageCurrentParam = $StageCurrent.IsPresent

if($SetEdition -eq '' -and ($false -eq $getTargetsParam)) {
    Write-Usage
    Exit 1
}

$removalCandidates = @();
$installCandidates = @{};

$packages = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages' | select Name | where { $_.name -match '^.*\\Microsoft-Windows-.*Edition~' }
foreach($package in $packages) {
    $state = (Get-ItemProperty -Path "Registry::$($package.Name)").CurrentState
    $packageName = ($package.Name -split '\\')[-1]
    $packageEdition = (($packageName -split 'Edition~')[0] -split 'Microsoft-Windows-')[-1]

    if($state -eq 0x40) {
        if($null -eq $installCandidates[$packageEdition]) {
            $installCandidates[$packageEdition] = @()
        }

        if($false -eq ($installCandidates[$packageEdition] -contains $packageName)) {
            $installCandidates[$packageEdition] = $installCandidates[$packageEdition] + @($packageName)
        }
    }

    if((($state -eq 0x50) -or ($state -eq 0x70)) -and ($false -eq ($removalCandidates -contains $packageName))) {
        $removalCandidates = $removalCandidates + @($packageName)
    }
}

if($getTargetsParam) {
    Write-UpgradeCandidates -InstallCandidates $installCandidates
    Exit
}

if($false -eq ($installCandidates.Keys -contains $SetEdition)) {
    Write-Error "The system cannot be upgraded to `"$SetEdition`""
    Exit 1
}

$xmlPath = $Env:SystemRoot + '\Temp' + '\CbsUpgrade.xml'

Write-UpgradeXml -RemovalCandidates $removalCandidates `
    -InstallCandidates $installCandidates[$SetEdition] `
    -Stage $stageCurrentParam >$xmlPath

$editionXml = Find-EditionXml -Edition $SetEdition
if($null -eq $editionXml) {
    Write-Warning 'Unable to find edition specific settings XML. Proceeding without it...'
}

Write-Host 'Starting the upgrade process. This may take a while...'

DISM.EXE /English /NoRestart /Online /Apply-Unattend:$xmlPath
$dismError = $LASTEXITCODE

Remove-Item -Path $xmlPath -Force

if(($dismError -ne 0) -and ($dismError -ne 3010)) {
    Write-Error 'Failed to upgrade to the target edition'
    Exit $dismError
}

if($null -ne $editionXml) {
    $destination = $Env:SystemRoot + '\' + $SetEdition + '.xml'
    Copy-Item -Path $editionXml -Destination $destination

    DISM.EXE /English /NoRestart /Online /Apply-Unattend:$editionXml
    $dismError = $LASTEXITCODE

    if(($dismError -ne 0) -and ($dismError -ne 3010)) {
        Write-Error 'Failed to apply edition specific settings'
        Exit $dismError
    }
}

Restart-Computer
:cbsxml:]

::========================================================================================================================================

::  1st column = Generic Retail/OEM/MAK/GVLK Key
::  2nd column = Key Type
::  3rd column = WMI Edition ID
::  4th column = Version name incase same Edition ID is used in different OS versions with different key
::  Separator  = _

::  Key preference is in the following order. Retail > Volume:MAK > Volume:GVLK > OEM:NONSLP > OEM:DM
::  OEM keys are in last because they can't be used in edition change if "changepk /productkey" method is needed instead of "slmgr /ipk"
::  OEM keys are listed here because we don't have other keys for that edition

:changeeditiondata

set h=
for %%# in (
44N%h%YX-TK%h%R9D-CCM2%h%D-V6%h%B8F-HQ%h%WWR__Volume:MAK_Enterprise
D6R%h%D9-D4%h%N8T-RT9Q%h%X-YW%h%6YT-FC%h%WWJ______Retail_Starter
3V6%h%Q6-NQ%h%XCX-V8YX%h%R-9Q%h%CYV-QP%h%FCT__Volume:MAK_EnterpriseN
3NF%h%XW-2T%h%27M-2BDW%h%6-4G%h%HRV-68%h%XRX______Retail_StarterN
VK7%h%JG-NP%h%HTM-C97J%h%M-9M%h%PGT-3V%h%66T______Retail_Professional
2B8%h%7N-8K%h%FHP-DKV6%h%R-Y2%h%C8J-PK%h%CKT______Retail_ProfessionalN
4CP%h%RK-NM%h%3K3-X6XX%h%Q-RX%h%X86-WX%h%CHW______Retail_CoreN
N24%h%34-X9%h%D7W-8PF6%h%X-8D%h%V9T-8T%h%YMD______Retail_CoreCountrySpecific
BT7%h%9Q-G7%h%N6G-PGBY%h%W-4Y%h%WX6-6F%h%4BT______Retail_CoreSingleLanguage
YTM%h%G3-N6%h%DKC-DKB7%h%7-7M%h%9GH-8H%h%VX7______Retail_Core
XKC%h%NC-J2%h%6Q9-KFHD%h%2-FK%h%THY-KD%h%72Y__OEM:NONSLP_PPIPro
YNM%h%GQ-8R%h%YV3-4PGQ%h%3-C8%h%XTP-7C%h%FBY______Retail_Education
84N%h%GF-MH%h%BT6-FXBX%h%8-QW%h%JK7-DR%h%R8H______Retail_EducationN
KCN%h%VH-YK%h%WX8-GJJB%h%9-H9%h%FDT-6F%h%7W2__Volume:MAK_EnterpriseS_VB
VBX%h%36-N7%h%DDY-M9H6%h%2-83%h%BMJ-CP%h%R42__Volume:MAK_EnterpriseS_RS5
PN3%h%KR-JX%h%M7T-46HM%h%4-MC%h%QGK-7X%h%PJQ__Volume:MAK_EnterpriseS_RS1
DVW%h%KN-3G%h%CMV-Q2XF%h%4-DD%h%PGM-VQ%h%WWY__Volume:MAK_EnterpriseS_TH
RQF%h%NW-9T%h%PM3-JQ73%h%T-QV%h%4VQ-DV%h%9PT__Volume:MAK_EnterpriseSN_VB
M33%h%WV-NH%h%Y3C-R7FP%h%M-BQ%h%GPT-23%h%9PG__Volume:MAK_EnterpriseSN_RS5
2DB%h%W3-N2%h%PJG-MVHW%h%3-G7%h%TDK-9H%h%KR4__Volume:MAK_EnterpriseSN_RS1
NTX%h%6B-BR%h%YC2-K678%h%6-F6%h%MVQ-M7%h%V2X__Volume:MAK_EnterpriseSN_TH
G3K%h%NM-CH%h%G6T-R36X%h%3-9Q%h%DG6-8M%h%8K9______Retail_ProfessionalSingleLanguage
HNG%h%CC-Y3%h%8KG-QVK8%h%D-WM%h%WRK-X8%h%6VK______Retail_ProfessionalCountrySpecific
DXG%h%7C-N3%h%6C4-C4HT%h%G-X4%h%T3X-2Y%h%V77______Retail_ProfessionalWorkstation
WYP%h%NQ-8C%h%467-V2W6%h%J-TX%h%4WX-WT%h%2RQ______Retail_ProfessionalWorkstationN
8PT%h%T6-RN%h%W4C-6V7J%h%2-C2%h%D3X-MH%h%BPB______Retail_ProfessionalEducation
GJT%h%YN-HD%h%MQY-FRR7%h%6-HV%h%GC7-QP%h%F8P______Retail_ProfessionalEducationN
C4N%h%TJ-CX%h%6Q2-VXDM%h%R-XV%h%KGM-F9%h%DJC__Volume:MAK_EnterpriseG
46P%h%N6-R9%h%BK9-CVHK%h%B-HW%h%Q9V-MB%h%JY8__Volume:MAK_EnterpriseGN
NJC%h%F7-PW%h%8QT-3324%h%D-68%h%8JX-2Y%h%V66______Retail_ServerRdsh
V3W%h%VW-N2%h%PV2-CGWC%h%3-34%h%QGF-VM%h%J2C______Retail_Cloud
NH9%h%J3-68%h%WK7-6FB9%h%3-4K%h%3DF-DJ%h%4F6______Retail_CloudN
2HN%h%6V-HG%h%TM8-6C97%h%C-RK%h%67V-JQ%h%PFD______Retail_CloudE
XQQ%h%YW-NF%h%FMW-XJPB%h%H-K8%h%732-CK%h%FFD______OEM:DM_IoTEnterprise
QPM%h%6N-7J%h%2WJ-P88H%h%H-P3%h%YRH-YY%h%74H__OEM:NONSLP_IoTEnterpriseS_VB
KBN%h%8V-HF%h%GQ4-MGXV%h%D-34%h%7P6-PD%h%QGT_Volume:GVLK_IoTEnterpriseS_NI
K9V%h%KN-3B%h%GWV-Y624%h%W-MC%h%RMQ-BH%h%DCD______Retail_CloudEditionN
KY7%h%PN-VR%h%6RX-83W6%h%Y-6D%h%DYQ-T6%h%R4W______Retail_CloudEdition
MPB%h%3G-XN%h%BR7-CC43%h%M-FG%h%64B-F9%h%GBK______Retail_IoTEnterpriseSK
) do (
for /f "tokens=1-4 delims=_" %%A in ("%%#") do if /i %targetedition%==%%C (

if not defined key (
set 4th=%%D
if not defined 4th (
set "key=%%A" & set "_chan=%%B"
) else (
echo "%branch%" | find "%%D" 1>nul && (set "key=%%A" & set "_chan=%%B")
)
)
)
)
exit /b

::========================================================================================================================================

:changeeditionserverdata

if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-Server*CorEdition~*.mum" (set Cor=Cor) else (set Cor=)

::  Only RS3 and older version keys (GVLK/Generic Retail) are stored here, later ones are extracted from the system itself

set h=
for %%# in (
WC2%h%BQ-8N%h%RM3-FDD%h%YY-2B%h%FGV-KHK%h%QY_RS1_ServerStandard%Cor%
CB7%h%KF-BW%h%N84-R7R%h%2Y-79%h%3K2-8XD%h%DG_RS1_ServerDatacenter%Cor%
JCK%h%RF-N3%h%7P4-C2D%h%82-9Y%h%XRT-4M6%h%3B_RS1_ServerSolution
QN4%h%C6-GB%h%JD2-FB4%h%22-GH%h%WJK-GJG%h%2R_RS1_ServerCloudStorage
VP3%h%4G-4N%h%PPG-79J%h%TQ-86%h%4T4-R3M%h%QX_RS1_ServerAzureCor
9JQ%h%NQ-V8%h%HQ6-PKB%h%8H-GG%h%HRY-R62%h%H6_RS1_ServerAzureNano
VN8%h%D3-PR%h%82H-DB6%h%BJ-J9%h%P4M-92F%h%6J_RS1_ServerStorageStandard
48T%h%QX-NV%h%K3R-D8Q%h%R3-GT%h%HHM-8FH%h%XC_RS1_ServerStorageWorkgroup
2HX%h%DN-KR%h%XHB-GPY%h%C7-YC%h%KFJ-7FV%h%DG_RS3_ServerDatacenterACor
PTX%h%N8-JF%h%HJM-4WC%h%78-MP%h%CBR-9W4%h%KR_RS3_ServerStandardACor
) do (
for /f "tokens=1-3 delims=_" %%A in ("%%#") do if /i %targetedition%==%%C (
echo "%branch%" | find /i "%%B" 1>nul && (set "key=%%A")
)
)
exit /b

:+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

:MASend
echo:
if defined _MASunattended timeout /t 2 & exit /b
echo Press any key to exit...
pause >nul
exit /b

::End::