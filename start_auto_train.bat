@echo off

ECHO Kiem tra cac phan mem can thiet...
ECHO.

REM Kiem tra Git
where git >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Git chua duoc cai dat.
    where winget >nul 2>nul
    IF %ERRORLEVEL% EQU 0 (
        ECHO Dang thu cai dat Git bang winget...
        winget install --id Git.Git -e --source winget --silent --accept-source-agreements --accept-package-agreements
        IF %ERRORLEVEL% EQU 0 (
            ECHO Cai dat Git thanh cong. Vui long chay lai file nay de tiep tuc.
        ) ELSE (
            ECHO Cai dat Git that bai. Vui long cai dat thu cong roi chay lai file.
        )
    ) ELSE (
        ECHO winget khong ton tai. Vui long cai dat Git thu cong roi chay lai file.
    )
    pause > nul
    exit /b
)

REM Kiem tra Python
where py >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Python chua duoc cai dat.
    where winget >nul 2>nul
    IF %ERRORLEVEL% EQU 0 (
        ECHO Dang thu cai dat Python bang winget...
        winget install --id Python.Python.3 -e --source winget --silent --accept-source-agreements --accept-package-agreements
        IF %ERRORLEVEL% EQU 0 (
            ECHO Cai dat Python thanh cong. Vui long chay lai file nay de tiep tuc.
        ) ELSE (
            ECHO Cai dat Python that bai. Vui long cai dat thu cong roi chay lai file.
        )
    ) ELSE (
        ECHO winget khong ton tai. Vui long cai dat Python thu cong roi chay lai file.
    )
    pause > nul
    exit /b
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
