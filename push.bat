@echo off
cd /d "%~dp0"
echo ==============================================
echo   Pushing Rebellium MM2 changes to GitHub...
echo ==============================================
"C:\Users\Dayn\AppData\Local\Programs\MinGit\cmd\git.exe" add .
"C:\Users\Dayn\AppData\Local\Programs\MinGit\cmd\git.exe" commit -m "Update scripts and assets"
"C:\Users\Dayn\AppData\Local\Programs\MinGit\cmd\git.exe" push -u origin main
echo.
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Vse izmeneniya uspeshno otpravleny na GitHub!
) else (
    echo [ERROR] Ne udalos otpravit.
)
pause
