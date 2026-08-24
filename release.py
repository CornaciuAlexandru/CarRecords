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
import sys, subprocess, json, shutil, re, hashlib
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

def bump_msix_version(new_ver: str):
    """Versiunea MSIX are 4 componente (Store cere formatul x.y.z.0)."""
    pub = FLUTTER / "pubspec.yaml"
    txt = pub.read_text(encoding="utf-8")
    txt = re.sub(r"msix_version: [\d.]+", f"msix_version: {new_ver}.0", txt)
    pub.write_text(txt, encoding="utf-8")
    print(f"  ✓ Versiune MSIX actualizata: {new_ver}.0")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def update_version_json(new_ver: str, changelog: str):
    vf = BACKEND / "version.json"
    data = json.loads(vf.read_text(encoding="utf-8")) if vf.exists() else {}
    data["version"]            = new_ver
    data["changelog"]          = changelog
    data["installer_filename"] = f"CarRecords_Setup_v{new_ver}.exe"
    # Hash SHA-256 al installer-ului — verificat de client inainte de executie
    installer = ROOT / f"CarRecords_Setup_v{new_ver}.exe"
    if installer.exists():
        data["sha256"] = sha256_file(installer)
        print(f"  ✓ SHA-256: {data['sha256'][:16]}...")
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

    print("[1/7] Actualizare versiuni in cod...")
    bump_flutter_version(new_ver)
    bump_inno_version(new_ver)
    bump_msix_version(new_ver)

    print("\n[2/7] Build Windows EXE...")
    run("flutter build windows --release", cwd=FLUTTER)

    print("\n[3/7] Build Android APK...")
    run("flutter build apk --release", cwd=FLUTTER)

    print("\n[4/7] Compilare installer Inno Setup...")
    run(f'"{ISCC}" installer.iss', cwd=ROOT)

    print("\n[5/7] Actualizare version.json backend...")
    update_version_json(new_ver, changelog)

    print("\n[6/7] Copiere artefacte...")
    installer_src = ROOT / f"CarRecords_Setup_v{new_ver}.exe"
    installer_dst = BACKEND / "downloads" / f"CarRecords_Setup_v{new_ver}.exe"
    shutil.copy(installer_src, installer_dst)
    # Copie si ca CarRecords.apk pentru distributie usoara
    apk_src = FLUTTER / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"
    shutil.copy(apk_src, ROOT / "CarRecords.apk")
    print(f"  ✓ {installer_dst.name} ({installer_src.stat().st_size / 1e6:.1f} MB)")

    # Pachetul pentru Microsoft Store se face separat: are updater-ul propriu
    # dezactivat (magazinul gestioneaza actualizarile).
    print("\n[7/7] Pachet MSIX pentru Microsoft Store...")
    run("flutter build windows --release --dart-define=STORE_BUILD=true", cwd=FLUTTER)
    run("dart run msix:create", cwd=FLUTTER)
    msix_src = FLUTTER / "build" / "windows" / "x64" / "runner" / "Release" / "car_manager.msix"
    if msix_src.exists():
        msix_dst = ROOT / f"CarRecords_v{new_ver}.msix"
        shutil.copy(msix_src, msix_dst)
        print(f"  ✓ {msix_dst.name} ({msix_dst.stat().st_size / 1e6:.1f} MB)")
    # Refacem build-ul normal (fara STORE_BUILD), ca sa ramana cel curent
    run("flutter build windows --release", cwd=FLUTTER)

    print(f"\n{'='*50}")
    print(f"  ✓ Release v{new_ver} completat cu succes!")
    print(f"  Installer: CarRecords_Setup_v{new_ver}.exe")
    print(f"  APK:       CarRecords.apk")
    print(f"{'='*50}\n")
