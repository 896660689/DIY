@ECHO OFF
CD /D %~DP0

SET AppName=Ѹ������
SET AppExec=Thunder.exe
SET AppDir=%~DP0Program\
SET AppArgs=
ECHO ������ݷ�ʽ��%AppName%
MSHTA VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""AllUsersPrograms"") & ""\%AppName%.lnk""):b.TargetPath=""%AppDir%%AppExec%"":b.WorkingDirectory=""%AppDir%"":b.Arguments=""%AppArgs%"":b.Save:close")

REG ADD "HKLM\SOFTWARE\Thunder Network\Xmp" /v storepath /d "%~DP0KanKan" /f

CALL ��װж��.bat 1 2
