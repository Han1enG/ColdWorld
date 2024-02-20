@echo off
setlocal enabledelayedexpansion
REM 声明采用UTF-8编码
chcp 65001

set "input_dir=C:\Users\han1en9\Desktop\Project\ColdWorld\content\post"
set "output_dir=C:\Users\han1en9\Desktop\Project\ColdWorld\archetypes"

for %%F in ("%input_dir%\*.md") do (
    set "output_file=%output_dir%\%%~nxF"
    echo Converting "%%~nxF"...
    (
        echo ---
        for /f "usebackq delims=" %%L in ("%%F") do (
            set "line=%%L"
            if "!line:tags: =!" neq "!line!" (
                set "line=tags = [!line:~6,-1]"
            ) else if "!line:categories: =!" neq "!line!" (
                set "line=categories = [!line:~12,-1]"
            )
            echo !line!
        )
        echo ---
    ) > "!output_file!"
)

echo Conversion completed.
pause