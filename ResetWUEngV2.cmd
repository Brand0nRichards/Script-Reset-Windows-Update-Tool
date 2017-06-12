:: ==================================================================================
:: NAME:	Reset Windows Update Tool.
:: DESCRIPTION:	This script reset the Windows Update Components.
:: AUTHOR:	Manuel Gil.
:: EDITED BY:	Brandon Richards
:: VERSION:	10.5.3.2
:: NOTES: Thanks Manuel, I've edited this for use at work.
:: ==================================================================================


:: Set console.
:: void mode();
:: /************************************************************************************/
:mode
	echo off
	title Reset Windows Update Tool.
	mode con cols=78 lines=32
	color 17
	cls

	goto getValues
goto :eof
:: /************************************************************************************/


:: Print Top Text.
::		@param - text = the text to print (%*).
:: void print(string text);
:: /*************************************************************************************/
:print
	cls
	echo.
	echo.%name% [Version: %version%]
	echo.Reset Windows Update Tool.
	echo.
	echo.%*
	echo.
goto :eof
:: /*************************************************************************************/


:: Add Value in the Registry.
::		@param - key = the key or entry to be added (%~1).
::				value = the value to be added under the selected key (%~2).
::				type = the type for the registry entry (%~3).
::				data = the data for the new registry entry (%~4).
:: void addReg(string key, string value, string type, string data);
:: /*************************************************************************************/
:addReg
	reg add "%~1" /v "%~2" /t "%~3" /d "%~4" /f
goto :eof
:: /*************************************************************************************/


:: Load the system values.
:: void getValues();
:: /************************************************************************************/
:getValues
	for /f "tokens=4-5 delims=[] " %%a in ('ver') do set version=%%a%%b
	for %%a in (%version%) do set version=%%a

	) else if %version% EQU 10.0.10240 (
		:: Name: "Microsoft Windows 10 Threshold 1"
		set name=Microsoft Windows 10 Threshold 1
		:: Family: Windows 10
		set family=10
		:: Compatibility: Yes
		set allow=Yes
	) else if %version% EQU 10.0.10586 (
		:: Name: "Microsoft Windows 10 Threshold 2"
		set name=Microsoft Windows 10 Threshold 2
		:: Family: Windows 10
		set family=10
		:: Compatibility: Yes
		set allow=Yes
	) else if %version% EQU 10.0.14393 (
		:: Name: "Microsoft Windows 10 Redstone 1"
		set name=Microsoft Windows 10 Redstone 1
		:: Family: Windows 10
		set family=10
		:: Compatibility: Yes
		set allow=Yes
	) else if %version% EQU 10.0.15063 (
		:: Name: "Microsoft Windows 10 Creators Update"
		set name=Microsoft Windows 10 Creators Update
		:: Family: Windows 10
		set family=10
		:: Compatibility: Yes
		set allow=Yes
	) else (
		:: Name: "Unknown"
		set name=Unknown
		:: Compatibility: No
		set allow=No
	)

	call :print %name% detected . . .

	if %allow% EQU Yes goto permission

	call :print Sorry, this Operative System is not compatible with this tool.

	echo.    An error occurred while attempting to verify your system.
	echo.    Can this using a business or test version.
	echo.
	echo.    If not, verify that your system has the correct security fix.
	echo.

	echo.Press any key to continue . . .
	pause>nul
goto :eof
:: /************************************************************************************/


:: Checking for Administrator elevation.
:: void permission();
:: /************************************************************************************/
:permission
	openfiles>nul 2>&1

	if %errorlevel% EQU 0 goto terms

	call :print Checking for Administrator elevation.

	echo.    You are not running as Administrator.
	echo.    This tool cannot do it's job without elevation.
	echo.
	echo.    You need run this tool as Administrator.
	echo.

	echo.Press any key to continue . . .
	pause>nul
goto :eof
:: /************************************************************************************/


