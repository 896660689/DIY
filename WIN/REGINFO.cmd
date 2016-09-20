reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /f /v "RegisteredOrganization" /t REG_SZ /d "Yonsm.NET"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /f /v "RegisteredOwner" /t REG_SZ /d "Yonsm"

IF EXIST %windir%\SysWOW64 (
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion" /f /v "RegisteredOrganization" /t REG_SZ /d "Yonsm.NET"
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion" /f /v "RegisteredOwner" /t REG_SZ /d "Yonsm"
)
