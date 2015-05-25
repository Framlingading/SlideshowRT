@ECHO off
SETLOCAL EnableDelayedExpansion

ECHO Setting up...
SET srcDir=%~1
SET outDir=%temp%\outDir
SET templateStart="%~dp0template_start.txt"
SET templateMiddle="%~dp0template_middle.txt"
SET templateEnd="%~dp0template_end.txt"

ECHO Clearing target directory...
IF EXIST %outDir% RD /s /q %outDir%>nul
MKDIR %outDir%

:: We want to view gifs, we want them shuffled.  This is how we do it:
::   create a chain of n randomly-named html files, where n is the number of gif files we've found
::   push all the gif paths on a stack, in default dir-output order
::   loop through the html files in the chain in default dir-output order
::     pop a gif path off the stack and assign it to the img element of the current html file
:: End result: since the html filenames are generated randomly, we end up with a shuffled chain of
:: html pages, each containing one gif image

ECHO Generating pages...
FOR /f "delims=" %%A IN (DIR /s /b %srcDir%\*.gif %srcDir%\*.jpg') DO (
  CALL :generate "%%A"
)

ECHO Priming...
FOR /f "delims=" %%A in ('dir /s /b %outDir%\*.html') DO (
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
