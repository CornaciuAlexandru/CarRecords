; Inno Setup Script — CarRecords Installer
; Generat automat

#define AppName      "CarRecords"
#define AppVersion      "1.0.17"
#define AppPublisher "CarRecords"
#define AppURL       "https://carrecords.ro"
#define AppExeName   "CarRecords.exe"
#define BuildDir     "frontend\car_manager\build\windows\x64\runner\Release"

[Setup]
AppId={{A7F3C2E1-9D4B-4F8A-B2C3-D1E5F6A7B8C9}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=yes
; Iesire installer
OutputDir=.
OutputBaseFilename=CarRecords_Setup_v1.0.17
; Icon installer
SetupIconFile=app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; Imagini cu sigla in expertul de instalare
WizardImageFile=wizard_image.bmp
WizardSmallImageFile=wizard_small.bmp
; Necesita Windows 10+
MinVersion=10.0
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon";   Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"; Flags: checkedonce
Name: "startmenuicon"; Description: "Add to Start Menu";         GroupDescription: "Shortcuts:"; Flags: checkedonce

[Files]
; Executabilul principal
Source: "{#BuildDir}\{#AppExeName}";  DestDir: "{app}"; Flags: ignoreversion

; Backend auto-start script
Source: "start_backend.vbs"; DestDir: "{app}"; Flags: ignoreversion

; Flutter DLL-uri necesare
Source: "{#BuildDir}\flutter_windows.dll";   DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDir}\*.dll";                 DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

; Date Flutter (assets, fonturi, etc.)
Source: "{#BuildDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Meniu Start
Name: "{group}\{#AppName}";           Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"
Name: "{group}\Dezinstalare {#AppName}"; Filename: "{uninstallexe}"

; Desktop (dacă e bifat)
Name: "{autodesktop}\{#AppName}";     Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
; Opțional: pornește aplicația după instalare
Filename: "{app}\{#AppExeName}"; Description: "Pornește {#AppName}"; Flags: nowait postinstall skipifsilent

[Registry]
; Pornire automata backend la login (HKCU - nu necesita admin)
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "CarRecords Backend"; ValueData: "wscript.exe ""{app}\start_backend.vbs"""; Flags: uninsdeletevalue

[UninstallDelete]
Type: filesandordirs; Name: "{app}\data"
