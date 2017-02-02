@echo off
setlocal enabledelayedexpansion
mode con:cols=100 lines=4
SET BATCHPATH=%~dp0
set IP=8.8.8.8
set TIMEOUT=300
set TTL=300
set LOGFILE=pingtest.log

cls
echo PING TEST IN PROGRESS
echo Failed pings logged in:%BATCHPATH%%LOGFILE%
echo (To terminate press ctrl c)
:loop
set pingline=1
for /f "delims=" %%A in ('ping -n 1 -w %TIMEOUT% -l %TTL% %IP%') do (
	if !pingline! equ 2 (
		set logline=!date! !time! "%%A"
		echo !logline! | find "TTL=">nul || echo !logline! >> %LOGFILE%
		)
	set /a pingline+=1
	)
goto loop
exit
