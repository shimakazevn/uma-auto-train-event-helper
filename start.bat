@echo off
title Uma Musume Auto Train Launcher
color 0B

:LANGUAGE_SELECTION
cls
echo ======================================
echo         LANGUAGE SELECTION
echo ======================================
echo.
echo [1] English
echo [2] Tieng Viet
echo.
echo ======================================
set /p lang_choice="Choose language / Chon ngon ngu: "

if "%lang_choice%"=="1" (
    set LANGUAGE=en
    goto MAIN_MENU_EN
) else if "%lang_choice%"=="2" (
    set LANGUAGE=vi
    goto MAIN_MENU_VI
) else (
    echo Invalid choice / Lua chon khong hop le!
    timeout /t 2 >nul
    goto LANGUAGE_SELECTION
)

:MAIN_MENU_EN
cls
echo ======================================
echo    UMA MUSUME AUTO TRAIN AND EVENT HELPER OVERLAY
echo ======================================
echo.
echo [1] Start BOT Auto Training
echo [2] Start Event Helper Overlay    
echo [3] Verify/Update Core (Git, Python)
echo [4] Backup config
echo [5] Restore config
echo [0] Exit
echo.
echo ======================================

set /p choice="Enter your choice: "

if "%choice%"=="1" goto START_BOT_EN
if "%choice%"=="2" goto START_EVENT_OVERLAY_EN
if "%choice%"=="3" goto VERIFY_UPDATE_CORE_EN
if "%choice%"=="4" goto BACKUP_CONFIG_EN
if "%choice%"=="5" goto RESTORE_CONFIG_EN
if "%choice%"=="0" exit

echo.
echo Invalid choice!
timeout /t 2 >nul
goto MAIN_MENU_EN

:MAIN_MENU_VI
cls
echo ======================================
echo    UMA MUSUME AUTO TRAIN AND EVENT HELPER OVERLAY
echo ======================================
echo.
echo [1] Khoi dong BOT Auto Training
echo [2] Khoi dong Event Helper Overlay    
echo [3] Verify/Update Core (Git, Python)
echo [4] Sao luu config
echo [5] Khoi phuc config
echo [0] Thoat
echo.
echo ======================================

set /p choice="Nhap lua chon cua ban: "

if "%choice%"=="1" goto START_BOT_VI
if "%choice%"=="2" goto START_EVENT_OVERLAY_VI
if "%choice%"=="3" goto VERIFY_UPDATE_CORE_VI
if "%choice%"=="4" goto BACKUP_CONFIG_VI
if "%choice%"=="5" goto RESTORE_CONFIG_VI
if "%choice%"=="0" exit

echo.
echo Lua chon khong hop le!
timeout /t 2 >nul
goto MAIN_MENU_VI

:VERIFY_UPDATE_CORE
cls
echo ======================================
echo       VERIFY/UPDATE CORE
echo ======================================
echo.
echo [*] Dang kiem tra he thong...

REM Kiem tra Python
echo.
echo [1] Kiem tra Python...
powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Python: OK
    set PYTHON_OK=1
) else (
    echo [-] Python: NOT FOUND
    set PYTHON_OK=0
)

REM Kiem tra Git
echo.
echo [2] Kiem tra Git...
powershell -Command "if (Get-Command git -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Git: OK
    set GIT_OK=1
) else (
    echo [-] Git: NOT FOUND
    set GIT_OK=0
)

echo.
echo ======================================
echo           KET QUA KIEM TRA
echo ======================================
if "%PYTHON_OK%"=="1" (
    echo [+] Python: San sang
) else (
    echo [-] Python: Can cai dat
)
if "%GIT_OK%"=="1" (
    echo [+] Git: San sang
) else (
    echo [-] Git: Can cai dat
)
echo.

REM Hoi nguoi dung co muon cap nhat khong
echo Ban co muon:
echo [1] Cap nhat tu GitHub (neu Git OK)
echo [2] Cai dat Python (neu Python chua co)
echo [3] Cai dat Git (neu Git chua co)
echo [4] Cai dat cac goi phu thuoc
echo [0] Tro ve menu
echo.
set /p update_choice="Nhap lua chon: "

if "%update_choice%"=="1" goto UPDATE_GIT
if "%update_choice%"=="2" goto INSTALL_PYTHON
if "%update_choice%"=="3" goto INSTALL_GIT
if "%update_choice%"=="4" goto INSTALL_DEPS
if "%update_choice%"=="0" goto MENU

echo Lua chon khong hop le!
timeout /t 2 >nul
goto VERIFY_UPDATE_CORE

:UPDATE_GIT
if "%GIT_OK%"=="0" (
    echo [-] Git chua duoc cai dat!
    echo [*] Vui long cai dat Git truoc: https://git-scm.com/
    pause
    goto VERIFY_UPDATE_CORE
)
echo.
echo [*] Dang cap nhat tu GitHub...
git update-index --assume-unchanged config.json
git pull
if %ERRORLEVEL% EQU 0 (
    echo [+] Cap nhat thanh cong!
) else (
    echo [-] Cap nhat that bai!
)
timeout /t 2 >nul
goto VERIFY_UPDATE_CORE

:INSTALL_PYTHON
echo.
echo [*] Dang cai dat Python...

REM Kiem tra winget
powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo [-] Khong tim thay winget
    echo [*] Dang sua winget...
    powershell -Command "Install-PackageProvider -Name NuGet -Force | Out-Null; Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null; Repair-WinGetPackageManager"
    echo [+] Da sua winget, dang thu lai...
    
    REM Kiem tra lai winget
    powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
    if %ERRORLEVEL% NEQ 0 (
        echo [-] Khong the sua winget
        echo [*] Dang thu cach khac...
        goto TRY_CHOCOLATEY
    )
)

