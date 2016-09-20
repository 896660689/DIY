@Echo Off
Title 迅雷7JayXon绿色精简版安装卸载工具
Pushd %~dp0
If "%PROCESSOR_ARCHITECTURE%"=="AMD64" (Set a="HKLM\SOFTWARE\Wow6432Node\Thunder Network\ThunderOem\thunder_backwnd" /v&Set b=%SystemRoot%\SysWOW64) Else (Set a="HKLM\SOFTWARE\Thunder Network\ThunderOem\thunder_backwnd" /v&Set b=%SystemRoot%\system32)
Rd "%b%\test_permission_JayXon" >nul 2>nul
Md "%b%\test_permission_JayXon" 2>nul||(Echo 请使用右键管理员身份运行&&Pause >nul&&Exit)
Rd "%b%\test_permission_JayXon" >nul 2>nul
Set p=Profiles
ver|Find "6." >nul&&If "%~d0"=="%SystemDrive%" (Set p=%PUBLIC%\Documents\Thunder Network\Thunder\Profiles)
SetLocal EnableDelayedExpansion
:Menu
If "%1"=="" Cls
If Exist "%b%\Tasklist.exe" Tasklist|Find /i "thunder.exe">nul&&(Echo 请先退出迅雷，按任意键重试&&Pause >nul&&Goto Menu)
If Not "%1"=="" (Set c=%1&Goto Goto)
Echo 1.全新安装
Echo 此模式直接将迅雷安装到当前文件夹，即普通安装模式
Echo.
Echo 2.更新安装beta
Echo 此模式会自动检测系统中旧版迅雷的位置并将其卸载，然后将新版安装至旧版迅雷的位置，更新后会保留用户的设置、应用、皮肤等
Echo 如果之前使用的不是本人制作的迅雷版本，请勿使用此模式，无法保证能够正常安装
Echo.
Echo 3.创建桌面快捷方式
Echo.
Echo 4.删除Win7库中的迅雷下载
Echo.
Echo 5.将离线下载添加到左侧我的应用
Echo.
Echo 6.卸载
Echo.
Echo 7.退出
Echo.
Set /p c=请输入数字并按Enter确定：
:Goto
If Not "%c%"=="" Set c=%c:~0,1%
If "%c%"=="1" Goto SetupMenu
If "%c%"=="2" Goto Update
If "%c%"=="3" Goto lnk
If "%c%"=="4" Goto Libraries
If "%c%"=="5" Goto Offline
If "%c%"=="6" Goto Uninstall
If "%c%"=="7" Goto Exit
Goto Menu
:SetupMenu
If "%2"=="" Cls
If Not "%2"=="" (Set c=%2&Goto Goto2)
Echo 请选择需要安装的项目
Echo 1.BHO、IE右键菜单、专用链、屏蔽上传
Echo 2.BHO、IE右键菜单、屏蔽上传
Echo 3.BHO、专用链、屏蔽上传
Echo 4.BHO、屏蔽上传
Echo 5.仅屏蔽上传
Set /p c=请输入数字并按Enter确定：
:Goto2
If Not "%c%"=="" Set c=%c:~0,1%
If "%c%" LEQ "5" Goto Delete
Goto SetupMenu
:Update
For /f "skip=2 tokens=1,2 delims=:" %%i in ('Reg Query %a% "Path"') Do (Set f=%%i
Set g=%%~dpj
Set f=!f:~-1!!g:~1!)
If "%f%"=="" Goto Error
Set f=%f:"=%
Cd /d "%f%"||Goto Error
Cd ..\
Cls
Echo 将迅雷安装到%cd%
Pause
Goto Uninstall
:Error
Cls
Echo 未检测到迅雷位置，按任意键返回主菜单
Pause >nul
Goto Menu
:Copy
Rd /s /q "Addins\Community" >nul 2>nul
Rd /s /q "Addins\VipService" >nul 2>nul
Rd /s /q "BHO" >nul 2>nul
Rd /s /q "Program" >nul 2>nul
Rd /s /q "Xar" >nul 2>nul
Echo 正在复制文件...
XCopy /e /i /q /y "%~dp0Addins" "%cd%\Addins"
XCopy /e /i /q /y "%~dp0BHO" "%cd%\BHO"
XCopy /e /i /q /y "%~dp0Program" "%cd%\Program"
XCopy /e /i /q /y "%~dp0Skin" "%cd%\Skin"
XCopy /e /i /q /y "%~dp0Xar" "%cd%\Xar"
Copy /y "%~f0" "%cd%"
Call "%cd%\%~nx0" 1
Goto Exit
:BHO
For %%i In (Program\*71.dll) Do If Not Exist "%b%\%%~nxi" (Copy /y "%%i" "%b%\" 2>nul)
BHO\XLNonIESvr.exe -r 360 -silent -setfirst
BHO\XLNonIESvr.exe -r opera -silent -setfirst
BHO\XLNonIESvr.exe -r maxthon -silent -setfirst
BHO\XLNonIESvr.exe -r theworld -silent -setfirst
Regsvr32 /s BHO\ThunderAgent.dll
Regsvr32 /s BHO\XunLeiBHO.dll
Reg Add %a% "Path" /d "%~dp0Program\Thunder.exe" /f
Reg Add %a% "dir" /d "%~dp0\" /f
Reg Add %a% "instdir" /d "%~dp0\" /f
Reg Add %a% "addinsdir" /d "%~dp0Addins" /f
Reg Add %a% "Version" /d "7.2.11.3788" /f
If Not "%c%"=="2" If Not "%c%"=="4" Regsvr32 /s BHO\LinkSimulate.dll
If "%c%" GEQ "3" Goto Fuck
Reg Add "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷下载" /ve /d "%~dp0BHO\geturl.htm" /f
Reg Add "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷下载" /v "Contexts" /t REG_DWORD /d "0x00000022" /f
Reg Add "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷下载全部链接" /ve /d "%~dp0BHO\getAllurl.htm" /f
Reg Add "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷下载全部链接" /v "Contexts" /t REG_DWORD /d "0x000000f3" /f
:Fuck
Md "%AllUsersProfile%\Application Data\Thunder Network\cid_store.dat"
Md "%AllUsersProfile%\Application Data\Thunder Network\emule_upload_list.dat"
Md "%AllUsersProfile%\Application Data\Thunder Network\DownloadLib\pub_store.dat"
Program\Thunder.exe -install -associate:all
Call "%~f0" 5
Set e=安装完成
ver|Find "6." >nul||Goto MsgBox
Md "%PUBLIC%\Thunder Network\cid_store.dat" 2>nul
Md "%PUBLIC%\Thunder Network\emule_upload_list.dat" 2>nul
If "%~d0"=="%SystemDrive%" (XCopy /e /i /q /y Addins "%ProgramData%\Thunder Network\Thunder\Addins" >nul 2>nul&XCopy /e /i /q /y Skin "%PUBLIC%\Documents\Thunder Network\Thunder\Skin" >nul 2>nul)
Goto MsgBox
:Uninstall
BHO\XLNonIESvr.exe -u opera -silent
BHO\XLNonIESvr.exe -u theworld -silent
Regsvr32 /s /u BHO\ThunderAgent.dll
Regsvr32 /s /u BHO\XunLeiBHO.dll
Regsvr32 /s /u BHO\LinkSimulate.dll
If Exist "BHO\XlBrowserAddin.dll" Regsvr32 /s /u BHO\XlBrowserAddin.dll
If Exist "BHO\XlBrowserAddinKernel.dll" Regsvr32 /s /u BHO\XlBrowserAddinKernel.dll
If Exist "BHO\xlfxctrl.dll" Regsvr32 /s /u BHO\xlfxctrl.dll
If Exist "BHO\UserAgent.dll" Regsvr32 /s /u BHO\UserAgent.dll
Program\Thunder.exe -unassociate:td -unassociate:torrent -unassociate:downlist -unassociate:thunderskin -unassociate:thunderaddin -unassociate:all -unregprotocol:ed2k -unregprotocol:magnet -unregprotocol:thunder -unregprotocol:xlapplink
If "%c%"=="2" Goto Copy
For /f "skip=2 tokens=1,2 delims=:" %%i in ('Reg Query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Desktop') Do (Set d=%%i
Set d=!d:~-1!:%%j\)
Set d=%d:"=%
Del /f /q "%d:\\=\%迅雷7.lnk" 2>nul
:Delete
Reg Delete "HKCR\Software\thunder" /f >nul 2>nul
Reg Delete "HKLM\Software\Thunder Network" /f >nul 2>nul
Reg Delete "HKCU\Software\Thunder Network" /f >nul 2>nul
Reg Delete "HKLM\Software\Wow6432Node\Thunder Network" /f >nul 2>nul
Reg Delete "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷下载" /f >nul 2>nul
Reg Delete "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷下载全部链接" /f >nul 2>nul
Reg Delete "HKCU\Software\Microsoft\Internet Explorer\MenuExt\使用迅雷离线下载" /f >nul 2>nul
If Exist "%PUBLIC%" (Rd /s /q "%PUBLIC%\Thunder Network" >nul 2>nul
Rd /s /q "%PUBLIC%\Documents\Thunder Network\XLFX" >nul 2>nul)
Rd /s /q "%TMP%\LiveUD" >nul 2>nul
Rd /s /q "%TMP%\Thunder" >nul 2>nul
Rd /s /q "%TMP%\Thunder Network" >nul 2>nul
Rd /s /q "%TMP%\ThunderLiveUD" >nul 2>nul
Rd /s /q "%TMP%\xltmp" >nul 2>nul
Rd /s /q "%TMP%\Xunlei" >nul 2>nul
Rd /s /q "%AllUsersProfile%\Application Data\Thunder Network" >nul 2>nul
Rd /s /q "%AllUsersProfile%\Application Data\Xunlei" >nul 2>nul
Rd /s /q "%AllUsersProfile%\Xunlei" >nul 2>nul
Rd /s /q "%AllUsersProfile%\Thunder Network" >nul 2>nul
Rd /s /q "%AppData%\Thunder Network" >nul 2>nul
Rd /s /q "%CommonProgramFiles%\Thunder Network" >nul 2>nul
If Exist "%CommonProgramFiles(x86)%" Rd /s /q "%CommonProgramFiles(x86)%\Thunder Network" >nul 2>nul
Rd /s /q "%UserProfile%\AppData\LocalLow\Thunder Network" >nul 2>nul
Rd /s /q "%UserProfile%\AppData\LocalLow\XunLei" >nul 2>nul
Rd /q "%SystemDrive%\TDDOWNLOAD" >nul 2>nul
Rd /s /q "Data" >nul 2>nul
Rd /s /q "Skin\autoskin" >nul 2>nul
Rd /s /q "Skin\recommend" >nul 2>nul
Rd /s /q "%p%\..\Skin\autoskin" >nul 2>nul
Rd /s /q "%p%\..\Skin\recommend" >nul 2>nul
Rd /s /q "%p%\AppleAssistant" >nul 2>nul
Rd /s /q "%p%\icondir" >nul 2>nul
Rd /s /q "%p%\Community\VipAssistant" >nul 2>nul
Rd /s /q "%p%\Community\XMLPaint" >nul 2>nul
Rd /s /q "%p%\platform" >nul 2>nul
Rd /s /q "%p%\pluginpanel" >nul 2>nul
Rd /s /q "%p%\MsgSys" >nul 2>nul
Rd /s /q "%p%\SkinRecommendIcon" >nul 2>nul
Rd /s /q "%p%\ThunderAddin" >nul 2>nul
Rd /s /q "%p%\ThunderNavigator" >nul 2>nul
Rd /s /q "%p%\VipService\Scene" >nul 2>nul
Rd /s /q "%p%\XLDaQuan" >nul 2>nul
Rd /s /q "Addins\HideTaskInfoAddin" >nul 2>nul
Rd /s /q "Addins\Update" >nul 2>nul
If Exist "%ProgramData%" (Rd /s /q "%ProgramData%\Thunder Network\Thunder\Addins\Community" >nul 2>nul
Rd /s /q "%ProgramData%\Thunder Network\Thunder\Addins\HideTaskInfoAddin" >nul 2>nul
Rd /s /q "%ProgramData%\Thunder Network\Thunder\Addins\VipService" >nul 2>nul
Del /f /q "%ProgramData%\Thunder Network\Thunder\Addins\addins*.*" >nul 2>nul)
Del /f /q "Addins\addins*.*" >nul 2>nul
Del /f /q "%p%\Community\*.png" >nul 2>nul
Del /f /q "%p%\Community\*.xml" >nul 2>nul
Del /f /q "%p%\Community\welcome.jpg" >nul 2>nul
Del /f /q "%p%\P2pShare\linkdata.xml" >nul 2>nul
Del /f /q "%p%\P2pShare\thumb*.png" >nul 2>nul
Del /f /q "BHO\*.?.?.*.dll" >nul 2>nul
If "%c%" LEQ "4" Goto BHO
If "%c%"=="5" Goto Fuck
Set e=卸载完成
Goto MsgBox
:Libraries
Del /f /q "%AppData%\Microsoft\Windows\Libraries\迅雷下载.library-ms" 2>nul
If Exist "%AppData%\Microsoft\Windows\Libraries\迅雷下载.library-ms" (Set e=删除失败) Else (Set e=删除完成)
Goto MsgBox
:Offline
Md "%p%\Download" 2>nul
Copy /y "Program\Download" "%p%\Download" >nul 2>nul
If Exist "%p%\Download\Download" (Set e=添加完成) Else (Set e=添加失败)
Goto MsgBox
:lnk
mshta VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""Desktop"") & ""\迅雷7.lnk""):b.TargetPath=""%~dp0Program\Thunder.exe"":b.WorkingDirectory=""%~dp0Program\"":b.Save:close")
Set e=创建快捷方式完成
:MsgBox
If Not "%1"=="" If Not "%1"=="1" Goto Exit
If "%2"=="" mshta VBScript:Msgbox("%e%",vbSystemModal,"")(close)
:Exit
Popd