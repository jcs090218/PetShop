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

:: "D:\Program Files\LOVE\love.exe" "%CD%" --console

:: "C:\Program Files\LOVE\love.exe" "C:\DataBase_University\Academy of Art University\GAM_GameDesign\GAM_335_01_Scripting_for_Lower_Level_Engines\GAM_335_JenChieh_Module_03\ZeldaStyle"
"C:\Program Files\LOVE\love.exe" "%CD%" --console

echo.
echo.
echo -------------------------------------------------------------------
echo                               END
echo -------------------------------------------------------------------
echo.