echo [+] Dang cai dat Python bang winget...
powershell -Command "winget install --id Python.Python.3.12 -e --source winget --silent --accept-source-agreements --accept-package-agreements"
if %ERRORLEVEL% EQU 0 (
    echo [+] Cai dat Python thanh cong bang winget!
    echo [*] Vui long khoi dong lai may tinh de hoan tat cai dat
) else (
    echo [-] Cai dat Python bang winget that bai!
    echo [*] Thu cai dat bang Chocolatey...
    goto TRY_CHOCOLATEY
)

echo.
echo [*] Sau khi cai dat xong, vui long:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE

:TRY_CHOCOLATEY
REM Thu kiem tra chocolatey
where choco >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [+] Tim thay Chocolatey, dang cai dat Python...
    choco install python -y
    if %ERRORLEVEL% EQU 0 (
        echo [+] Cai dat Python thanh cong bang Chocolatey!
        echo [*] Vui long khoi dong lai may tinh de hoan tat cai dat
    ) else (
        echo [-] Cai dat Python bang Chocolatey that bai!
        goto MANUAL_PYTHON_INSTALL
    )
) else (
    echo [-] Khong tim thay Chocolatey
    goto MANUAL_PYTHON_INSTALL
)

echo.
echo [*] Sau khi cai dat xong, vui long:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE

:MANUAL_PYTHON_INSTALL
echo.
echo ======================================
echo        CAI DAT PYTHON THU CONG
echo ======================================
echo.
echo [-] Khong the cai dat Python tu dong
echo [*] Vui long cai dat Python thu cong:
echo.
echo [1] Truy cap: https://www.python.org/downloads/
echo [2] Tai Python 3.8 hoac cao hon
echo [3] Chay installer voi "Add Python to PATH" checked
echo [4] Khoi dong lai may tinh
echo [5] Chay lai start.bat va chon option [3]
echo.
echo [*] Hoac cai dat Chocolatey tu dong:
echo [1] Tu dong cai dat Chocolatey (khuyen dung)
echo [2] Cai dat Python thu cong
echo [0] Tro ve menu
echo.
set /p choco_choice="Nhap lua chon: "
if "%choco_choice%"=="1" goto INSTALL_CHOCOLATEY
if "%choco_choice%"=="2" goto MANUAL_PYTHON_GUIDE
if "%choco_choice%"=="0" goto MENU
echo Lua chon khong hop le!
timeout /t 2 >nul
goto MANUAL_PYTHON_INSTALL

:INSTALL_CHOCOLATEY
echo.
echo [*] Dang cai dat Chocolatey...
echo [+] Mo PowerShell voi quyen Admin de cai dat Chocolatey...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Dang cai dat Chocolatey...\" -ForegroundColor Green; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1'')); Write-Host \"Chocolatey da duoc cai dat thanh cong!\" -ForegroundColor Green; Write-Host \"Dang cai dat Python...\" -ForegroundColor Yellow; choco install python -y; Write-Host \"Python da duoc cai dat thanh cong!\" -ForegroundColor Green; Write-Host \"Vui long khoi dong lai may tinh de hoan tat.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Da mo PowerShell de cai dat Chocolatey va Python.
echo [*] Vui long doi cho qua trinh cai dat hoan tat.
echo [*] Dong cua so PowerShell sau khi cai dat xong.
echo.
echo [*] Sau khi cai dat xong:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE

:MANUAL_PYTHON_GUIDE
echo.
echo ======================================
echo     HUONG DAN CAI DAT PYTHON
echo ======================================
echo.
echo [1] Truy cap: https://www.python.org/downloads/
echo [2] Nhan "Download Python 3.x.x"
echo [3] Chay file installer vua tai
echo [4] TICK VAO "Add Python to PATH"
echo [5] Nhan "Install Now"
echo [6] Doi cai dat xong
echo [7] Khoi dong lai may tinh
echo [8] Chay lai start.bat va chon option [3]
echo.
echo [*] Lưu ý: Phải tick vào "Add Python to PATH"!
echo.
pause
goto VERIFY_UPDATE_CORE

:INSTALL_DEPS
echo.
echo [*] Dang cai dat cac goi phu thuoc...
if "%PYTHON_OK%"=="0" (
    echo [-] Python chua duoc cai dat!
    echo [*] Vui long cai dat Python truoc
    echo.
    echo Ban co muon:
    echo [1] Cai dat Python ngay bay gio
    echo [2] Tro ve menu chinh
    echo.
    set /p python_choice="Nhap lua chon: "
    if "!python_choice!"=="1" goto INSTALL_PYTHON
    if "!python_choice!"=="2" goto MENU
    echo Lua chon khong hop le!
    timeout /t 2 >nul
    goto VERIFY_UPDATE_CORE
)

echo [+] Python da san sang, dang cai dat cac goi phu thuoc...
echo [+] Mo PowerShell voi quyen Admin de cai dat...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', '$pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source; if (-not $pythonPath) { $pythonPath = (Get-Command py -ErrorAction SilentlyContinue).Source }; if ($pythonPath) { Write-Host ''Tim thay Python tai: $pythonPath''; Set-Location ''%~dp0''; Write-Host ''Dang cai dat cac goi phu thuoc...''; if ($pythonPath -like ''*\py.exe'') { py -m pip install -r requirements.txt } else { python -m pip install -r requirements.txt } } else { Write-Host ''Khong tim thay Python. Hay cai dat Python truoc.''; pause }'"
echo.
echo [+] Da mo PowerShell de cai dat. Vui long doi cho qua trinh cai dat hoan tat.
echo [*] Dong cua so PowerShell sau khi cai dat xong.
echo.
echo [*] Sau khi cai dat xong, ban co the:
echo [1] Chay lai start.bat
echo [2] Chon option [1] hoac [2] de su dung bot/overlay
echo.
pause
goto VERIFY_UPDATE_CORE

:START_BOT
cls
echo ======================================
echo          KHOI DONG UMA BOT
echo ======================================
echo.
echo [*] Dang kiem tra Python...

powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python...
    python main.py
    goto START_BOT_END
)

powershell -Command "if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python Launcher...
    py main.py
    goto START_BOT_END
)

echo [-] Khong tim thay Python! Hay chay chuc nang [3] de kiem tra va cai dat Python.
pause >nul
goto MENU

:START_BOT_END
echo.
echo [*] Bot da dung. Nhan phim bat ky de tro ve menu.
pause >nul
goto MENU

:START_EVENT_OVERLAY
cls
echo ======================================
echo       KHOI DONG EVENT OVERLAY
echo ======================================
echo.
echo [*] Dang kiem tra Python...

powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python...
    python utils/event_overlay.py
    goto START_EVENT_OVERLAY_END
)

powershell -Command "if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python Launcher...
    py utils/event_overlay.py
    goto START_EVENT_OVERLAY_END
)

echo [-] Khong tim thay Python! Hay chay chuc nang [3] de kiem tra va cai dat Python.
pause >nul
goto MENU

:START_EVENT_OVERLAY_END
echo.
echo [*] Event Overlay da dung. Nhan phim bat ky de tro ve menu.
pause >nul
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

:RefreshEnv
    ECHO Dang nap lai bien moi truong PATH...
    set "KEY_USER=HKCU\Environment"
    set "KEY_MACHINE=HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
    
    for /f "tokens=2,*" %%a in ('reg query "%KEY_USER%" /v Path 2^>nul') do set "USER_PATH=%%b"
    for /f "tokens=2,*" %%a in ('reg query "%KEY_MACHINE%" /v Path 2^>nul') do set "SYSTEM_PATH=%%b"
    
    set "PATH=%USER_PATH%;%SYSTEM_PATH%"
    ECHO Nap lai PATH hoan tat.
goto :eof

:VERIFY_UPDATE_CORE_VI
cls
echo ======================================
echo       VERIFY/UPDATE CORE
echo ======================================
echo.
echo [*] Dang kiem tra he thong...

REM Kiem tra Python
echo.
echo [1] Kiem tra Python...
powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Python: OK
    set PYTHON_OK=1
) else (
    echo [-] Python: NOT FOUND
    set PYTHON_OK=0
)

REM Kiem tra Git
echo.
echo [2] Kiem tra Git...
powershell -Command "if (Get-Command git -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Git: OK
    set GIT_OK=1
) else (
    echo [-] Git: NOT FOUND
    set GIT_OK=0
)

echo.
echo ======================================
echo           KET QUA KIEM TRA
echo ======================================
if "%PYTHON_OK%"=="1" (
    echo [+] Python: San sang
) else (
    echo [-] Python: Can cai dat
)
if "%GIT_OK%"=="1" (
    echo [+] Git: San sang
) else (
    echo [-] Git: Can cai dat
)
echo.

REM Hoi nguoi dung co muon cap nhat khong
echo Ban co muon:
echo [1] Cap nhat tu GitHub (neu Git OK)
echo [2] Cai dat Python (neu Python chua co)
echo [3] Cai dat Git (neu Git chua co)
echo [4] Cai dat cac goi phu thuoc
echo [0] Tro ve menu
echo.
set /p update_choice="Nhap lua chon: "

if "%update_choice%"=="1" goto UPDATE_GIT_VI
if "%update_choice%"=="2" goto INSTALL_PYTHON_VI
if "%update_choice%"=="3" goto INSTALL_GIT_VI
if "%update_choice%"=="4" goto INSTALL_DEPS_VI
if "%update_choice%"=="0" goto MAIN_MENU_VI

echo Lua chon khong hop le!
timeout /t 2 >nul
goto VERIFY_UPDATE_CORE_VI

:UPDATE_GIT_VI
if "%GIT_OK%"=="0" (
    echo [-] Git chua duoc cai dat!
    echo [*] Vui long cai dat Git truoc: https://git-scm.com/
    pause
    goto VERIFY_UPDATE_CORE_VI
)
echo.
echo [*] Dang cap nhat tu GitHub...
git update-index --assume-unchanged config.json
git pull
if %ERRORLEVEL% EQU 0 (
    echo [+] Cap nhat thanh cong!
) else (
    echo [-] Cap nhat that bai!
)
timeout /t 2 >nul
goto VERIFY_UPDATE_CORE_VI

:INSTALL_PYTHON_VI
echo.
echo [*] Dang cai dat Python...

REM Kiem tra Python da cai dat chua
powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Python da duoc cai dat roi!
    echo [*] Phiên bản Python:
    python --version 2>nul
    if %ERRORLEVEL% NEQ 0 (
        py --version 2>nul
    )
    echo.
    echo [*] Python da san sang su dung.
    echo [*] Ban co the:
    echo [1] Cai dat cac goi phu thuoc (option 3)
    echo [2] Khoi dong bot (option 1)
    echo [3] Khoi dong event overlay (option 2)
    echo.
    pause
    goto VERIFY_UPDATE_CORE_VI
)

REM Kiem tra winget
powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo [-] Khong tim thay winget
    echo [*] Dang sua winget...
    powershell -Command "Install-PackageProvider -Name NuGet -Force | Out-Null; Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null; Repair-WinGetPackageManager"
    echo [+] Da sua winget, dang thu lai...
    
    REM Kiem tra lai winget
    powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
    if %ERRORLEVEL% NEQ 0 (
        echo [-] Khong the sua winget
        echo [*] Dang thu cach khac...
        goto TRY_CHOCOLATEY_VI
    )
)

echo [+] Dang cai dat Python bang winget...
powershell -Command "winget install --id Python.Python.3.12 -e --source winget --silent --accept-source-agreements --accept-package-agreements"
if %ERRORLEVEL% EQU 0 (
    echo [+] Cai dat Python thanh cong bang winget!
    echo [*] Vui long khoi dong lai may tinh de hoan tat cai dat
) else (
    echo [-] Cai dat Python bang winget that bai!
    echo [*] Thu cai dat bang Chocolatey...
    goto TRY_CHOCOLATEY_VI
)