:: Terms.
:: void terms();
:: /*************************************************************************************/
:terms
	call :print Terms and Conditions of Use.

	echo.    The methods inside this tool modify files and registry settings.
	echo.    While you are tested and tend to work, We not take responsibility for
	echo.    the use of this tool.
	echo.
	echo.    This tool is provided without warranty. Any damage caused is your
	echo.    own responsibility.
	echo.
	echo.    As well, batch files are almost always flagged by anti-virus, feel free
	echo.    to review the code if you're unsure.
	echo.

	choice /c YN /n /m "Do you want to continue with this process? (Yes/No) "
	if %errorlevel% EQU 1 goto menu
	if %errorlevel% EQU 2 goto close

	echo.An unexpected error has occurred.
	echo.
	echo.Press any key to continue . . .
	pause>nul

	goto menu
goto :eof
:: /*************************************************************************************/

:: Menu of tool.
:: void menu();
:: /*************************************************************************************/
:menu
	call :print This tool reset the Windows Update Components.

	echo.    1. Reset Windows Update Components.
	echo.    2. Scans all protected system files.
	echo.    3. Clean up the superseded components.
	echo.    4. Change invalid values in the Registry.
	echo.    5. Reset the Winsock settings.
	echo.    6. Search updates.
	echo.
	echo.                                            ?. Help.    0. Close.
	echo.

	set /p option=Select an option:

	if %option% EQU 0 (
		goto close
	) else if %option% EQU 1 (
		call :components
	) else if %option% EQU 2 (
		call :sfc
	) else if %option% EQU 3 (
		call :dism4
	) else if %option% EQU 4 (
		call :regedit
	) else if %option% EQU 5 (
		call :winsock
	) else if %option% EQU 6 (
		call :updates
	) else if %option% EQU ? (
		call :help
	) else (
		echo.
		echo.Invalid option.
		echo.
		echo.Press any key to continue . . .
		pause>nul
	)

	goto menu
goto :eof
:: /*************************************************************************************/

