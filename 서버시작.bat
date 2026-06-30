@echo off
chcp 65001 >nul
echo ========================================
echo  기획 Tool 파일 서버 시작
echo ========================================
echo.

set PORT=7321
cd /d "%~dp0"

:: Node.js 확인
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [오류] Node.js가 설치되어 있지 않습니다.
    echo  https://nodejs.org 에서 LTS 버전을 설치해 주세요.
    pause
    exit /b
)

:: 내 IP 주소 추출
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4 주소"') do (
    set MYIP=%%a
)
:: 공백 제거
set MYIP=%MYIP: =%

echo [서버 주소 — 팀원에게 이 주소를 공유하세요]
echo  내부망: http://%MYIP%:%PORT%/
echo  로컬:   http://localhost:%PORT%/
echo.
echo [HTML 파일 링크 예시]
echo  http://%MYIP%:%PORT%/projects/CBAM_SaaS/02_기획화면/SCR-CBAM-001_벤치마크.html
echo.
echo  서버를 종료하려면 이 창을 닫거나 Ctrl+C 를 누르세요.
echo ========================================
echo.

npx serve . --port %PORT% --no-clipboard

pause