echo.
echo [*] Sau khi cai dat xong, vui long:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:TRY_CHOCOLATEY_VI
REM Thu chocolatey voi quyen admin
echo [*] Dang thu Chocolatey voi quyen admin...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Dang cai dat Python voi Chocolatey...\" -ForegroundColor Green; choco install python -y; Write-Host \"Cai dat Python hoan tat!\" -ForegroundColor Green; Write-Host \"Vui long khoi dong lai may tinh de hoan tat.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Da mo PowerShell voi quyen admin de cai dat Python.
echo [*] Vui long doi cho qua trinh cai dat hoan tat.
echo [*] Dong cua so PowerShell sau khi cai dat xong.
echo.
echo [*] Sau khi cai dat xong:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:MANUAL_PYTHON_INSTALL_VI
echo.
echo ======================================
echo        CAI DAT PYTHON THU CONG
echo ======================================
echo.
echo [-] Khong the cai dat Python tu dong
echo [*] Vui long cai dat Python thu cong:
echo.
echo [1] Truy cap: https://www.python.org/downloads/
echo [2] Tai Python 3.8 hoac cao hon
echo [3] Chay installer voi "Add Python to PATH" checked
echo [4] Khoi dong lai may tinh
echo [5] Chay lai start.bat va chon option [3]
echo.
echo [*] Hoac cai dat Chocolatey tu dong:
echo [1] Tu dong cai dat Chocolatey (khuyen dung)
echo [2] Cai dat Python thu cong
echo [0] Tro ve menu
echo.
set /p choco_choice="Nhap lua chon: "
if "%choco_choice%"=="1" goto INSTALL_CHOCOLATEY_VI
if "%choco_choice%"=="2" goto MANUAL_PYTHON_GUIDE_VI
if "%choco_choice%"=="0" goto MAIN_MENU_VI
echo Lua chon khong hop le!
timeout /t 2 >nul
goto MANUAL_PYTHON_INSTALL_VI

:INSTALL_CHOCOLATEY_VI
echo.
echo [*] Dang cai dat Chocolatey...
echo [+] Mo PowerShell voi quyen Admin de cai dat Chocolatey...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Dang cai dat Chocolatey...\" -ForegroundColor Green; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1'')); Write-Host \"Chocolatey da duoc cai dat thanh cong!\" -ForegroundColor Green; Write-Host \"Dang cai dat Python...\" -ForegroundColor Yellow; choco install python -y; Write-Host \"Python da duoc cai dat thanh cong!\" -ForegroundColor Green; Write-Host \"Vui long khoi dong lai may tinh de hoan tat.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Da mo PowerShell de cai dat Chocolatey va Python.
echo [*] Vui long doi cho qua trinh cai dat hoan tat.
echo [*] Dong cua so PowerShell sau khi cai dat xong.
echo.
echo [*] Sau khi cai dat xong:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:MANUAL_PYTHON_GUIDE_VI
echo.
echo ======================================
echo     HUONG DAN CAI DAT PYTHON
echo ======================================
echo.
echo [1] Truy cap: https://www.python.org/downloads/
echo [2] Nhan "Download Python 3.x.x"
echo [3] Chay file installer vua tai
echo [4] TICK VAO "Add Python to PATH"
echo [5] Nhan "Install Now"
echo [6] Doi cai dat xong
echo [7] Khoi dong lai may tinh
echo [8] Chay lai start.bat va chon option [3]
echo.
echo [*] Lưu ý: Phải tick vào "Add Python to PATH"!
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:INSTALL_GIT_VI
echo.
echo [*] Dang cai dat Git...

REM Kiem tra Git da cai dat chua
powershell -Command "if (Get-Command git -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Git da duoc cai dat roi!
    echo [*] Phiên bản Git:
    git --version 2>nul
    echo.
    echo [*] Git da san sang su dung.
    echo [*] Ban co the:
    echo [1] Cap nhat tu GitHub (option 1)
    echo [2] Cai dat cac goi phu thuoc (option 4)
    echo.
    pause
    goto VERIFY_UPDATE_CORE_VI
)

REM Kiem tra winget
powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo [-] Khong tim thay winget
    echo [*] Dang sua winget...
    powershell -Command "Install-PackageProvider -Name NuGet -Force | Out-Null; Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null; Repair-WinGetPackageManager"
    echo [+] Da sua winget, dang thu lai...
    
    REM Kiem tra lai winget
    powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
    if %ERRORLEVEL% NEQ 0 (
        echo [-] Khong the sua winget
        echo [*] Dang thu cach khac...
        goto TRY_CHOCOLATEY_GIT_VI
    )
)

echo [+] Dang cai dat Git bang winget...
powershell -Command "winget install --id Git.Git -e --source winget --silent --accept-source-agreements --accept-package-agreements"
if %ERRORLEVEL% EQU 0 (
    echo [+] Cai dat Git thanh cong bang winget!
    echo [*] Vui long khoi dong lai may tinh de hoan tat cai dat
) else (
    echo [-] Cai dat Git bang winget that bai!
    echo [*] Thu cai dat bang Chocolatey...
    goto TRY_CHOCOLATEY_GIT_VI
)

