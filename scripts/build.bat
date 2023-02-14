@echo off

echo -------------------------------------------------------------------
echo                   Emacs_Build_JCSJava version 1.0
echo          Copyright (c) by Jen-Chieh Shen(jcs090218@gmail.com)
echo -------------------------------------------------------------------
echo.
echo.

:: Back up to project root
cd ..

:: ##################
:: set path macros.
:: ##################
set BUILDNAME="PetShop"
set BUILDLOVEDIR="%cd%\build\love"
set BUILDEXEDIR="%cd%\build\exe"

set FILETOZIP="%cd%"
set FILEOUT="%cd%\build\love\%BUILDNAME%.zip"

set TEMPDIR="C:\temp738"
mkdir %TEMPDIR%
xcopy /s %FILETOZIP% %TEMPDIR%

:: #################################################################################
:: IMPORTANT(jenchieh): 這裡使用了多線程,所已主線成可能已經結束 但壓縮還沒有結束...
:: #################################################################################
set COMPRESSTIME=15000

:: ##############################
:: create the zip vb script.
:: ##############################
echo [build.bat]: Creating the vb script...
echo Set objArgs = WScript.Arguments > _zipIt.vbs
echo InputFolder = objArgs(0) >> _zipIt.vbs
echo ZipFile = objArgs(1) >> _zipIt.vbs
echo CreateObject("Scripting.FileSystemObject").CreateTextFile(ZipFile, True).Write "PK" ^& Chr(5) ^& Chr(6) ^& String(18, vbNullChar) >> _zipIt.vbs
echo Set objShell = CreateObject("Shell.Application") >> _zipIt.vbs
echo Set source = objShell.NameSpace(InputFolder).Items >> _zipIt.vbs
echo objShell.NameSpace(ZipFile).CopyHere(source) >> _zipIt.vbs
echo wScript.Sleep %COMPRESSTIME% >> _zipIt.vbs

:: ################
:: zip the folder
:: ################
echo [build.bat]: Start zipping the target file and output the file to destination folder...
CScript  _zipIt.vbs  %TEMPDIR%  %FILEOUT%

:: #############################
:: remove all the temp files.
:: #############################
echo [build.bat]: Start Removing all the temporary folders and files...
rmdir "%TEMPDIR%" /s /q

:: #############################
:: Start the build
:: #############################
echo [build.bat]: Start the building the command/executable file.

:: create the love directory.
mkdir %BUILDLOVEDIR%

:: create the executable directory.
mkdir %BUILDEXEDIR%

:: push the current directory and goto that directory
pushd build\

:: goto the love directory..
cd %BUILDLOVEDIR%

::
:: delete the previous build.
::
del %BUILDNAME%.love

:: zip to love
rename %BUILDNAME%.zip %BUILDNAME%.love

:: build using love 2d engine compiler?
copy /b love.exe+%BUILDNAME%.love %BUILDNAME%.exe

:: move file to command/execuatble directory
move %BUILDNAME%.exe %BUILDEXEDIR%

:: back to root directory.
popd

echo.
echo.
echo -------------------------------------------------------------------
echo                               END
echo -------------------------------------------------------------------
echo.

:: pause
