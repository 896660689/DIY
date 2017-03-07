@ECHO OFF

IF "%1"=="" (
	SET VDIR=.
) ELSE (
	SET VDIR=%1
)

IF EXIST "%VDIR%\." (
	FOR %%A IN ("%VDIR%\*.mp4" *.mkv *.mov *.avi *.wmv *.vob) DO CALL :MakeMMIViD "%%A"
) ELSE (
	CALL MakeMMIViD "%VDIR%"
)
EXIT /b 0

:MakeMMIViD
	CD %~dp1
	SET DDIR=MMIVID
	IF NOT EXIST "%DDIR%" MD "%DDIR%"

	SET DVID=%DDIR%\%~n1.mp4

	SET FOPT=-y -strict -2 -acodec aac -ab 225k -ar 44.1k -ac 2 -vf crop=in_w:in_w*338/720 -s 720x338 -vcodec libx264 -crf 17 -profile:v main -level 3.1
	
	SET SUBT=%~n1.srt
	IF NOT EXIST "%SUBT%" SET SUBT=%~n1.ass
	IF EXIST "%SUBT%" (
		ffmpeg -i %1 %FOPT% -vf "subtitles=%SUBT%:original_size=720x338" "%DVID%"
	) ELSE (
		ffmpeg -i %1 %FOPT% "%DVID%"
	)
EXIT /b 0

REM OLD_VERSION
REM IF NOT EXIST OUT MD OUT
REM FOR %%A IN (*.mp4 *.mkv *.mov *.avi *.wmv *.vob) DO ffmpeg -i "%%A" -strict -2 -acodec aac -ab 225k -ar 44.1k -ac 2 -vf crop="in_w:in_w*338/720" -s 720x338 -vcodec libx264 -crf 17 -profile:v main -level 3.1 "OUT/%%~nA.mp4"