echo.
echo [*] Sau khi cai dat xong, vui long:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:TRY_CHOCOLATEY_GIT_VI
REM Thu chocolatey voi quyen admin
echo [*] Dang thu Chocolatey voi quyen admin...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Dang cai dat Git voi Chocolatey...\" -ForegroundColor Green; choco install git -y; Write-Host \"Cai dat Git hoan tat!\" -ForegroundColor Green; Write-Host \"Vui long khoi dong lai may tinh de hoan tat.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Da mo PowerShell voi quyen admin de cai dat Git.
echo [*] Vui long doi cho qua trinh cai dat hoan tat.
echo [*] Dong cua so PowerShell sau khi cai dat xong.
echo.
echo [*] Sau khi cai dat xong:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:MANUAL_GIT_INSTALL_VI
echo.
echo ======================================
echo        CAI DAT GIT THU CONG
echo ======================================
echo.
echo [-] Khong the cai dat Git tu dong
echo [*] Vui long cai dat Git thu cong:
echo.
echo [1] Truy cap: https://git-scm.com/download/win
echo [2] Tai Git for Windows
echo [3] Chay installer voi "Git from the command line and also from 3rd-party software" selected
echo [4] Khoi dong lai may tinh
echo [5] Chay lai start.bat va chon option [3]
echo.
echo [*] Hoac cai dat Chocolatey tu dong:
echo [1] Tu dong cai dat Chocolatey (khuyen dung)
echo [2] Cai dat Git thu cong
echo [0] Tro ve menu
echo.
set /p choco_choice="Nhap lua chon: "
if "%choco_choice%"=="1" goto INSTALL_CHOCOLATEY_GIT_VI
if "%choco_choice%"=="2" goto MANUAL_GIT_GUIDE_VI
if "%choco_choice%"=="0" goto MAIN_MENU_VI
echo Lua chon khong hop le!
timeout /t 2 >nul
goto MANUAL_GIT_INSTALL_VI

:INSTALL_CHOCOLATEY_GIT_VI
echo.
echo [*] Dang cai dat Chocolatey...
echo [+] Mo PowerShell voi quyen Admin de cai dat Chocolatey...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Dang cai dat Chocolatey...\" -ForegroundColor Green; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1'')); Write-Host \"Chocolatey da duoc cai dat thanh cong!\" -ForegroundColor Green; Write-Host \"Dang cai dat Git...\" -ForegroundColor Yellow; choco install git -y; Write-Host \"Git da duoc cai dat thanh cong!\" -ForegroundColor Green; Write-Host \"Vui long khoi dong lai may tinh de hoan tat.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Da mo PowerShell de cai dat Chocolatey va Git.
echo [*] Vui long doi cho qua trinh cai dat hoan tat.
echo [*] Dong cua so PowerShell sau khi cai dat xong.
echo.
echo [*] Sau khi cai dat xong:
echo [1] Khoi dong lai may tinh
echo [2] Chay lai start.bat
echo [3] Chon option [3] de kiem tra lai
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:MANUAL_GIT_GUIDE_VI
echo.
echo ======================================
echo     HUONG DAN CAI DAT GIT
echo ======================================
echo.
echo [1] Truy cap: https://git-scm.com/download/win
echo [2] Nhan "Click here to download"
echo [3] Chay file installer vua tai
echo [4] Chon "Git from the command line and also from 3rd-party software"
echo [5] Nhan "Next" cho den khi xong
echo [6] Doi cai dat xong
echo [7] Khoi dong lai may tinh
echo [8] Chay lai start.bat va chon option [3]
echo.
echo [*] Lưu ý: Chọn "Git from the command line and also from 3rd-party software"!
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:INSTALL_DEPS_VI
echo.
echo [*] Dang cai dat cac goi phu thuoc...
if "%PYTHON_OK%"=="0" (
    echo [-] Python chua duoc cai dat!
    echo [*] Vui long cai dat Python truoc
    echo.
    echo Ban co muon:
    echo [1] Cai dat Python ngay bay gio
    echo [2] Tro ve menu chinh
    echo.
    set /p python_choice="Nhap lua chon: "
    if "!python_choice!"=="1" goto INSTALL_PYTHON_VI
    if "!python_choice!"=="2" goto MAIN_MENU_VI
    echo Lua chon khong hop le!
    timeout /t 2 >nul
    goto VERIFY_UPDATE_CORE_VI
)

echo [+] Python da san sang, dang cai dat cac goi phu thuoc...
echo [+] Mo PowerShell voi quyen Admin de cai dat...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', '$pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source; if (-not $pythonPath) { $pythonPath = (Get-Command py -ErrorAction SilentlyContinue).Source }; if ($pythonPath) { Write-Host ''Tim thay Python tai: $pythonPath''; Set-Location ''%~dp0''; Write-Host ''Dang cai dat cac goi phu thuoc...''; if ($pythonPath -like ''*\py.exe'') { py -m pip install -r requirements.txt } else { python -m pip install -r requirements.txt } } else { Write-Host ''Khong tim thay Python. Hay cai dat Python truoc.''; pause }'"
echo.
echo [+] Da mo PowerShell de cai dat. Vui long doi cho qua trinh cai dat hoan tat.
echo [*] Dong cua so PowerShell sau khi cai dat xong.
echo.
echo [*] Sau khi cai dat xong, ban co the:
echo [1] Chay lai start.bat
echo [2] Chon option [1] hoac [2] de su dung bot/overlay
echo.
pause
goto VERIFY_UPDATE_CORE_VI

:START_BOT_VI
cls
echo ======================================
echo          KHOI DONG UMA BOT
echo ======================================
echo.
echo [*] Dang kiem tra Python...

powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python...
    python main.py
    goto START_BOT_END_VI
)

powershell -Command "if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python Launcher...
    py main.py
    goto START_BOT_END_VI
)

echo [-] Khong tim thay Python! Hay chay chuc nang [3] de kiem tra va cai dat Python.
pause >nul
goto MAIN_MENU_VI

:START_BOT_END_VI
echo.
echo [*] Bot da dung. Nhan phim bat ky de tro ve menu.
pause >nul
goto MAIN_MENU_VI

:START_EVENT_OVERLAY_VI
cls
echo ======================================
echo       KHOI DONG EVENT OVERLAY
echo ======================================
echo.
echo [*] Dang kiem tra Python...

powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python...
    python utils/event_overlay.py
    goto START_EVENT_OVERLAY_END_VI
)

