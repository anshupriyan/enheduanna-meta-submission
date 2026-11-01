@echo off
setlocal
set SCRIPT_DIR=%~dp0
set REPO_ROOT=%SCRIPT_DIR%..
set WORKSPACE_ROOT=%REPO_ROOT%\..

if exist "%REPO_ROOT%\memvison\.venv\Scripts\python.exe" (
    set PYTHON_EXE=%REPO_ROOT%\memvison\.venv\Scripts\python.exe
) else if exist "%WORKSPACE_ROOT%\memvison\.venv\Scripts\python.exe" (
    set PYTHON_EXE=%WORKSPACE_ROOT%\memvison\.venv\Scripts\python.exe
) else if exist "%REPO_ROOT%\igi\.venv\Scripts\python.exe" (
    set PYTHON_EXE=%REPO_ROOT%\igi\.venv\Scripts\python.exe
) else (
    set PYTHON_EXE=python
)

echo ==========================================================
echo    ::: LAUNCHING IGI (THE EYE OF ENHEDUANNA) :::
echo    Interpreter: %PYTHON_EXE%
echo ==========================================================

:: JIT Verification: Ensure PySide6 desktop HUD GUI package is installed
"%PYTHON_EXE%" -c "import PySide6" >nul 2>&1
if errorlevel 1 (
    echo.
    echo  [IGI] First-time launch detected: PySide6 GUI package is required.
    echo  [IGI] Installing PySide6-Essentials for on-screen companion HUD...
    where uv >nul 2>&1
    if not errorlevel 1 (
        uv pip install --python "%PYTHON_EXE%" -r "%REPO_ROOT%\igi\requirements.txt"
    ) else (
        "%PYTHON_EXE%" -m pip install -r "%REPO_ROOT%\igi\requirements.txt"
    )
    if errorlevel 1 (
        echo.
        echo  [FAIL] Failed to install PySide6. Check your internet connection.
        pause
        exit /b 1
    )
    echo  [OK] PySide6-Essentials installed successfully.
    echo.
)

cd /d "%REPO_ROOT%\igi"
"%PYTHON_EXE%" main.py
