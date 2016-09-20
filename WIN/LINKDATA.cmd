@ECHO OFF
CD /D %~DP0
FOR /D %%A IN (*) DO (
	REM ECHO %%A
	IF EXIST D:\%%A (
		ECHO D:\%%A
		CD %%A
		FOR /D %%B IN (*) DO (
			IF NOT EXIST D:\%%A\%%B MKLINK /D "D:\%%A\%%B" "%~DP0\%%A\%%B"
		)
		CD ..
	)
)