@echo off

:: this will run Love.exe and pass in this folder as an argument.
:: use this to test the game in the Love engine.

:: syntax: EXE-LOCATION ARGUMENT
:: in this case: Love.exe PathToGameFolder

echo -------------------------------------------------------------------
echo                   Emacs_Run_JCSJava version 1.0
echo          Copyright (c) by Jen-Chieh Shen(jcs090218@gmail.com)
echo -------------------------------------------------------------------
echo.
echo.

:: Back up to project root
cd ..

:: "D:\Program Files\LOVE\love.exe" "%CD%"

"C:\Program Files\LOVE\love.exe" "%CD%"

echo.
echo.
echo -------------------------------------------------------------------
echo                               END
echo -------------------------------------------------------------------
echo.
