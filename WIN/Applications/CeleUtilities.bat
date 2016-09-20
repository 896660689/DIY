@ECHO OFF
CD /D %~DP0

TITLE Yonsm.NET 一键安装软件包
ECHO 欢迎使用 Yonsm.NET 提供的一键安装软件！
ECHO 若要单独安装某个软件，请执行其中的名称为 CeleSetup 的所有文件。
ECHO.
PAUSE 

ECHO.
ECHO 正在安装 Visual C++ 运行库
VC2003.Redist.exe
VC2005.Redist.exe
VC2008.Redist.exe

ECHO.
FOR /R %%A IN (CeleSet?p.bat) DO CALL %%A 

ECHO.
ECHO 恭喜，软件包已经完成安装。您可以在开始菜单中找到新添加的快捷方式。
ECHO.
PAUSE
