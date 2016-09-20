@ECHO OFF
CD /D %~DP0

SET AppName=迅雷下载
SET AppExec=Thunder.exe
SET AppDir=%~DP0Program\
SET AppArgs=
ECHO 创建快捷方式：%AppName%
MSHTA VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""AllUsersPrograms"") & ""\%AppName%.lnk""):b.TargetPath=""%AppDir%%AppExec%"":b.WorkingDirectory=""%AppDir%"":b.Arguments=""%AppArgs%"":b.Save:close")

REG ADD "HKLM\SOFTWARE\Thunder Network\Xmp" /v storepath /d "%~DP0KanKan" /f

CALL 安装卸载.bat 1 2
