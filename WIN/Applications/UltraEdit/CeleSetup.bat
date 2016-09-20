@ECHO OFF
CD /D %~DP0

SET AppName=文本编辑器
SET AppExec=uedit32.exe
SET AppDir=%~DP0
SET AppArgs=
ECHO 创建快捷方式：%AppName%
MSHTA VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""AllUsersPrograms"") & ""\%AppName%.lnk""):b.TargetPath=""%AppDir%%AppExec%"":b.WorkingDirectory=""%AppDir%"":b.Arguments=""%AppArgs%"":b.Save:close")


IF EXIST %windir%\SysWOW64 (
REG ADD HKCR\CLSID\{b5eedee0-c06e-11cf-8c56-444553540000}\InProcServer32 /ve /d "%~DP0ue64ctmn.dll" /f
) ELSE (
REG ADD HKCR\CLSID\{b5eedee0-c06e-11cf-8c56-444553540000}\InProcServer32 /ve /d "%~DP0ue32ctmn.dll" /f
)
REG ADD HKCR\CLSID\{b5eedee0-c06e-11cf-8c56-444553540000}\InProcServer32 /v ThreadingModel /d "Apartment" /f
REG ADD HKCR\*\shellex\ContextMenuHandlers\UltraEdit /ve /d {b5eedee0-c06e-11cf-8c56-444553540000} /f
REG ADD "HKCU\Software\IDM Computer Solutions\UltraEdit" /v ContextMenuText /d "&UltraEdit" /f
REG ADD "HKCU\Software\IDM Computer Solutions\UltraEdit" /v IntegrateWithExplorer /t REG_DWORD /d 1 /f
REG ADD "HKCU\Software\IDM Computer Solutions\UltraEdit" /v IntegrateWithExplorerOverride /t REG_DWORD /d 1 /f
