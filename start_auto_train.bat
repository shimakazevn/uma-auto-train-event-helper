@echo off

ECHO Kiem tra quyen Administrator...
net session >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO Yeu cau quyen Administrator de tu dong cai dat.
    ECHO Vui long chap nhan UAC prompt de tiep tuc.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
ECHO Da co quyen Administrator.
ECHO.

ECHO Kiem tra cac phan mem can thiet...
ECHO.

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
        ECHO winget va Chocolatey khong ton tai.
        ECHO Dang tien hanh cai dat Chocolatey...
        powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        IF %ERRORLEVEL% NEQ 0 (
            ECHO Cai dat Chocolatey that bai. Vui long cai dat thu cong va chay lai script.
            pause >nul
            exit /b
        )
        ECHO Cai dat Chocolatey thanh cong.
        ECHO.
        ECHO ** QUAN TRONG: Nap lai moi truong de su dung Chocolatey. **
        set "PATH=%PATH%;C:\ProgramData\chocolatey\bin"
        refreshenv
        
        ECHO.
        ECHO Kiem tra lai Chocolatey sau khi nap moi truong...
        where choco >nul 2>nul
        IF %ERRORLEVEL% EQU 0 (
            ECHO Da tim thay Chocolatey. Tiep tuc cai dat Git...
            choco install git -y
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
                ECHO Cai dat Git bang Chocolatey that bai. Vui long cai dat thu cong roi chay lai file.
                pause > nul
                exit /b
            )
        ) ELSE (
            ECHO Khong the su dung Chocolatey sau khi cai dat.
            ECHO Vui long dong cua so nay, mo lai va chay lai script.
            pause >nul
            exit /b
        )
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
        ECHO winget va Chocolatey khong ton tai.
        ECHO Dang tien hanh cai dat Chocolatey...
        powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        IF %ERRORLEVEL% NEQ 0 (
            ECHO Cai dat Chocolatey that bai. Vui long cai dat thu cong va chay lai script.
            pause >nul
            exit /b
        )
        ECHO Cai dat Chocolatey thanh cong.
        ECHO.
        ECHO ** QUAN TRONG: Nap lai moi truong de su dung Chocolatey. **
        set "PATH=%PATH%;C:\ProgramData\chocolatey\bin"
        refreshenv
        
        ECHO.
        ECHO Kiem tra lai Chocolatey sau khi nap moi truong...
        where choco >nul 2>nul
        IF %ERRORLEVEL% EQU 0 (
            ECHO Da tim thay Chocolatey. Tiep tuc cai dat Python...
            choco install python -y
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
                ECHO Cai dat Python bang Chocolatey that bai. Vui long cai dat thu cong roi chay lai file.
                pause > nul
                exit /b
            )
        ) ELSE (
            ECHO Khong the su dung Chocolatey sau khi cai dat.
            ECHO Vui long dong cua so nay, mo lai va chay lai script.
            pause >nul
            exit /b
        )
    )
)

REM Kiem tra Tesseract
where tesseract >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Tesseract OCR chua duoc cai dat.
    ECHO Dang tim phuong thuc cai dat tu dong...
    where winget >nul 2>nul
    IF %ERRORLEVEL% EQU 0 (
        ECHO Da tim thay winget. Dang thu cai dat Tesseract OCR bang winget...
        winget install --id Tesseract.Tesseract -e --source winget --silent --accept-source-agreements --accept-package-agreements
        IF %ERRORLEVEL% EQU 0 (
            ECHO Cai dat Tesseract OCR thanh cong. Tu dong nap lai PATH...
            call :RefreshEnv
            where tesseract >nul 2>nul
            IF %ERRORLEVEL% NEQ 0 (
                ECHO Khong the tu dong nap lai PATH. Vui long chay lai file nay.
                pause >nul
                exit /b
            )
            ECHO Nap lai PATH thanh cong.
        ) ELSE (
            ECHO Cai dat Tesseract OCR bang winget that bai. Vui long cai dat thu cong roi chay lai file.
            pause > nul
            exit /b
        )
    ) ELSE (
        ECHO winget va Chocolatey khong ton tai.
        ECHO Dang tien hanh cai dat Chocolatey...
        powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        IF %ERRORLEVEL% NEQ 0 (
            ECHO Cai dat Chocolatey that bai. Vui long cai dat thu cong va chay lai script.
            pause >nul
            exit /b
        )
        ECHO Cai dat Chocolatey thanh cong.
        ECHO.
        ECHO ** QUAN TRONG: Nap lai moi truong de su dung Chocolatey. **
        set "PATH=%PATH%;C:\ProgramData\chocolatey\bin"
        refreshenv
        
        ECHO.
        ECHO Kiem tra lai Chocolatey sau khi nap moi truong...
        where choco >nul 2>nul
        IF %ERRORLEVEL% EQU 0 (
            ECHO Da tim thay Chocolatey. Tiep tuc cai dat Tesseract OCR...
            choco install tesseract-ocr -y
            IF %ERRORLEVEL% EQU 0 (
                ECHO Cai dat Tesseract OCR thanh cong. Tu dong nap lai PATH...
                call :RefreshEnv
                where tesseract >nul 2>nul
                IF %ERRORLEVEL% NEQ 0 (
                    ECHO Khong the tu dong nap lai PATH. Vui long chay lai file nay.
                    pause >nul
                    exit /b
                )
                ECHO Nap lai PATH thanh cong.
            ) ELSE (
                ECHO Cai dat Tesseract OCR bang Chocolatey that bai. Vui long cai dat thu cong roi chay lai file.
                pause > nul
                exit /b
            )
        ) ELSE (
            ECHO Khong the su dung Chocolatey sau khi cai dat.
            ECHO Vui long dong cua so nay, mo lai va chay lai script.
            pause >nul
            exit /b
        )
    )
)

ECHO Tat ca phan mem can thiet da san sang.
ECHO.

echo Bo qua theo doi file config.json de giu lai cau hinh local...
git update-index --assume-unchanged config.json


echo.
echo Dang cap nhat tu Git...
git pull
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo Update that bai, vui long kiem tra lai.
    pause > nul
    exit /b
)

echo.
echo Cai dat cac goi phu thuoc...
pip install -r requirements.txt

echo.
echo Khoi chay umamusume auto train...
python main.py
echo.
echo Cap nhat va thuc thi hoan tat. An phim bat ky de thoat.
pause > nul
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
