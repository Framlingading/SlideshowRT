@ECHO off
SETLOCAL EnableDelayedExpansion

SET srcDir=%~1
SET outDir=%temp%\outDir
SET templateStart="%~dp0template_start.txt"
SET templateMiddle="%~dp0template_middle.txt"
SET templateEnd="%~dp0template_end.txt"

IF EXIST %outDir% RD /s /q %outDir%>nul
MKDIR %outDir%
XCOPY /yi "%~dp0slideshow.js" "%outDir%">nul
XCOPY /yi "%~dp0arrow.png" "%outDir%">nul

:: We want to view images, we want them shuffled.  This is the roundabout way we do it:
::     foreach image file, in dir order
::       write template middle, the image path, and template end to a randomly named html file
::     foreach html file
::       write template start, path to next html file, and current contents of html file to temp html file
::       move temp html to the original html file location
:: This creates a bunch of html files that are all chained together.  Because of the way the template is written,
:: we have to post-process a bit with the javascript.  So the first thing the javascript does is take the file
:: the img link points to, and set the next page link to point to it instead, and then it changes the img link to
:: point to the image itself (so the image can be opened directly if the user desires.)

ECHO Generating pages...
FOR /f "delims=" %%A IN ('DIR /s /b %srcDir%\*.gif %srcDir%\*.jpg %srcDir%\*.png') DO (
  CALL :generate "%%A"
)

ECHO Priming...
FOR /f "delims=" %%A IN ('DIR /s /b %outDir%\*.html') DO (
  SET last=%%A
)

ECHO Linking...
SET head=
FOR /f "delims=" %%A IN ('DIR /s /b %outDir%\*.html') DO (
  IF NOT DEFINED head (
    SET head=%%A
  ) ELSE (
    CALL :Link !last! %%A
  )
  set last=%%A
)
CALL :Link %last% %head%

rem START %head%
echo Chain start: %head%
Pause

GOTO :EOF

:generate
  SET newPage=%outDir%\%RANDOM%%RANDOM%.html
  IF EXIST %newPage% GOTO :generate
  TYPE %templateMiddle%>%newPage%
  ECHO %1>>%newPage%
  TYPE %templateEnd%>>%newPage%
GOTO :EOF

:Link
  SET thisPage=%1
  SET nextPage=%2
  SET tempPage=%outDir%\tempPage
  TYPE %templateStart%>%tempPage%
  ECHO %nextPage%>>%tempPage%
  TYPE %thisPage%>>%tempPage%
  MOVE /y %tempPage% %thisPage%>nul
GOTO :EOF
