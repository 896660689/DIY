@ECHO OFF

SET inTypes=*.mp4 *.mkv *.mov *.avi *.wmv *.vob
SET outDir=OUT

SET videoWidth=720
SET videoHeight=338
SET videoLevel=3.1
SET videoProfile=main
SET videoConstantRateFactor=17

SET audioChannel=2
SET audioCodec=aac
SET audioBitRate=225k
SET audioSampleRate=44.1k

PATH=%PATH%;%~dp0
PUSHD %CD%

IF [%1]==[] (
	SET videoPath=.
) ELSE (
	SET videoPath=%1
)

IF EXIST %videoPath%\NUL (
	CD /D %videoPath%
	FOR %%I IN (%inTypes%) DO CALL :MakeVideo "%%~nxI"
) ELSE (
	CD /D %~dp1
	CALL :MakeVideo "%~nx1"
)

POPD
EXIT /b 0

:MakeVideo
	SET audioOptions=-acodec %audioCodec% -ab %audioBitRate% -ar %audioSampleRate% -ac %audioChannel%
	SET videoOptions=-vf crop=in_w:in_w*%videoHeight%/%videoWidth% -s %videoWidth%x%videoHeight% -vcodec libx264 -crf %videoConstantRateFactor% -profile:v %videoProfile% -level %videoLevel%

	SET subtitle=%~n1.ass
	IF NOT EXIST "%subtitle%" SET subtitle=%~n1.srt
	IF EXIST "%subtitle%" (
		SET subtitleCharset=GB18030
		CALL :IsUTF8 "%subtitle%"
		IF ERRORLEVEL 1 SET subtitleCharset=UTF-8
		SET subtitleOptions=-vf "subtitles=%subtitle%:original_size=%VideoWidth%x%VideoHeight%:charenc=%subtitleCharset%"
	)

	IF NOT EXIST %outDir% MD %outDir%
	ffmpeg -i %1 -y %audioOptions% %videoOptions% %subtitleOptions% "%outDir%\%~n1.mp4"
EXIT /b 0

:IsUTF8
	SET hexFile=%~n1.hex
	CERTUTIL -f -encodehex %1 "%hexFile%" >NUL
	FOR /f "usebackq delims=" %%E IN ("%hexFile%") DO (
		SET "firstLine=%%E" >NUL
		GOTO :endFor
	)
	:endFor
	DEL /Q /F "%hexFile%" >NUL 2>&1

	ECHO %firstLine% | FIND "ef bb bf" >NUL && EXIT /b 1
EXIT /b 0

