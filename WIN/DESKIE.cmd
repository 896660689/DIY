reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}" /f /v "InfoTip" /t REG_SZ /d "@%SystemDrive%\WINDOWS\system32\zh-CN\ieframe.dll.mui,-881"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}" /f /ve /t REG_SZ /d "浏览器"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}" /f /v "LocalizedStringX" /t REG_SZ /d "@%SystemDrive%\WINDOWS\system32\zh-CN\ieframe.dll.mui,-880"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\DefaultIcon" /f /ve /t REG_SZ /d "%SystemDrive%\Program Files\Internet Explorer\iexplore.exe,-32528"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\NoAddOns" /f /ve /t REG_SZ /d "无加载项启动(&N)"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\NoAddOns\Command" /f /ve /t REG_SZ /d "%SystemDrive%\Program Files\Internet Explorer\iexplore.exe about:NoAdd-ons"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\Set" /f /ve /t REG_SZ /d "属性(&R)"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\Set\Command" /f /ve /t REG_SZ /d "Rundll32.exe Shell32.dll,Control_RunDLL Inetcpl.cpl"

reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\Open" /f /ve /t REG_SZ /d "打开主页(&H)"

IF EXIST %windir%\SysWOW64 (
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\Open\Command" /f /ve /t REG_SZ /d "%SystemDrive%\Program Files (x86)\Internet Explorer\iexplore.exe"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\Open64" /f /ve /t REG_SZ /d "64 位模式(&6)"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\Open64\Command" /f /ve /t REG_SZ /d "%SystemDrive%\Program Files\Internet Explorer\iexplore.exe"
) ELSE (
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\Shell\Open\Command" /f /ve /t REG_SZ /d "%SystemDrive%\Program Files\Internet Explorer\iexplore.exe"
)

reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\ShellFolder" /f /ve /t REG_SZ /d "%SystemDrive%\WINDOWS\system32\ieframe.dll,-190"
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\ShellFolder" /f /v "Attributes" /t REG_DWORD /d 16
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\ShellFolder" /f /v "HideFolderVerbs" /t REG_SZ /d ""
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\ShellFolder" /f /v "HideOnDesktopPerUser" /t REG_SZ /d ""
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\ShellFolder" /f /v "HideAsDeletePerUser" /t REG_SZ /d ""
reg add "HKCR\CLSID\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}\ShellFolder" /f /v "WantsParseDisplayName" /t REG_SZ /d ""

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{B416D21B-3B22-B6D4-BBD3-BBD452DB3D5B}"  /f /ve /t REG_SZ /d "浏览器"
