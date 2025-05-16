@echo off
setlocal enabledelayedexpansion

:: Load MSVC environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

:: Configuration
set "source_dir=%~dp0sources"
set "test_dir=%~dp0tests"
set "build_dir==%~dp0build"
set "cpp_list=test_cpp_files.txt"
set "obj_list=test_obj_files.txt"
set "exe_name=tests_debug.exe"
set "compiler=cl"
set "cflags=/Zi /EHsc /RTCc /RTCs /RTC1 /MDd /std:c++14 /W4 /Od /I\"%source_dir%\" /I\"%test_dir%\" /Fe%build_dir%\%exe_name% /Fo%build_dir%\ /Fd%build_dir%\vc140.pdb /DEBUG user32.lib"

:: Create build directory
if not exist "%build_dir%" mkdir "%build_dir%"

:: Clean old files
echo Cleaning previous builds...
del /q "%build_dir%\*.obj" >nul 2>&1
del /q "%build_dir%\*.exe" >nul 2>&1
del /q "%build_dir%\*.pdb" >nul 2>&1

:: === Start Timer ===
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set "start=%%a*3600 + %%b*60 + %%c + %%d/100"
)

:: Compile & Link
echo Compiling and linking all .cpp files...
pushd "%source_dir%"
%compiler% *.cpp %cflags%
if errorlevel 1 (
    echo Compilation or linking failed.
    pause
    exit /b 1
)
popd

:: === End Timer ===
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set "end=%%a*3600 + %%b*60 + %%c + %%d/100"
)

for /f %%t in ('powershell -nologo -command "[math]::Round((%end%) - (%start%), 2)"') do set duration=%%t

echo Build complete: %build_dir%\%exe_name%
echo Build time: %duration% seconds
pause