powershell -Command "if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Su dung Python Launcher...
    py utils/event_overlay.py
    goto START_EVENT_OVERLAY_END_VI
)

echo [-] Khong tim thay Python! Hay chay chuc nang [3] de kiem tra va cai dat Python.
pause >nul
goto MAIN_MENU_VI

:START_EVENT_OVERLAY_END_VI
echo.
echo [*] Event Overlay da dung. Nhan phim bat ky de tro ve menu.
pause >nul
goto MAIN_MENU_VI

:BACKUP_CONFIG_VI
cls
echo ======================================
echo         SAO LUU CONFIG
echo ======================================
echo.
if not exist "backups" mkdir backups
copy /y config.json "backups\config_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.json" >nul
echo [+] Da sao luu config.json!
timeout /t 2 >nul
goto MAIN_MENU_VI

:RESTORE_CONFIG_VI
cls
echo ======================================
echo        KHOI PHUC CONFIG
echo ======================================
echo.
if not exist "backups\*.json" (
    echo [-] Khong tim thay ban sao luu!
    timeout /t 2 >nul
    goto MAIN_MENU_VI
)
echo Cac ban sao luu hien co:
echo.
dir /b "backups\*.json"
echo.
set /p "backup=Nhap ten file muon khoi phuc (hoac ENTER de huy): "
if "%backup%"=="" goto MAIN_MENU_VI
if not exist "backups\%backup%" (
    echo [-] Khong tim thay file!
    timeout /t 2 >nul
    goto MAIN_MENU_VI
)
copy /y "backups\%backup%" config.json >nul
echo [+] Da khoi phuc config tu ban sao %backup%
timeout /t 2 >nul
goto MAIN_MENU_VI

:VERIFY_UPDATE_CORE_EN
cls
echo ======================================
echo       VERIFY/UPDATE CORE
echo ======================================
echo.
echo [*] Checking system...

REM Check Python
echo.
echo [1] Checking Python...
powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Python: OK
    set PYTHON_OK=1
) else (
    echo [-] Python: NOT FOUND
    set PYTHON_OK=0
)

REM Check Git
echo.
echo [2] Checking Git...
powershell -Command "if (Get-Command git -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Git: OK
    set GIT_OK=1
) else (
    echo [-] Git: NOT FOUND
    set GIT_OK=0
)

echo.
echo ======================================
echo           CHECK RESULTS
echo ======================================
if "%PYTHON_OK%"=="1" (
    echo [+] Python: Ready
) else (
    echo [-] Python: Needs installation
)
if "%GIT_OK%"=="1" (
    echo [+] Git: Ready
) else (
    echo [-] Git: Needs installation
)
echo.

REM Ask user what they want to do
echo What would you like to do:
echo [1] Update from GitHub (if Git OK)
echo [2] Install Python (if Python not found)
echo [3] Install Git (if Git not found)
echo [4] Install dependencies
echo [0] Back to menu
echo.
set /p update_choice="Enter your choice: "

if "%update_choice%"=="1" goto UPDATE_GIT_EN
if "%update_choice%"=="2" goto INSTALL_PYTHON_EN
if "%update_choice%"=="3" goto INSTALL_GIT_EN
if "%update_choice%"=="4" goto INSTALL_DEPS_EN
if "%update_choice%"=="0" goto MAIN_MENU_EN

echo Invalid choice!
timeout /t 2 >nul
goto VERIFY_UPDATE_CORE_EN

:UPDATE_GIT_EN
if "%GIT_OK%"=="0" (
    echo [-] Git not installed!
    echo [*] Please install Git first: https://git-scm.com/
    pause
    goto VERIFY_UPDATE_CORE_EN
)
echo.
echo [*] Updating from GitHub...
git update-index --assume-unchanged config.json
git pull
if %ERRORLEVEL% EQU 0 (
    echo [+] Update successful!
) else (
    echo [-] Update failed!
)
timeout /t 2 >nul
goto VERIFY_UPDATE_CORE_EN

:INSTALL_PYTHON_EN
echo.
echo [*] Installing Python...

REM Check if Python is already installed
powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Python is already installed!
    echo [*] Python version:
    python --version 2>nul
    if %ERRORLEVEL% NEQ 0 (
        py --version 2>nul
    )
    echo.
    echo [*] Python is ready to use.
    echo [*] You can now:
    echo [1] Install dependencies (option 3)
    echo [2] Start bot (option 1)
    echo [3] Start event overlay (option 2)
    echo.
    pause
    goto VERIFY_UPDATE_CORE_EN
)

REM Check winget
powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo [-] Winget not found
    echo [*] Repairing winget...
    powershell -Command "Install-PackageProvider -Name NuGet -Force | Out-Null; Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null; Repair-WinGetPackageManager"
    echo [+] Winget repaired, testing again...
    
    REM Check winget again
    powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
    if %ERRORLEVEL% NEQ 0 (
        echo [-] Cannot repair winget
        echo [*] Trying alternative method...
        goto TRY_CHOCOLATEY_EN
    )
)

echo [+] Installing Python with winget...
powershell -Command "winget install --id Python.Python.3.12 -e --source winget --silent --accept-source-agreements --accept-package-agreements"
if %ERRORLEVEL% EQU 0 (
    echo [+] Python installed successfully with winget!
    echo [*] Please restart your computer to complete installation
) else (
    echo [-] Python installation with winget failed!
    echo [*] Trying Chocolatey...
    goto TRY_CHOCOLATEY_EN
)

