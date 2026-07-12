' Porneste backend-ul CarRecords in fundal (fara fereastra)
Dim oShell
Set oShell = CreateObject("WScript.Shell")
oShell.Run "cmd /c cd /d C:\Users\Alex\CarManager\backend && ""C:\Users\Alex\AppData\Roaming\Python\Python313\Scripts\uvicorn.exe"" app.main:app --host 0.0.0.0 --port 8000", 0, False
Set oShell = Nothing
