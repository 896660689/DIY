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
	CD /d %videoPath%
	FOR %%I IN (%inTypes%) DO CALL :MakeVideo "%%~nxI"
) ELSE (
	CD /d %~dp1
	CALL :MakeVideo "%~nx1"
)

POPD
EXIT /b 0

:MakeVideo
	SET audioOptions=-acodec %audioCodec% -ab %audioBitRate% -ar %audioSampleRate% -ac %audioChannel%
	SET videoOptions=-vf crop=in_w:in_w*%videoHeight%/%videoWidth% -s %videoWidth%x%videoHeight% -vcodec libx264 -crf %videoConstantRateFactor% -profile:v %videoProfile% -level %videoLevel%

	SET subtitleOptions=
	SET subtitle=%~n1.ass
	IF NOT EXIST "%subtitle%" SET subtitle=%~n1.srt
	IF NOT EXIST "%subtitle%" GOTO :endSubtitle
		SET charsetOption=
		CALL :DetectCharset "%subtitle%"
		IF NOT ERRORLEVEL 1 SET charsetOption=:charenc=GB18030
		SET subtitleOptions=-vf "subtitles=%subtitle%:original_size=%VideoWidth%x%VideoHeight%%charsetOption%"
		ECHO.
		ECHO Subtitle: %subtitle%
		ECHO Charset: %detectedCharset%
	:endSubtitle

	IF NOT EXIST %outDir% MD %outDir%
	@ECHO ON
	ffmpeg -i %1 -y %audioOptions% %videoOptions% %subtitleOptions% "%outDir%\%~n1.mp4"
	@ECHO OFF
EXIT /b 0

:DetectCharset
	SET hexFile=%~n1.hex
	CERTUTIL -f -encodehex %1 "%hexFile%" >NUL
	FOR /f "usebackq delims=" %%E IN ("%hexFile%") DO (
		SET "firstLine=%%E" >NUL
		GOTO :endFor
	)
	:endFor
	DEL /Q /F "%hexFile%" >NUL 2>&1

	ECHO %firstLine% | FIND "ef bb bf"     >NUL && SET "detectedCharset=UTF-8"     && EXIT /b 1
	ECHO %firstLine% | FIND "ff fe 00 00"  >NUL && SET "detectedCharset=UTF-32 LE" && EXIT /b 5
	ECHO %firstLine% | FIND "ff fe"        >NUL && SET "detectedCharset=UTF-16"    && EXIT /b 2
	ECHO %firstLine% | FIND "fe ff 00"     >NUL && SET "detectedCharset=UTF-16 BE" && EXIT /b 3
	ECHO %firstLine% | FIND "00 00 fe ff"  >NUL && SET "detectedCharset=UTF-32 BE" && EXIT /b 4
	SET "detectedCharset=ASCII"
EXIT /b 0
