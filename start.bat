@echo off
title Uma Musume Auto Train Launcher
color 0B

:MENU
cls
echo ======================================
echo    UMA MUSUME AUTO TRAIN AND EVENT HELPER OVERLAY
echo ======================================
echo.
echo [1] Khoi dong BOT Auto Training
echo [2] Khoi dong Event Helper Overlay    
echo [3] Cap nhat tu GitHub
echo [4] Cai dat/Cap nhat phu thuoc
echo [5] Sao luu config
echo [6] Khoi phuc config
echo [7] Kiem tra phan mem

echo [0] Thoat
echo.
echo ======================================

set /p choice="Nhap lua chon cua ban: "

if "%choice%"=="1" goto START_BOT
if "%choice%"=="2" goto START_EVENT_OVERLAY
if "%choice%"=="3" goto UPDATE
if "%choice%"=="4" goto INSTALL_DEPS
if "%choice%"=="5" goto BACKUP_CONFIG
if "%choice%"=="6" goto RESTORE_CONFIG
if "%choice%"=="7" goto CHECK_DEPS
if "%choice%"=="0" exit

echo.
echo Lua chon khong hop le!
timeout /t 2 >nul
goto MENU

:CHECK_DEPS
cls
echo ======================================
echo       KIEM TRA PYTHON
echo ======================================
echo.

REM Kiem tra Python
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [+] Da tim thay Python
    goto CHECK_PYTHON_SUCCESS
)

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [+] Da tim thay Python Launcher
    goto CHECK_PYTHON_SUCCESS
)

echo [-] Python chua duoc cai dat
echo [*] Dang tim phuong thuc cai dat tu dong...

where winget >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [-] Khong tim thay winget
    echo [*] Vui long cai dat Python 3 thu cong va them vao PATH
    echo [*] Link tai: https://www.python.org/downloads/
    pause
    goto MENU
)

echo [+] Da tim thay winget
echo [*] Dang thu cai dat Python bang winget...
winget install --id Python.Python.3 -e --source winget --silent --accept-source-agreements --accept-package-agreements

if %ERRORLEVEL% NEQ 0 (
    echo [-] Cai dat Python that bai
    echo [*] Vui long cai dat thu cong roi chay lai
    pause
    goto MENU
)

echo [+] Cai dat Python thanh cong
echo [*] Dang nap lai PATH...
call :RefreshEnv
powershell -Command "& {$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')}"

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 goto CHECK_PYTHON_SUCCESS

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 goto CHECK_PYTHON_SUCCESS

echo [-] Khong the tu dong nap lai PATH
echo [*] Vui long khoi dong lai may tinh va chay lai file nay
pause
goto MENU

:CHECK_PYTHON_SUCCESS


ECHO.
ECHO [+] Python da san sang de su dung.
timeout /t 2 >nul
goto MENU

:START_BOT
cls
echo ======================================
echo          KHOI DONG UMA BOT
echo ======================================
echo.
echo [*] Dang kiem tra Python...

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python...
    python main.py
    goto START_BOT_END
)

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python Launcher...
    py main.py
    goto START_BOT_END
)

echo [-] Khong tim thay Python! Hay chay chuc nang [6] de cai dat Python.
pause >nul
goto MENU

:START_BOT_END
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
echo [*] Mo PowerShell voi quyen Admin de cai dat...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', '$pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source; if (-not $pythonPath) { $pythonPath = (Get-Command py -ErrorAction SilentlyContinue).Source }; if ($pythonPath) { Write-Host ''Tim thay Python tai: $pythonPath''; Set-Location ''%~dp0''; Write-Host ''Dang cai dat cac goi phu thuoc...''; if ($pythonPath -like ''*\py.exe'') { py -m pip install -r requirements.txt } else { python -m pip install -r requirements.txt } } else { Write-Host ''Khong tim thay Python. Hay chay chuc nang [6] Kiem tra phan mem truoc.''; pause }'"
echo.
echo [+] Da mo PowerShell de cai dat. Vui long doi cho qua trinh cai dat hoan tat.
echo [*] Dong cua so PowerShell sau khi cai dat xong.
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

:START_EVENT_OVERLAY
cls
echo ======================================
echo       KHOI DONG EVENT OVERLAY
echo ======================================
echo.
echo [*] Dang kiem tra Python...

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python...
    python utils/event_overlay.py
    goto START_EVENT_OVERLAY_END
)

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python Launcher...
    py utils/event_overlay.py
    goto START_EVENT_OVERLAY_END
)

echo [-] Khong tim thay Python! Hay chay chuc nang [6] de cai dat Python.
pause >nul
goto MENU

:START_EVENT_OVERLAY_END
echo.
echo [*] Event Overlay da dung. Nhan phim bat ky de tro ve menu.
pause >nul
goto MENU

:RefreshEnv
    ECHO Dang nap lai bien moi truong PATH...
    set "KEY_USER=HKCU\Environment"
    set "KEY_MACHINE=HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
    
    for /f "tokens=2,*" %%a in ('reg query "%KEY_USER%" /v Path 2^>nul') do set "USER_PATH=%%b"
    for /f "tokens=2,*" %%a in ('reg query "%KEY_MACHINE%" /v Path 2^>nul') do set "SYSTEM_PATH=%%b"
    
    set "PATH=%USER_PATH%;%SYSTEM_PATH%"
    ECHO Nap lai PATH hoan tat.
goto :eof