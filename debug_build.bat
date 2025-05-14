@echo off
setlocal enabledelayedexpansion

:: Load MSVC environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

:: Configuration
set "source_dir=%~dp0sources"
set "build_dir=%~dp0build"
set "cpp_list=cpp_files.txt"
set "obj_list=obj_files.txt"
set "exe_name=app_debug.exe"
set "compiler=cl"
set "cflags=/Zi /fsanitize=address /EHsc /RTCc /RTCs /RTC1 /MDd /std:c++14 /W4 /Od /Fo%build_dir%\ /Fd:%build_dir%\vc140.pdb"
set "ldflags= /DEBUG /OUT:%build_dir%\%exe_name% /INFERASANLIBS"

:: Create build directory if it doesn't exist
if not exist "%build_dir%" mkdir "%build_dir%"

:: Clean old files
echo Cleaning previous builds...
del /q "%build_dir%\*.obj" >nul 2>&1
del /q "%build_dir%\*.exe" >nul 2>&1
del /q "%build_dir%\*.pdb" >nul 2>&1
del /q "%cpp_list%" >nul 2>&1
del /q "%obj_list%" >nul 2>&1

:: Generate cpp_files.txt
echo Listing .cpp files...
(for %%f in (%source_dir%\*.cpp) do (
    echo %%f
)) > %cpp_list%

:: === Start Timer ===
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set "start=%%a*3600 + %%b*60 + %%c + %%d/100"
)

:: === Compile phase ===
echo Compiling .cpp files to .obj...
for /f %%f in (%cpp_list%) do (
    echo Compiling %%f...
    %compiler% /c %%f %cflags%
    if errorlevel 1 (
        echo Compilation failed at %%f
        pause
        exit /b 1
    )
    echo %build_dir%\%%~nf.obj >> %obj_list%
)

:: === Link phase ===
echo Linking all object files...
%compiler% @%obj_list% /link %ldflags%

if errorlevel 1 (
    echo Linking failed.
    pause
    exit /b 1
)

:: === End Timer and Report Duration ===
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set "end=%%a*3600 + %%b*60 + %%c + %%d/100"
)

:: Calculate duration using PowerShell
for /f %%t in ('powershell -nologo -command "[math]::Round((%end%) - (%start%), 2)"') do set duration=%%t

echo Debug build complete: %build_dir%\%exe_name%
echo Build time: %duration% seconds
pause
