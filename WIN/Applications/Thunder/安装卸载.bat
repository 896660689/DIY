@Echo Off
Title Ѹ��7JayXon��ɫ����氲װж�ع���
Pushd %~dp0
If "%PROCESSOR_ARCHITECTURE%"=="AMD64" (Set a="HKLM\SOFTWARE\Wow6432Node\Thunder Network\ThunderOem\thunder_backwnd" /v&Set b=%SystemRoot%\SysWOW64) Else (Set a="HKLM\SOFTWARE\Thunder Network\ThunderOem\thunder_backwnd" /v&Set b=%SystemRoot%\system32)
Rd "%b%\test_permission_JayXon" >nul 2>nul
Md "%b%\test_permission_JayXon" 2>nul||(Echo ��ʹ���Ҽ�����Ա�������&&Pause >nul&&Exit)
Rd "%b%\test_permission_JayXon" >nul 2>nul
Set p=Profiles
ver|Find "6." >nul&&If "%~d0"=="%SystemDrive%" (Set p=%PUBLIC%\Documents\Thunder Network\Thunder\Profiles)
SetLocal EnableDelayedExpansion
:Menu
If "%1"=="" Cls
If Exist "%b%\Tasklist.exe" Tasklist|Find /i "thunder.exe">nul&&(Echo �����˳�Ѹ�ף������������&&Pause >nul&&Goto Menu)
If Not "%1"=="" (Set c=%1&Goto Goto)
Echo 1.ȫ�°�װ
Echo ��ģʽֱ�ӽ�Ѹ�װ�װ����ǰ�ļ��У�����ͨ��װģʽ
Echo.
Echo 2.���°�װbeta
Echo ��ģʽ���Զ����ϵͳ�оɰ�Ѹ�׵�λ�ò�����ж�أ�Ȼ���°氲װ���ɰ�Ѹ�׵�λ�ã����º�ᱣ���û������á�Ӧ�á�Ƥ����
Echo ���֮ǰʹ�õĲ��Ǳ���������Ѹ�װ汾������ʹ�ô�ģʽ���޷���֤�ܹ�������װ
Echo.
Echo 3.���������ݷ�ʽ
Echo.
Echo 4.ɾ��Win7���е�Ѹ������
Echo.
Echo 5.������������ӵ�����ҵ�Ӧ��
Echo.
Echo 6.ж��
Echo.
Echo 7.�˳�
Echo.
Set /p c=���������ֲ���Enterȷ����
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
Echo ��ѡ����Ҫ��װ����Ŀ
Echo 1.BHO��IE�Ҽ��˵���ר�����������ϴ�
Echo 2.BHO��IE�Ҽ��˵��������ϴ�
Echo 3.BHO��ר�����������ϴ�
Echo 4.BHO�������ϴ�
Echo 5.�������ϴ�
Set /p c=���������ֲ���Enterȷ����
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
Echo ��Ѹ�װ�װ��%cd%
Pause
Goto Uninstall
:Error
Cls
Echo δ��⵽Ѹ��λ�ã���������������˵�
Pause >nul
Goto Menu
:Copy
Rd /s /q "Addins\Community" >nul 2>nul
Rd /s /q "Addins\VipService" >nul 2>nul
Rd /s /q "BHO" >nul 2>nul
Rd /s /q "Program" >nul 2>nul
Rd /s /q "Xar" >nul 2>nul
Echo ���ڸ����ļ�...
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
Reg Add "HKCU\Software\Microsoft\Internet Explorer\MenuExt\ʹ��Ѹ������" /ve /d "%~dp0BHO\geturl.htm" /f
Reg Add "HKCU\Software\Microsoft\Internet Explorer\MenuExt\ʹ��Ѹ������" /v "Contexts" /t REG_DWORD /d "0x00000022" /f
Reg Add "HKCU\Software\Microsoft\Internet Explorer\MenuExt\ʹ��Ѹ������ȫ������" /ve /d "%~dp0BHO\getAllurl.htm" /f
Reg Add "HKCU\Software\Microsoft\Internet Explorer\MenuExt\ʹ��Ѹ������ȫ������" /v "Contexts" /t REG_DWORD /d "0x000000f3" /f
:Fuck
Md "%AllUsersProfile%\Application Data\Thunder Network\cid_store.dat"
Md "%AllUsersProfile%\Application Data\Thunder Network\emule_upload_list.dat"
Md "%AllUsersProfile%\Application Data\Thunder Network\DownloadLib\pub_store.dat"
Program\Thunder.exe -install -associate:all
Call "%~f0" 5
Set e=��װ���
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
Del /f /q "%d:\\=\%Ѹ��7.lnk" 2>nul
:Delete
Reg Delete "HKCR\Software\thunder" /f >nul 2>nul
Reg Delete "HKLM\Software\Thunder Network" /f >nul 2>nul
Reg Delete "HKCU\Software\Thunder Network" /f >nul 2>nul
Reg Delete "HKLM\Software\Wow6432Node\Thunder Network" /f >nul 2>nul
Reg Delete "HKCU\Software\Microsoft\Internet Explorer\MenuExt\ʹ��Ѹ������" /f >nul 2>nul
Reg Delete "HKCU\Software\Microsoft\Internet Explorer\MenuExt\ʹ��Ѹ������ȫ������" /f >nul 2>nul
Reg Delete "HKCU\Software\Microsoft\Internet Explorer\MenuExt\ʹ��Ѹ����������" /f >nul 2>nul
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
Set e=ж�����
Goto MsgBox
:Libraries
Del /f /q "%AppData%\Microsoft\Windows\Libraries\Ѹ������.library-ms" 2>nul
If Exist "%AppData%\Microsoft\Windows\Libraries\Ѹ������.library-ms" (Set e=ɾ��ʧ��) Else (Set e=ɾ�����)
Goto MsgBox
:Offline
Md "%p%\Download" 2>nul
Copy /y "Program\Download" "%p%\Download" >nul 2>nul
If Exist "%p%\Download\Download" (Set e=������) Else (Set e=���ʧ��)
Goto MsgBox
:lnk
mshta VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""Desktop"") & ""\Ѹ��7.lnk""):b.TargetPath=""%~dp0Program\Thunder.exe"":b.WorkingDirectory=""%~dp0Program\"":b.Save:close")
Set e=������ݷ�ʽ���
:MsgBox
If Not "%1"=="" If Not "%1"=="1" Goto Exit
If "%2"=="" mshta VBScript:Msgbox("%e%",vbSystemModal,"")(close)
:Exit
Popd