:: Run the reset Windows Update components.
:: void components();
:: /*************************************************************************************/
:components
	:: ----- Stopping the Windows Update services -----
	call :print Stopping the Windows Update services.
	net stop bits

	call :print Stopping the Windows Update services.
	net stop wuauserv

	call :print Stopping the Windows Update services.
	net stop appidsvc

	call :print Stopping the Windows Update services.
	net stop cryptsvc

	:: ----- Checking the services status -----
	call :print Checking the services status.

	sc query bits | findstr /I /C:"STOPPED"
	If %errorlevel% NEQ 0 (
		echo.    Failed to stop the BITS service.
		echo.
		echo.Press any key to continue . . .
		pause>nul
		goto close
	)

	call :print Checking the services status.

	sc query wuauserv | findstr /I /C:"STOPPED"
	if %errorlevel% NEQ 0 (
		echo.    Failed to stop the Windows Update service.
		echo.
		echo.Press any key to continue . . .
		pause>nul
		goto close
	)

	call :print Checking the services status.

	sc query appidsvc | findstr /I /C:"STOPPED"
	if %errorlevel% NEQ 0 (
		sc query appidsvc | findstr /I /C:"OpenService FAILED 1060"
		if %errorlevel% NEQ 0 (
			echo.    Failed to stop the Application Identity service.
			echo.
			echo.Press any key to continue . . .
			pause>nul
			if %family% NEQ 6 goto close
		)
	)

	call :print Checking the services status.

	sc query cryptsvc | findstr /I /C:"STOPPED"
	If %errorlevel% NEQ 0 (
		echo.    Failed to stop the Cryptographic Services service.
		echo.
		echo.Press any key to continue . . .
		pause>nul
		goto close
	)

	:: ----- Delete the qmgr*.dat files -----
	call :print Deleting the qmgr*.dat files.

	del /s /q /f "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
	del /s /q /f "%ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat"

	:: ----- Renaming the softare distribution folders backup copies -----
	call :print Deleting the old software distribution backup copies.

	cd /d %SYSTEMROOT%

	if exist "%SYSTEMROOT%\winsxs\pending.xml.bak" (
		del /s /q /f "%SYSTEMROOT%\winsxs\pending.xml.bak"
	)
	if exist "%SYSTEMROOT%\SoftwareDistribution.bak" (
		rmdir /s /q "%SYSTEMROOT%\SoftwareDistribution.bak"
	)
	if exist "%SYSTEMROOT%\system32\Catroot2.bak" (
		rmdir /s /q "%SYSTEMROOT%\system32\Catroot2.bak"
	)
	if exist "%SYSTEMROOT%\WindowsUpdate.log.bak" (
		del /s /q /f "%SYSTEMROOT%\WindowsUpdate.log.bak"
	)

	call :print Renaming the software distribution folders.

	if exist "%SYSTEMROOT%\winsxs\pending.xml" (
		takeown /f "%SYSTEMROOT%\winsxs\pending.xml"
		attrib -r -s -h /s /d "%SYSTEMROOT%\winsxs\pending.xml"
		ren "%SYSTEMROOT%\winsxs\pending.xml" pending.xml.bak
	)
	if exist "%SYSTEMROOT%\SoftwareDistribution" (
		attrib -r -s -h /s /d "%SYSTEMROOT%\SoftwareDistribution"
		ren "%SYSTEMROOT%\SoftwareDistribution" SoftwareDistribution.bak
	)
	if exist "%SYSTEMROOT%\system32\Catroot2" (
		attrib -r -s -h /s /d "%SYSTEMROOT%\system32\Catroot2"
		ren "%SYSTEMROOT%\system32\Catroot2" Catroot2.bak
	)
	if exist "%SYSTEMROOT%\WindowsUpdate.log" (
		attrib -r -s -h /s /d "%SYSTEMROOT%\WindowsUpdate.log"
		ren "%SYSTEMROOT%\WindowsUpdate.log" WindowsUpdate.log.bak
	)

	:: ----- Reset the BITS service and the Windows Update service to the default security descriptor -----
	call :print Reset the BITS service and the Windows Update service to the default security descriptor.

	sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
	sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)

	:: ----- Reregister the BITS files and the Windows Update files -----
	call :print Reregister the BITS files and the Windows Update files.

	cd /d %WINDIR%\system32
	regsvr32.exe /s atl.dll
	regsvr32.exe /s urlmon.dll
	regsvr32.exe /s mshtml.dll
	regsvr32.exe /s shdocvw.dll
	regsvr32.exe /s browseui.dll
	regsvr32.exe /s jscript.dll
	regsvr32.exe /s vbscript.dll
	regsvr32.exe /s scrrun.dll
	regsvr32.exe /s msxml.dll
	regsvr32.exe /s msxml3.dll
	regsvr32.exe /s msxml6.dll
	regsvr32.exe /s actxprxy.dll
	regsvr32.exe /s softpub.dll
	regsvr32.exe /s wintrust.dll
	regsvr32.exe /s dssenh.dll
	regsvr32.exe /s rsaenh.dll
	regsvr32.exe /s gpkcsp.dll
	regsvr32.exe /s sccbase.dll
	regsvr32.exe /s slbcsp.dll
	regsvr32.exe /s cryptdlg.dll
	regsvr32.exe /s oleaut32.dll
	regsvr32.exe /s ole32.dll
	regsvr32.exe /s shell32.dll
	regsvr32.exe /s initpki.dll
	regsvr32.exe /s wuapi.dll
	regsvr32.exe /s wuaueng.dll
	regsvr32.exe /s wuaueng1.dll
	regsvr32.exe /s wucltui.dll
	regsvr32.exe /s wups.dll
	regsvr32.exe /s wups2.dll
	regsvr32.exe /s wuweb.dll
	regsvr32.exe /s qmgr.dll
	regsvr32.exe /s qmgrprxy.dll
	regsvr32.exe /s wucltux.dll
	regsvr32.exe /s muweb.dll
	regsvr32.exe /s wuwebv.dll

	:: ----- Resetting Winsock -----
	call :print Resetting Winsock.
	netsh winsock reset

	:: ----- Resetting WinHTTP Proxy -----
	call :print Resetting WinHTTP Proxy.

	if %family% EQU 5 (
		proxycfg.exe -d
	) else (
		netsh winhttp reset proxy
	)

	:: ----- Set the startup type as automatic -----
	call :print Resetting the services as automatics.
	sc config wuauserv start= auto
	sc config bits start= auto
	sc config DcomLaunch start= auto

	:: ----- Starting the Windows Update services -----
	call :print Starting the Windows Update services.
	net start bits

	call :print Starting the Windows Update services.
	net start wuauserv

	call :print Starting the Windows Update services.
	net start appidsvc

	call :print Starting the Windows Update services.
	net start cryptsvc

	call :print Starting the Windows Update services.
	net start DcomLaunch

	:: ----- End process -----
	call :print The operation completed successfully.

	echo.Press any key to continue . . .
	pause>nul
