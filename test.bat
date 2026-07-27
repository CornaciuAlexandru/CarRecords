@echo off
REM Ruleaza suita de teste a backend-ului (in mediul virtual izolat).
REM Utilizare:  test.bat            -> toate testele
REM             test.bat -v         -> detaliat
REM             test.bat tests/test_auth.py  -> un singur fisier
cd /d "%~dp0backend"
if exist ".venv\Scripts\python.exe" (
    ".venv\Scripts\python.exe" -m pytest %*
) else (
    echo [!] Mediul virtual lipseste. Ruleaza mai intai:
    echo     python -m venv .venv ^&^& .venv\Scripts\pip install -r requirements.txt
    exit /b 1
)
