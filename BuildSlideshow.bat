@ECHO off
SETLOCAL EnableDelayedExpansion
SET srcDir=%~1

SET outDir=%temp%\outDir
SET templateStart="%~dp0template_start.txt"
SET templateMiddle="%~dp0template_middle.txt"
SET templateEnd="%~dp0template_end.txt"

IF EXIST %outDir% RD /s /q %outDir%>nul
MKDIR %outDir%

:: We want to view gifs, we want them shuffled.  This is how we do it:
::   create a chain of n randomly-named html files, where n is the number of gif files we've found
::   push all the gif paths on a stack, in default dir-output order
::   loop through the html files in the chain in default dir-output order
::     pop a gif path off the stack and assign it to the img element of the current html file
:: End result: since the html filenames are generated randomly, we end up with a shuffled chain of
:: html pages, each containing one gif image

ECHO Generating chain...

SET head=%random%.html
SET currentPage=%head%
SET stack=
FOR /f "delims=" %%A IN ('DIR /s /b %srcDir%\*.gif') DO (
  SET nextPage=!RANDOM!.html
  CALL :WriteIntro !currentPage! !nextPage!
  CALL :push %%A
  SET previousPage=!currentPage!
  SET currentPage=!nextPage!
)

CALL :WriteIntro %previousPage% %head%

ECHO Assigning image sources...

FOR /f "delims=" %%A IN ('DIR /s /b %outDir%\*.html') DO (
  CALL :pop
  ECHO  -- !popped!
  ECHO "!popped!" >>%%A
  TYPE %templateEnd%>>%%A
)

START %outDir%\%head%
ECHO Chain start: %outDir%\%head%
Pause
GOTO :EOF

:WriteIntro
  SET thisPage=%outDir%\%1
  SET nextPage=%outDir%\%2

  TYPE %templateStart% >%thisPage%
  ECHO "%nextPage:\=\\%" >>%thisPage%
  TYPE %templateMiddle%>>%thisPage%
GOTO :EOF

:push
  SET stack=%1 %stack%
GOTO :EOF

:pop
  CALL :_pop %stack%
GOTO :EOF

:_pop
  SET popped=%1
  SET tempStack=
  CALL :reduce %stack%
  SET stack=%tempStack%
GOTO :EOF

:reduce
  SHIFT
  IF NOT "%1"=="" (
    SET tempStack=%tempStack% %1
    GOTO :reduce
  )
GOTO :EOF
