@echo off

SET VERSIONTAG=RC4

SET VCVARSALL="%ProgramFiles(x86)%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"
SET DEVENV="devenv.exe"
SET MAKENSIS="%ProgramFiles(x86)%\NSIS\Unicode\makensis.exe"
SET RAR="%ProgramFiles%\WinRAR\WinRAR.exe"

call %VCVARSALL% x86 > NUL 2>&1

rmdir /s /q "%~dp0\mRemoteV1\bin" > NUL 2>&1
rmdir /s /q "%~dp0\mRemoteV1\obj" > NUL 2>&1

echo Building release version...
%DEVENV% "%~dp0\mRemoteV1.sln" /build "Release"

echo Building portable version...
%DEVENV% "%~dp0\mRemoteV1.sln" /build "Release Portable"

mkdir "%~dp0\Release"

echo Getting product version...
%MAKENSIS% "%~dp0\Installer\GetVersion.nsi"
"%~dp0\Release\GetVersion.exe"
call "%~dp0\Release\Version.cmd"

echo Creating installer package...
if defined VERSIONTAG (
	%MAKENSIS% /DPRODUCT_VERSION_TAG=%VERSIONTAG% "%~dp0\Installer\mRemote.nsi"

	set BINARYZIP="%~dp0\Release\mRemoteNG-%PRODUCT_VERSION_SHORT%-%VERSIONTAG%.zip"
	set PORTABLEZIP="%~dp0\Release\mRemoteNG-Portable-%PRODUCT_VERSION_SHORT%-%VERSIONTAG%.zip"
) else (
	%MAKENSIS% "%~dp0\Installer\mRemote.nsi"

	set BINARYZIP="%~dp0\Release\mRemoteNG-%PRODUCT_VERSION_SHORT%.zip"
	set PORTABLEZIP="%~dp0\Release\mRemoteNG-Portable-%PRODUCT_VERSION_SHORT%.zip"
)

echo Creating release ZIP file...
del /f /q %BINARYZIP% > NUL 2>&1
%RAR% a -m5 -r -ep1 -afzip -inul %BINARYZIP% "%~dp0\mRemoteV1\bin\Release\*.*"
%RAR% a -m5 -r -ep1 -afzip -inul %BINARYZIP% "%~dp0\Installer\Dependencies\*.*"
%RAR% a -m5 -ep -afzip -inul %BINARYZIP% "%~dp0\*.TXT"

echo Creating portable ZIP file...
del /f /q %PORTABLEZIP% > NUL 2>&1
%RAR% a -m5 -r -ep1 -afzip -inul %PORTABLEZIP% "%~dp0\mRemoteV1\bin\Release Portable\*.*"
%RAR% a -m5 -r -ep1 -afzip -inul %PORTABLEZIP% "%~dp0\Installer\Dependencies\*.*"
%RAR% a -m5 -ep -afzip -inul %PORTABLEZIP% "%~dp0\*.TXT"
