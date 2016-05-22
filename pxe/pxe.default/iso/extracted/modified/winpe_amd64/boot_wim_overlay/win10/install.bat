@echo off


rem You must hardcode here your pxe server's IP address into this script
rem Actually it can be any http server but we recommend to use the same host running your PXE boot server
set pxe_server=192.168.69.69


rem We HTTP GET an ASCII text file at the following fixed URL location
rem Can be a php or cgi script if you prefer dynamic configuration
set winpe_config_url=http://%pxe_server%/winpe/win10.config


rem You must also download wget64.exe and copy it into the %PATH% of your mounted boot.wimi file
rem e.g. C:\Windows\wget64.exe
set wget_cmd=wget64.exe



echo.
echo wpeinit: Configuring the windows preinstallation environment...
wpeinit || goto error:
echo Done.
echo.


echo Waiting for network connectivity...
@setlocal enableextensions enabledelayedexpansion
:loop
set state=down
ping -n 1 %pxe_server% | find "TTL=" >nul

if errorlevel 1 (
	set state=down
) else (
	set state=up
)

echo.Link is !state!
if "%state%"=="down" goto :loop
endlocal
echo.



rem Set the list of permitted configuration options
set samba_vars=samba_server samba_share samba_username samba_password
set required_vars=%samba_vars%
set optional_vars=command_prompt



rem Clear the variables
for %%x in (errorlevel %required_vars% %optional_vars%) do (
	rem Clear the variable
	set %%x=
)



echo Loading samba config from %winpe_config_url%:
echo.
for /f "delims=" %%x in ('%wget_cmd% -O - -q %winpe_config_url%') do (
	set "%%x"
	rem Print config values for debugging purposes
	echo set %%x
)
echo.



for %%x in (%required_vars%) do (
	if not defined %%x (
		echo error: the required variable "%%x" was not set
		set errorlevel=1
	)
)


if %errorlevel%==1 (
	echo.
	echo Put: variable=value ^(no spaces or quotes^) in your http://%pxe_server%/winpe_setup.txt
	echo.
	echo required variables: %required_vars%
	echo optional variables: %optional_vars%
	goto :error
)
echo Done.
echo.

goto :net_use

:error
echo Error: the previous step has failed to complete successfully.
echo Dumping to command prompt.
echo.
cmd.exe

echo Continuing...
echo.


:net_use
echo Mounting samba share to drive z:
net use z: \\%samba_server%\%samba_share% %samba_password% /user:%samba_username% || goto :error
z:


echo Command to run:
echo z:\setup.exe
echo.



if defined command_prompt (
	echo Not launching setup.exe.
	goto :command_prompt
)


echo Loading...
.\setup.exe
echo.


:command_prompt
echo Fallen through.
echo.
cmd.exe