goto :eof
:: /*************************************************************************************/

:: Scans all protected system files.
:: void sfc();
:: /*************************************************************************************/
:sfc
	call :print Scans all protected system files.

	if %family% NEQ 5 (
		sfc /scannow
	) else (
		echo.Sorry, this option is not available on this Operative System.
	)

	If %errorlevel% EQU 0 (
		echo.
		echo.The operation completed successfully.
	) else (
		echo.
		echo.An error occurred during operation.
	)

	echo.
	echo.Press any key to continue . . .
	pause>nul
goto :eof
:: /*************************************************************************************/

:: Clean up the superseded components .
:: void dism4();
:: /*************************************************************************************/
:dism4
	call :print Clean up the superseded components.

	if %family% EQU 8 (
		Dism.exe /Online /Cleanup-Image /StartComponentCleanup
	) else if %family% EQU 10 (
		Dism.exe /Online /Cleanup-Image /StartComponentCleanup
	) else (
		echo.Sorry, this option is not available on this Operative System.
	)

	If %errorlevel% EQU 0 (
		echo.
		echo.The operation completed successfully.
	) else (
		echo.
		echo.An error occurred during operation.
	)

	echo.
	echo.Press any key to continue . . .
	pause>nul
goto :eof
:: /*************************************************************************************/

