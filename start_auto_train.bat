@echo off
title Uma Musume Auto Train Launcher
color 0B

REM Kiem tra quyen Admin
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [+] Dang chay voi quyen Admin
) else (
    echo [-] Chuong trinh can quyen Admin de cai dat...
    echo [*] Dang yeu cau quyen Admin...
    
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:MENU
cls
echo ======================================
echo    UMA MUSUME AUTO TRAIN LAUNCHER
echo ======================================
echo.
echo [1] Khoi dong bot
echo [2] Cap nhat tu GitHub
echo [3] Cai dat/Cap nhat phu thuoc
echo [4] Sao luu config
echo [5] Khoi phuc config
echo [6] Kiem tra phan mem
echo [0] Thoat
echo.
echo ======================================

set /p choice="Nhap lua chon cua ban: "

if "%choice%"=="1" goto START_BOT
if "%choice%"=="2" goto UPDATE
if "%choice%"=="3" goto INSTALL_DEPS
if "%choice%"=="4" goto BACKUP_CONFIG
if "%choice%"=="5" goto RESTORE_CONFIG
if "%choice%"=="6" goto CHECK_DEPS
if "%choice%"=="0" exit

echo.
echo Lua chon khong hop le!
timeout /t 2 >nul
goto MENU

:CHECK_DEPS
cls
echo ======================================
echo      KIEM TRA PHAN MEM CAN THIET
echo ======================================
echo.

REM Kiem tra Git
where git >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Git chua duoc cai dat.
    ECHO Dang tim phuong thuc cai dat tu dong...
    where winget >nul 2>nul
    IF %ERRORLEVEL% EQU 0 (
        ECHO Da tim thay winget. Dang thu cai dat Git bang winget...
        winget install --id Git.Git -e --source winget --silent --accept-source-agreements --accept-package-agreements
        IF %ERRORLEVEL% EQU 0 (
            ECHO Cai dat Git thanh cong. Tu dong nap lai PATH...
            call :RefreshEnv
            where git >nul 2>nul
            IF %ERRORLEVEL% NEQ 0 (
                ECHO Khong the tu dong nap lai PATH. Vui long chay lai file nay.
                pause >nul
                exit /b
            )
            ECHO Nap lai PATH thanh cong.
        ) ELSE (
            ECHO Cai dat Git bang winget that bai. Vui long cai dat thu cong roi chay lai file.
            pause > nul
            exit /b
        )
    ) ELSE (
        ECHO winget khong ton tai. Vui long cai dat Git thu cong va them vao PATH.
        ECHO Link tai: https://git-scm.com/downloads
        pause
        exit /b
    )
)

REM Kiem tra Python
where py >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Python chua duoc cai dat.
    ECHO Dang tim phuong thuc cai dat tu dong...
    where winget >nul 2>nul
    IF %ERRORLEVEL% EQU 0 (
        ECHO Da tim thay winget. Dang thu cai dat Python bang winget...
        winget install --id Python.Python.3 -e --source winget --silent --accept-source-agreements --accept-package-agreements
        IF %ERRORLEVEL% EQU 0 (
            ECHO Cai dat Python thanh cong. Tu dong nap lai PATH...
            call :RefreshEnv
            where py >nul 2>nul
            IF %ERRORLEVEL% NEQ 0 (
                ECHO Khong the tu dong nap lai PATH. Vui long chay lai file nay.
                pause >nul
                exit /b
            )
            ECHO Nap lai PATH thanh cong.
        ) ELSE (
            ECHO Cai dat Python bang winget that bai. Vui long cai dat thu cong roi chay lai file.
            pause > nul
            exit /b
        )
    ) ELSE (
        ECHO winget khong ton tai. Vui long cai dat Python 3 thu cong va them vao PATH.
        ECHO Link tai: https://www.python.org/downloads/
        pause
        exit /b
    )
)


REM Kiem tra Tesseract OCR
set "TESSERACT_DIR=%~dp0Tesseract-OCR"
if not exist "%TESSERACT_DIR%\tesseract.exe" (
    ECHO [-] Tesseract OCR chua duoc cai dat.
    ECHO [*] Vui long tai ve thu cong tu GitHub releases.
    pause
    goto MENU
) else (
    ECHO [+] Da tim thay Tesseract OCR
)

ECHO.
ECHO [+] Tat ca phan mem can thiet da san sang.
timeout /t 2 >nul
goto MENU

:START_BOT
cls
echo ======================================
echo          KHOI DONG UMA BOT
echo ======================================
echo.
echo [*] Dang khoi dong bot...
python main.py
echo.
echo [*] Bot da dung. Nhan phim bat ky de tro ve menu.
pause >nul
goto MENU

:UPDATE
cls
echo ======================================
echo        CAP NHAT TU GITHUB
echo ======================================
echo.
echo [*] Bo qua theo doi file config.json...
git update-index --assume-unchanged config.json

echo.
echo [*] Dang cap nhat tu Git...
git pull
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [-] Cap nhat that bai!
    timeout /t 2 >nul
    goto MENU
)
echo [+] Cap nhat thanh cong!
timeout /t 2 >nul
goto MENU

:INSTALL_DEPS
cls
echo ======================================
echo      CAI DAT GOI PHU THUOC
echo ======================================
echo.
echo [*] Dang cai dat tu requirements.txt...
pip install -r requirements.txt
echo.
echo [+] Cai dat hoan tat!
timeout /t 2 >nul
goto MENU

:BACKUP_CONFIG
cls
echo ======================================
echo         SAO LUU CONFIG
echo ======================================
echo.
if not exist "backups" mkdir backups
copy /y config.json "backups\config_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.json" >nul
echo [+] Da sao luu config.json!
timeout /t 2 >nul
goto MENU

:RESTORE_CONFIG
cls
echo ======================================
echo        KHOI PHUC CONFIG
echo ======================================
echo.
if not exist "backups\*.json" (
    echo [-] Khong tim thay ban sao luu!
    timeout /t 2 >nul
    goto MENU
)
echo Cac ban sao luu hien co:
echo.
dir /b "backups\*.json"
echo.
set /p "backup=Nhap ten file muon khoi phuc (hoac ENTER de huy): "
if "%backup%"=="" goto MENU
if not exist "backups\%backup%" (
    echo [-] Khong tim thay file!
    timeout /t 2 >nul
    goto MENU
)
copy /y "backups\%backup%" config.json >nul
echo [+] Da khoi phuc config tu ban sao %backup%
timeout /t 2 >nul
goto MENU
pause
exit /b

:RefreshEnv
    ECHO Dang nap lai bien moi truong PATH...
    set "KEY_USER=HKCU\Environment"
    set "KEY_MACHINE=HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
    
    for /f "tokens=2,*" %%a in ('reg query "%KEY_USER%" /v Path 2^>nul') do set "USER_PATH=%%b"
    for /f "tokens=2,*" %%a in ('reg query "%KEY_MACHINE%" /v Path 2^>nul') do set "SYSTEM_PATH=%%b"
    
    set "PATH=%USER_PATH%;%SYSTEM_PATH%"
    ECHO Nap lai PATH hoan tat.
goto :eof