"""
Script de release CarRecords.
Utilizare:
    python release.py 1.1.0 "Descriere noutati"

Ce face:
  1. Actualizeaza versiunea in Flutter (update_service.dart) si pubspec.yaml
  2. Rebuildeaza EXE-ul Windows
  3. Rebuildeaza APK-ul Android
  4. Compileaza noul installer Inno Setup
  5. Actualizeaza version.json in backend
  6. Copiaza installer-ul in backend/downloads/
"""
import sys, subprocess, json, shutil, re
from pathlib import Path

# Forteaza UTF-8 pe stdout pentru a evita erori cp1252 pe Windows
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

ROOT     = Path(__file__).parent
BACKEND  = ROOT / "backend"
FLUTTER  = ROOT / "frontend" / "car_manager"
ISCC     = Path(r"C:\Users\Alex\AppData\Local\Programs\Inno Setup 6\ISCC.exe")

def run(cmd, cwd=None):
    print(f"  $ {cmd}")
    r = subprocess.run(cmd, shell=True, cwd=cwd or ROOT)
    if r.returncode != 0:
        print(f"  ✗ Eroare (exit {r.returncode})")
        sys.exit(r.returncode)

def bump_flutter_version(new_ver: str):
    # pubspec.yaml
    pub = FLUTTER / "pubspec.yaml"
    txt = pub.read_text(encoding="utf-8")
    txt = re.sub(r"^version: .+", f"version: {new_ver}+{new_ver.replace('.','')}", txt, flags=re.MULTILINE)
    pub.write_text(txt, encoding="utf-8")
    # update_service.dart — constanta _appVersion
    svc = FLUTTER / "lib" / "core" / "services" / "update_service.dart"
    txt2 = svc.read_text(encoding="utf-8")
    txt2 = re.sub(r"const _appVersion = '[^']+';", f"const _appVersion = '{new_ver}';", txt2)
    svc.write_text(txt2, encoding="utf-8")
    print(f"  ✓ Versiune Flutter actualizata: {new_ver}")

def bump_inno_version(new_ver: str):
    iss = ROOT / "installer.iss"
    txt = iss.read_text(encoding="utf-8")
    txt = re.sub(r'#define AppVersion\s+"[^"]+"', f'#define AppVersion      "{new_ver}"', txt)
    txt = re.sub(r'OutputBaseFilename=CarRecords_Setup_v[^\n]+',
                 f'OutputBaseFilename=CarRecords_Setup_v{new_ver}', txt)
    iss.write_text(txt, encoding="utf-8")
    print(f"  ✓ Versiune Inno Setup actualizata: {new_ver}")

def update_version_json(new_ver: str, changelog: str):
    vf = BACKEND / "version.json"
    data = json.loads(vf.read_text(encoding="utf-8")) if vf.exists() else {}
    data["version"]            = new_ver
    data["changelog"]          = changelog
    data["installer_filename"] = f"CarRecords_Setup_v{new_ver}.exe"
    vf.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"  ✓ version.json actualizat: {new_ver}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Utilizare: python release.py <versiune> [changelog]")
        print("Exemplu:   python release.py 1.1.0 \"Imbunatatiri OCR si fix-uri\"")
        sys.exit(1)

    new_ver   = sys.argv[1]
    changelog = sys.argv[2] if len(sys.argv) > 2 else f"Versiunea {new_ver}"

    print(f"\n{'='*50}")
    print(f"  Release CarRecords v{new_ver}")
    print(f"{'='*50}\n")

    print("[1/6] Actualizare versiuni in cod...")
    bump_flutter_version(new_ver)
    bump_inno_version(new_ver)

    print("\n[2/6] Build Windows EXE...")
    run("flutter build windows --release", cwd=FLUTTER)

    print("\n[3/6] Build Android APK...")
    run("flutter build apk --release", cwd=FLUTTER)

    print("\n[4/6] Compilare installer Inno Setup...")
    run(f'"{ISCC}" installer.iss', cwd=ROOT)

    print("\n[5/6] Actualizare version.json backend...")
    update_version_json(new_ver, changelog)

    print("\n[6/6] Copiere installer in backend/downloads/...")
    installer_src = ROOT / f"CarRecords_Setup_v{new_ver}.exe"
    installer_dst = BACKEND / "downloads" / f"CarRecords_Setup_v{new_ver}.exe"
    shutil.copy(installer_src, installer_dst)
    # Copie si ca CarRecords.apk pentru distributie usoara
    apk_src = FLUTTER / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"
    shutil.copy(apk_src, ROOT / "CarRecords.apk")
    print(f"  ✓ {installer_dst.name} ({installer_src.stat().st_size / 1e6:.1f} MB)")

    print(f"\n{'='*50}")
    print(f"  ✓ Release v{new_ver} completat cu succes!")
    print(f"  Installer: CarRecords_Setup_v{new_ver}.exe")
    print(f"  APK:       CarRecords.apk")
    print(f"{'='*50}\n")
