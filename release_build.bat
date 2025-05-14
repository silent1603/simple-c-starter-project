@echo off
setlocal enabledelayedexpansion

:: Load MSVC environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

:: === Configuration ===
set "source_dir=%~dp0sources"
set "build_dir=%~dp0build"
set "cpp_list=cpp_files.txt"
set "obj_list=obj_files.txt"
set "exe_name=app_release.exe"
set "compiler=cl"
set "cflags=/c /O2 /GL /W4 /GR- /EHs- /std:c++14 /Fo%build_dir%\ "
set "ldflags=/LTCG /OPT:REF /OPT:ICF /INCREMENTAL:NO /OUT:%build_dir%\%exe_name%"

:: Create release directory
if not exist "%build_dir%" mkdir "%build_dir%"

:: Clean previous release artifacts
echo Cleaning previous release build...
del /q "%build_dir%\*.obj" >nul 2>&1
del /q "%build_dir%\*.exe" >nul 2>&1
del /q "%build_dir%\*.pdb" >nul 2>&1
del /q "%cpp_list%" >nul 2>&1
del /q "%obj_list%" >nul 2>&1

:: Generate list of cpp files
echo Listing source files...
(for %%f in ("%source_dir%\*.cpp") do (
    echo %%f
)) > %cpp_list%


:: === Start Timer ===
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set "start=%%a*3600 + %%b*60 + %%c + %%d/100"
)


:: === Compile step ===
echo Compiling for Release...
for /f %%f in (%cpp_list%) do (
    echo Compiling %%f...
    %compiler% %%f %cflags%
    if errorlevel 1 (
        echo Compile failed on %%f
        pause
        exit /b 1
    )
    echo %build_dir%\%%~nf.obj >> %obj_list%
)

:: === Link step ===
echo Linking release binary...
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

echo Release build complete: %build_dir%\%exe_name%
echo Build time: %duration% seconds
pause
