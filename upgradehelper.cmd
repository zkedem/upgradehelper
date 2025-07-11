<?xml : version="1.0" encoding="UTF-8"?> ^<!-- Batch file section
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
IF "%~1" == "/?" (
	ECHO Applies registry changes to allow upgrading to Windows 11 and installing 1>&2
	ECHO updates on unsupported systems. 1>&2
	ECHO. 1>&2
	ECHO %0 [/S Schedule ^| /R ^| /U] 1>&2
	ECHO. 1>&2
	ECHO     /S Schedule  Set to run on one of the following schedules: 1>&2
	ECHO. 1>&2
	ECHO     ONSTART      Whenever the system starts up. 1>&2
	ECHO     ONLOGON      Whenever a user logs on. 1>&2
	ECHO     ONUPDATE     Each time after Windows updates are installed. 1>&2
	ECHO. 1>&2
	ECHO     /R           Remove from scheduled tasks. 1>&2
	ECHO     /U           Undo registry changes. 1>&2
) ELSE IF "%~1" == "/U" (
	CALL :elevateself %*
	reg DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /f /v HwReqChkVars 1>NUL 2>NUL
	reg DELETE "HKLM\SYSTEM\Setup\MoSetup" /f /v AllowUpgradesWithUnsupportedTPMOrCPU 1>NUL 2>NUL
	(CALL )
	ECHO Undid changes to registry. 1>&2
) ELSE IF "%~1" == "/R" (
	CALL :elevateself %*
	IF NOT "%~f0" == "%SystemDrive%\%~nx0" DEL "%SystemDrive%\%~nx0" 1>NUL 2>NUL
	schtasks /Delete /TN "%~n0" /F 1>NUL 2>NUL
	ECHO Removed "%~n0" from scheduled tasks. 1>&2
) ELSE IF "%~1" == "/S" (
	CALL :elevateself %*
	SET "schedule=%2"
	SET "schedule=!schedule:ONUPDATE=ONEVENT /MO "*[System[Provider[@Name='Microsoft-Windows-WindowsUpdateClient'] and EventID=19]]^" /EC System!"
	IF NOT "%~f0" == "%SystemDrive%\%~nx0" COPY /Y "%~f0" "%SystemDrive%\%~nx0" 1>NUL 2>NUL
	schtasks /Create /SC !schedule! /TN "%~n0" /TR "'%SystemDrive%\%~nx0'" /F 1>NUL 2>NUL
	ECHO Added "%~n0" to scheduled tasks. 1>&2
) ELSE IF "%~1" == "" (
	CALL :elevateself %*
	reg DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" /f 1>NUL 2>NUL
	reg DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" /f 1>NUL 2>NUL
	reg DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" /f 1>NUL 2>NUL
	reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /f /v HwReqChkVars /t REG_MULTI_SZ /s , /d "SQ_SecureBootCapable=TRUE,SQ_SecureBootEnabled=TRUE,SQ_TpmVersion=2,SQ_RamMB=8192," 1>NUL 2>NUL
	reg ADD "HKLM\SYSTEM\Setup\MoSetup" /f /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 1>NUL 2>NUL
	(CALL )
	ECHO Applied changes to registry. 1>&2
) ELSE (
	ECHO Invalid arguments -- %* 1>&2
	ECHO Run %0 /? for usage information. 1>&2
	(CALL)
)
ENDLOCAL
GOTO :EOF
:elevateself
net SESSION 1>NUL 2>NUL
IF ERRORLEVEL 1 (
	cscript /Nologo "%~f0?.wsf" /V:runas "%~f0" %*
	(GOTO) 2>NUL || EXIT /B 0
)
EXIT /B 1
-->
<!-- Windows script file section -->
<job>
	<script language="JScript">
		<![CDATA[
		var shell = new ActiveXObject("Shell.Application");
		var application = null;
		var parameters = "";
		var verb = "";
		for (var e = new Enumerator(WScript.Arguments), o = false; !e.atEnd(); e.moveNext()) {
			var argument = e.item();
			if (!o) {
				if (argument.substring(0, "/V:".length) == "/V:") {
					verb = argument.replace("/V:", "").replace(/^"|"$/g, "");
				} else {
					o = true;
				}
			}
			if (o) {
				if (application == null) {
					application = argument;
				} else {
					parameters = (parameters + " " + argument).replace(/^ +/g, "");
				}
			}
		}
		if (application != null) {
			shell.ShellExecute(application, parameters, "", verb, 1);
		}
		]]>
	</script>
</job>