echo.
echo [*] After installation, please:
echo [1] Restart your computer
echo [2] Run start.bat again
echo [3] Select option [3] to verify
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:TRY_CHOCOLATEY_EN
REM Try chocolatey with admin rights
echo [*] Trying Chocolatey with admin rights...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Installing Python with Chocolatey...\" -ForegroundColor Green; choco install python -y; Write-Host \"Python installation completed!\" -ForegroundColor Green; Write-Host \"Please restart your computer to complete.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Opened PowerShell with admin rights to install Python.
echo [*] Please wait for installation to complete.
echo [*] Close PowerShell window when installation is done.
echo.
echo [*] After installation:
echo [1] Restart your computer
echo [2] Run start.bat again
echo [3] Select option [3] to verify
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:MANUAL_PYTHON_INSTALL_EN
echo.
echo ======================================
echo        MANUAL PYTHON INSTALLATION
echo ======================================
echo.
echo [-] Cannot install Python automatically
echo [*] Please install Python manually:
echo.
echo [1] Visit: https://www.python.org/downloads/
echo [2] Download Python 3.8 or higher
echo [3] Run installer with "Add Python to PATH" checked
echo [4] Restart your computer
echo [5] Run start.bat again and select option [3]
echo.
echo [*] Or install Chocolatey automatically:
echo [1] Auto install Chocolatey (recommended)
echo [2] Manual Python installation
echo [0] Back to menu
echo.
set /p choco_choice="Enter your choice: "
if "%choco_choice%"=="1" goto INSTALL_CHOCOLATEY_EN
if "%choco_choice%"=="2" goto MANUAL_PYTHON_GUIDE_EN
if "%choco_choice%"=="0" goto MAIN_MENU_EN
echo Invalid choice!
timeout /t 2 >nul
goto MANUAL_PYTHON_INSTALL_EN

:INSTALL_CHOCOLATEY_EN
echo.
echo [*] Installing Chocolatey...
echo [+] Opening PowerShell with Admin rights to install Chocolatey...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Installing Chocolatey...\" -ForegroundColor Green; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1'')); Write-Host \"Chocolatey installed successfully!\" -ForegroundColor Green; Write-Host \"Installing Python...\" -ForegroundColor Yellow; choco install python -y; Write-Host \"Python installed successfully!\" -ForegroundColor Green; Write-Host \"Please restart your computer to complete.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Opened PowerShell to install Chocolatey and Python.
echo [*] Please wait for installation to complete.
echo [*] Close PowerShell window when installation is done.
echo.
echo [*] After installation:
echo [1] Restart your computer
echo [2] Run start.bat again
echo [3] Select option [3] to verify
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:MANUAL_PYTHON_GUIDE_EN
echo.
echo ======================================
echo     MANUAL PYTHON INSTALLATION GUIDE
echo ======================================
echo.
echo [1] Visit: https://www.python.org/downloads/
echo [2] Click "Download Python 3.x.x"
echo [3] Run the downloaded installer
echo [4] CHECK "Add Python to PATH"
echo [5] Click "Install Now"
echo [6] Wait for installation to complete
echo [7] Restart your computer
echo [8] Run start.bat again and select option [3]
echo.
echo [*] Important: Must check "Add Python to PATH"!
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:INSTALL_GIT_EN
echo.
echo [*] Installing Git...

REM Check if Git is already installed
powershell -Command "if (Get-Command git -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Git is already installed!
    echo [*] Git version:
    git --version 2>nul
    echo.
    echo [*] Git is ready to use.
    echo [*] You can now:
    echo [1] Update from GitHub (option 1)
    echo [2] Install dependencies (option 4)
    echo.
    pause
    goto VERIFY_UPDATE_CORE_EN
)

REM Check winget
powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo [-] Winget not found
    echo [*] Repairing winget...
    powershell -Command "Install-PackageProvider -Name NuGet -Force | Out-Null; Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null; Repair-WinGetPackageManager"
    echo [+] Winget repaired, testing again...
    
    REM Check winget again
    powershell -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
    if %ERRORLEVEL% NEQ 0 (
        echo [-] Cannot repair winget
        echo [*] Trying alternative method...
        goto TRY_CHOCOLATEY_GIT_EN
    )
)

echo [+] Installing Git with winget...
powershell -Command "winget install --id Git.Git -e --source winget --silent --accept-source-agreements --accept-package-agreements"
if %ERRORLEVEL% EQU 0 (
    echo [+] Git installed successfully with winget!
    echo [*] Please restart your computer to complete installation
) else (
    echo [-] Git installation with winget failed!
    echo [*] Trying Chocolatey...
    goto TRY_CHOCOLATEY_GIT_EN
)

echo.
echo [*] After installation, please:
echo [1] Restart your computer
echo [2] Run start.bat again
echo [3] Select option [3] to verify
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:TRY_CHOCOLATEY_GIT_EN
REM Try chocolatey with admin rights
echo [*] Trying Chocolatey with admin rights...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Installing Git with Chocolatey...\" -ForegroundColor Green; choco install git -y; Write-Host \"Git installation completed!\" -ForegroundColor Green; Write-Host \"Please restart your computer to complete.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Opened PowerShell with admin rights to install Git.
echo [*] Please wait for installation to complete.
echo [*] Close PowerShell window when installation is done.
echo.
echo [*] After installation:
echo [1] Restart your computer
echo [2] Run start.bat again
echo [3] Select option [3] to verify
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:MANUAL_GIT_INSTALL_EN
echo.
echo ======================================
echo        MANUAL GIT INSTALLATION
echo ======================================
echo.
echo [-] Cannot install Git automatically
echo [*] Please install Git manually:
echo.
echo [1] Visit: https://git-scm.com/download/win
echo [2] Download Git for Windows
echo [3] Run installer with "Git from the command line and also from 3rd-party software" selected
echo [4] Restart your computer
echo [5] Run start.bat again and select option [3]
echo.
echo [*] Or install Chocolatey automatically:
echo [1] Auto install Chocolatey (recommended)
echo [2] Manual Git installation
echo [0] Back to menu
echo.
set /p choco_choice="Enter your choice: "
if "%choco_choice%"=="1" goto INSTALL_CHOCOLATEY_GIT_EN
if "%choco_choice%"=="2" goto MANUAL_GIT_GUIDE_EN
if "%choco_choice%"=="0" goto MAIN_MENU_EN
echo Invalid choice!
timeout /t 2 >nul
goto MANUAL_GIT_INSTALL_EN

