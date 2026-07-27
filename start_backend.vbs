' Porneste backend-ul CarRecords in fundal (fara fereastra).
' Foloseste mediul virtual izolat (.venv) — astfel niciun pachet instalat
' global pe calculator nu poate afecta aplicatia.
' Daca .venv lipseste (instalare noua), cade inapoi pe Python-ul global.
Dim oShell, oFS, sRoot, sVenvPy, sCmd
Set oShell = CreateObject("WScript.Shell")
Set oFS = CreateObject("Scripting.FileSystemObject")

sRoot = "C:\Users\Alex\CarManager\backend"
sVenvPy = sRoot & "\.venv\Scripts\python.exe"

If oFS.FileExists(sVenvPy) Then
    sCmd = "cmd /c cd /d """ & sRoot & """ && """ & sVenvPy & _
           """ -m uvicorn app.main:app --host 0.0.0.0 --port 8000"
Else
    sCmd = "cmd /c cd /d """ & sRoot & """ && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000"
End If

oShell.Run sCmd, 0, False

Set oFS = Nothing
Set oShell = Nothing
