@echo off
setlocal enabledelayedexpansion

:: === Load MSVC environment ===
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

:: === Configuration ===
set "source_dir=%~dp0sources"
set "build_dir=%~dp0build"
set "cpp_list=%build_dir%\cpp_files.txt"
set "obj_list=%build_dir%\obj_files.txt"
set "exe_name=app_release.exe"
set "compiler=cl"
set "cflags=/c /O2 /GL /W4 /GR- /EHs- /std:c++14 /I\"%source_dir%\" /Fo%build_dir%\\"
set "ldflags=/LTCG /OPT:REF /OPT:ICF /INCREMENTAL:NO /OUT:%build_dir%\%exe_name% user32.lib"

:: === Prepare build directory ===
if not exist "%build_dir%" mkdir "%build_dir%"

echo Cleaning previous build artifacts...
del /q "%build_dir%\*.obj" "%build_dir%\*.exe" "%build_dir%\*.pdb" >nul 2>&1
del /q "%cpp_list%" "%obj_list%" >nul 2>&1

:: === List source files ===
echo Listing source files...
pushd "%source_dir%"
(for %%f in (*.cpp) do echo "%source_dir%\%%f") > "%cpp_list%"
popd

:: === Start Timer ===
set "startTime=%time: =0%"

:: === Compilation Phase ===
echo Compiling...
for /f %%f in ('type "%cpp_list%"') do (
    echo Compiling %%~f...
    %compiler% %%~f %cflags%
    if errorlevel 1 (
        echo Compile failed on %%~f
        pause
        exit /b 1
    )
    echo "%build_dir%\%%~nf.obj" >> "%obj_list%"
)

:: === Linking Phase ===
echo Linking...
%compiler% @%obj_list% /link %ldflags%
if errorlevel 1 (
    echo Linking failed.
    pause
    exit /b 1
)

:: === End Timer ===
set "endTime=%time: =0%"
echo Build successful: %build_dir%\%exe_name%
:: === Get elapsed time: ===
set "end=!endTime:%time:~8,1%=%%100)*100+1!"  &  set "start=!startTime:%time:~8,1%=%%100)*100+1!"
set /A "elap=((((10!end:%time:~2,1%=%%100)*60+1!%%100)-((((10!start:%time:~2,1%=%%100)*60+1!%%100), elap-=(elap>>31)*24*60*60*100"

rem Convert elapsed time to HH:MM:SS:CC format:
set /A "cc=elap%%100+100,elap/=100,ss=elap%%60+100,elap/=60,mm=elap%%60+100,hh=elap/60+100"

echo Start:    %startTime%
echo End:      %endTime%
echo Elapsed:  %hh:~1%%time:~2,1%%mm:~1%%time:~2,1%%ss:~1%%time:~8,1%%cc:~1%
pause