:: Change invalid values.
:: void regedit();
:: /*************************************************************************************/
:regedit
	for /f "tokens=1-5 delims=/, " %%a in ("%date%") do (
		set now=%%a%%b%%c%%d%time:~0,2%%time:~3,2%
	)

	:: ----- Create a backup of the Registry -----
	call :print Making a backup copy of the Registry in: %USERPROFILE%\Desktop\Backup%now%.reg

	if exist "%USERPROFILE%\Desktop\Backup%now%.reg" (
		echo.An unexpected error has occurred.
		echo.
		echo.    Changes were not carried out in the registry.
		echo.    Will try it later.
		echo.
		echo.Press any key to continue . . .
		pause>nul
		goto :eof
	) else (
		regedit /e "%USERPROFILE%\Desktop\Backup%now%.reg"
	)

	:: ----- Checking backup -----
	call :print Checking the backup copy.

	if not exist "%USERPROFILE%\Desktop\Backup%now%.reg" (
		echo.An unexpected error has occurred.
		echo.
		echo.    Something went wrong.
		echo.    You manually create a backup of the registry before continuing.
		echo.
		echo.Press any key to continue . . .
		pause>nul
	) else (
		echo.The operation completed successfully.
		echo.
	)

	:: ----- Delete keys in the Registry -----
	call :print Deleting values in the Registry.

	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f
	reg delete "HKLM\COMPONENTS\PendingXmlIdentifier" /f
	reg delete "HKLM\COMPONENTS\NextQueueEntryIndex" /f
	reg delete "HKLM\COMPONENTS\AdvancedInstallersNeedResolving" /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" /f

	:: ----- Add keys in the Registry -----
	call :print Adding values in the Registry.

	set key=HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX
	call :addReg "%key%" "IsConvergedUpdateStackEnabled" "REG_DWORD" "0"

	set key=HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings
	call :addReg "%key%" "UxOption" "REG_DWORD" "0"

	set key=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
	call :addReg "%key%" "AppData" "REG_EXPAND_SZ" "%USERPROFILE%\AppData\Roaming"

	set key=HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
	call :addReg "%key%" "AppData" "REG_EXPAND_SZ" "%USERPROFILE%\AppData\Roaming"

	set key=HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
	call :addReg "%key%" "AppData" "REG_EXPAND_SZ" "%USERPROFILE%\AppData\Roaming"

	reg add "HKLM\SYSTEM\CurrentControlSet\Control\BackupRestore\FilesNotToBackup" /f

	reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" /v Security_HKLM_only | find /i "Security_HKLM_Only" | find "1"

	if %errorlevel% EQU 0 (
		set key=HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains
	) else (
		set key=HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains
	)

	call :addReg "%key%\microsoft.com\update" "http" "REG_DWORD" "2"
	call :addReg "%key%\microsoft.com\update" "https" "REG_DWORD" "2"
	call :addReg "%key%\microsoft.com\windowsupdate" "http" "REG_DWORD" "2"
	call :addReg "%key%\update.microsoft.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\update.microsoft.com" "https" "REG_DWORD" "2"
	call :addReg "%key%\windowsupdate.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\windowsupdate.microsoft.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\download.microsoft.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\windowsupdate.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\windowsupdate.com" "https" "REG_DWORD" "2"
	call :addReg "%key%\windowsupdate.com\download" "http" "REG_DWORD" "2"
	call :addReg "%key%\windowsupdate.com\download" "https" "REG_DWORD" "2"
	call :addReg "%key%\download.windowsupdate.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\download.windowsupdate.com" "https" "REG_DWORD" "2"
	call :addReg "%key%\windows.com\wustat" "http" "REG_DWORD" "2"
	call :addReg "%key%\wustat.windows.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\microsoft.com\ntservicepack" "http" "REG_DWORD" "2"
	call :addReg "%key%\ntservicepack.microsoft.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\microsoft.com\ws" "http" "REG_DWORD" "2"
	call :addReg "%key%\microsoft.com\ws" "https" "REG_DWORD" "2"
	call :addReg "%key%\ws.microsoft.com" "http" "REG_DWORD" "2"
	call :addReg "%key%\ws.microsoft.com" "https" "REG_DWORD" "2"

	:: ----- End process -----
	call :print The operation completed successfully.

	echo.Press any key to continue . . .
	pause>nul
goto :eof
:: /*************************************************************************************

:: Reset Winsock setting.
:: void winsock();
:: /*************************************************************************************/
:winsock
	:: ----- Reset Winsock control -----
	call :print Reset Winsock control.

	call :print Restoring transaction logs.
	fsutil resource setautoreset true C:\

	call :print Restoring TPC/IP.
	netsh int ip reset

	call :print Restoring Winsock.
	netsh winsock reset

	call :print Restoring default policy settings.
	netsh advfirewall reset

	call :print Restoring the DNS cache.
	ipconfig /flushdns

	call :print Restoring the Proxy.
	netsh winhttp reset proxy

	:: ----- End process -----
	call :print The operation completed successfully.

	echo.Press any key to continue . . .
	pause>nul
goto :eof
:: /*************************************************************************************/

:: Search Updates.
:: void updates();
:: /*************************************************************************************/
:updates
	call :print Looking for updates.

	echo.Wait . . .
	echo.

	wuauclt /resetauthorization /detectnow

	if %family% EQU 10 (
		start ms-settings:windowsupdate
	) else (
		if %family% NEQ 5 (
			start wuapp.exe
		) else (
			echo.
			echo.An unexpected error has occurred.
			echo.
			echo.Press any key to continue . . .
			pause>nul
		)
	)
goto :eof
:: /*************************************************************************************/

:: End tool.
:: void close();
:: /*************************************************************************************/
:close
	exit
goto :eof
:: /*************************************************************************************/