:INSTALL_CHOCOLATEY_GIT_EN
echo.
echo [*] Installing Chocolatey...
echo [+] Opening PowerShell with Admin rights to install Chocolatey...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', 'Write-Host \"Installing Chocolatey...\" -ForegroundColor Green; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(''https://community.chocolatey.org/install.ps1'')); Write-Host \"Chocolatey installed successfully!\" -ForegroundColor Green; Write-Host \"Installing Git...\" -ForegroundColor Yellow; choco install git -y; Write-Host \"Git installed successfully!\" -ForegroundColor Green; Write-Host \"Please restart your computer to complete.\" -ForegroundColor Cyan; pause'"
echo.
echo [+] Opened PowerShell to install Chocolatey and Git.
echo [*] Please wait for installation to complete.
echo [*] Close PowerShell window when installation is done.
echo.
echo [*] After installation:
echo [1] Restart your computer
echo [2] Run start.bat again
echo [3] Select option [3] to verify
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:MANUAL_GIT_GUIDE_EN
echo.
echo ======================================
echo     MANUAL GIT INSTALLATION GUIDE
echo ======================================
echo.
echo [1] Visit: https://git-scm.com/download/win
echo [2] Click "Click here to download"
echo [3] Run the downloaded installer
echo [4] Select "Git from the command line and also from 3rd-party software"
echo [5] Click "Next" until finished
echo [6] Wait for installation to complete
echo [7] Restart your computer
echo [8] Run start.bat again and select option [3]
echo.
echo [*] Important: Select "Git from the command line and also from 3rd-party software"!
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:INSTALL_DEPS_EN
echo.
echo [*] Installing dependencies...
if "%PYTHON_OK%"=="0" (
    echo [-] Python not installed!
    echo [*] Please install Python first
    echo.
    echo Would you like to:
    echo [1] Install Python now
    echo [2] Back to main menu
    echo.
    set /p python_choice="Enter your choice: "
    if "!python_choice!"=="1" goto INSTALL_PYTHON_EN
    if "!python_choice!"=="2" goto MAIN_MENU_EN
    echo Invalid choice!
    timeout /t 2 >nul
    goto VERIFY_UPDATE_CORE_EN
)

echo [+] Python ready, installing dependencies...
echo [+] Opening PowerShell with Admin rights to install...
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit', '-Command', '$pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source; if (-not $pythonPath) { $pythonPath = (Get-Command py -ErrorAction SilentlyContinue).Source }; if ($pythonPath) { Write-Host ''Found Python at: $pythonPath''; Set-Location ''%~dp0''; Write-Host ''Installing dependencies...''; if ($pythonPath -like ''*\py.exe'') { py -m pip install -r requirements.txt } else { python -m pip install -r requirements.txt } } else { Write-Host ''Python not found. Please install Python first.''; pause }'"
echo.
echo [+] Opened PowerShell to install. Please wait for installation to complete.
echo [*] Close PowerShell window when installation is done.
echo.
echo [*] After installation, you can:
echo [1] Run start.bat again
echo [2] Select option [1] or [2] to use bot/overlay
echo.
pause
goto VERIFY_UPDATE_CORE_EN

:START_BOT_EN
cls
echo ======================================
echo          START UMA BOT
echo ======================================
echo.
echo [*] Checking Python...

powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Using Python...
    python main.py
    goto START_BOT_END_EN
)

powershell -Command "if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Using Python Launcher...
    py main.py
    goto START_BOT_END_EN
)

echo [-] Python not found! Please run option [3] to check and install Python.
pause >nul
goto MAIN_MENU_EN

:START_BOT_END_EN
echo.
echo [*] Bot stopped. Press any key to return to menu.
pause >nul
goto MAIN_MENU_EN

:START_EVENT_OVERLAY_EN
cls
echo ======================================
echo       START EVENT OVERLAY
echo ======================================
echo.
echo [*] Checking Python...

powershell -Command "if (Get-Command python -ErrorAction SilentlyContinue) { exit 0 } else { if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 } }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Using Python...
    python utils/event_overlay.py
    goto START_EVENT_OVERLAY_END_EN
)

powershell -Command "if (Get-Command py -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [+] Using Python Launcher...
    py utils/event_overlay.py
    goto START_EVENT_OVERLAY_END_EN
)

echo [-] Python not found! Please run option [3] to check and install Python.
pause >nul
goto MAIN_MENU_EN

:START_EVENT_OVERLAY_END_EN
echo.
echo [*] Event Overlay stopped. Press any key to return to menu.
pause >nul
goto MAIN_MENU_EN

:BACKUP_CONFIG_EN
cls
echo ======================================
echo         BACKUP CONFIG
echo ======================================
echo.
if not exist "backups" mkdir backups
copy /y config.json "backups\config_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.json" >nul
echo [+] Config.json backed up!
timeout /t 2 >nul
goto MAIN_MENU_EN

:RESTORE_CONFIG_EN
cls
echo ======================================
echo        RESTORE CONFIG
echo ======================================
echo.
if not exist "backups\*.json" (
    echo [-] No backups found!
    timeout /t 2 >nul
    goto MAIN_MENU_EN
)
echo Available backups:
echo.
dir /b "backups\*.json"
echo.
set /p "backup=Enter backup filename (or ENTER to cancel): "
if "%backup%"=="" goto MAIN_MENU_EN
if not exist "backups\%backup%" (
    echo [-] File not found!
    timeout /t 2 >nul
    goto MAIN_MENU_EN
)
copy /y "backups\%backup%" config.json >nul
echo [+] Config restored from backup %backup%
timeout /t 2 >nul
goto MAIN_MENU_EN