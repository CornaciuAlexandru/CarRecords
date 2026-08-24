"""
Sursa unica pentru traducerile aplicatiei.

Fiecare cheie are traducerile in toate limbile suportate. Scriptul genereaza
fisierele .arb din care Flutter produce clasa AppLocalizations.

Rulare:
    python tools/build_translations.py
    cd frontend/car_manager && flutter gen-l10n

De ce asa si nu direct .arb: o singura sursa in loc de 7 fisiere paralele,
imposibil sa uiti o limba, si se vede dintr-o privire ce inseamna fiecare
cheie in toate limbile.
"""
import json
from pathlib import Path

OUT_DIR = Path(__file__).resolve().parent.parent / "frontend" / "car_manager" / "lib" / "l10n"

# Limbile suportate. Prima (en) este si sablonul.
LANGS = ["en", "ro", "de", "hu", "fr", "es", "it"]

# ─────────────────────────────────────────────────────────────────
#  Traduceri: cheie -> {limba: text}
# ─────────────────────────────────────────────────────────────────
T = {
    # ── General / comune ─────────────────────────────────────────
    "appName": dict(en="CarRecords", ro="CarRecords", de="CarRecords",
                    hu="CarRecords", fr="CarRecords", es="CarRecords", it="CarRecords"),
    "save": dict(en="Save", ro="Salvează", de="Speichern", hu="Mentés",
                 fr="Enregistrer", es="Guardar", it="Salva"),
    "cancel": dict(en="Cancel", ro="Anulează", de="Abbrechen", hu="Mégse",
                   fr="Annuler", es="Cancelar", it="Annulla"),
    "delete": dict(en="Delete", ro="Șterge", de="Löschen", hu="Törlés",
                   fr="Supprimer", es="Eliminar", it="Elimina"),
    "edit": dict(en="Edit", ro="Editează", de="Bearbeiten", hu="Szerkesztés",
                 fr="Modifier", es="Editar", it="Modifica"),
    "add": dict(en="Add", ro="Adaugă", de="Hinzufügen", hu="Hozzáadás",
                fr="Ajouter", es="Añadir", it="Aggiungi"),
    "update": dict(en="Update", ro="Actualizează", de="Aktualisieren",
                   hu="Frissítés", fr="Mettre à jour", es="Actualizar", it="Aggiorna"),
    "retry": dict(en="Try again", ro="Încearcă din nou", de="Erneut versuchen",
                  hu="Újra", fr="Réessayer", es="Reintentar", it="Riprova"),
    "error": dict(en="Error", ro="Eroare", de="Fehler", hu="Hiba",
                  fr="Erreur", es="Error", it="Errore"),
    "errorWith": dict(en="Error: {msg}", ro="Eroare: {msg}", de="Fehler: {msg}",
                      hu="Hiba: {msg}", fr="Erreur : {msg}", es="Error: {msg}",
                      it="Errore: {msg}"),
    "required": dict(en="Required", ro="Obligatoriu", de="Erforderlich",
                     hu="Kötelező", fr="Obligatoire", es="Obligatorio", it="Obbligatorio"),
    "optional": dict(en="optional", ro="opțional", de="optional", hu="opcionális",
                     fr="facultatif", es="opcional", it="facoltativo"),
    "notes": dict(en="Notes", ro="Note", de="Notizen", hu="Jegyzetek",
                  fr="Notes", es="Notas", it="Note"),
    "notesHint": dict(en="Remarks...", ro="Observații...", de="Anmerkungen...",
                      hu="Megjegyzések...", fr="Remarques...", es="Observaciones...",
                      it="Osservazioni..."),
    "chooseDate": dict(en="Choose date", ro="Alege dată", de="Datum wählen",
                       hu="Válassz dátumot", fr="Choisir une date",
                       es="Elegir fecha", it="Scegli data"),
    "city": dict(en="City", ro="Oraș", de="Stadt", hu="Város",
                 fr="Ville", es="Ciudad", it="Città"),
    "cost": dict(en="Cost (RON)", ro="Cost (RON)", de="Kosten (RON)",
                 hu="Költség (RON)", fr="Coût (RON)", es="Coste (RON)", it="Costo (RON)"),
    "invoiceNr": dict(en="Invoice no.", ro="Nr. factură", de="Rechnungsnr.",
                      hu="Számlaszám", fr="N° facture", es="N.º factura",
                      it="N. fattura"),

    # ── Autentificare ────────────────────────────────────────────
    "loginTitle": dict(en="Welcome back", ro="Bine ai revenit", de="Willkommen zurück",
                       hu="Üdv újra", fr="Bon retour", es="Bienvenido de nuevo",
                       it="Bentornato"),
    "loginSubtitle": dict(en="Sign in to continue",
                          ro="Autentifică-te pentru a continua",
                          de="Melde dich an, um fortzufahren",
                          hu="Jelentkezz be a folytatáshoz",
                          fr="Connecte-toi pour continuer",
                          es="Inicia sesión para continuar",
                          it="Accedi per continuare"),
    "email": dict(en="Email", ro="Email", de="E-Mail", hu="E-mail",
                  fr="E-mail", es="Correo electrónico", it="Email"),
    "password": dict(en="Password", ro="Parolă", de="Passwort", hu="Jelszó",
                     fr="Mot de passe", es="Contraseña", it="Password"),
    "login": dict(en="Sign in", ro="Autentificare", de="Anmelden",
                  hu="Bejelentkezés", fr="Se connecter", es="Iniciar sesión",
                  it="Accedi"),
    "register": dict(en="Create account", ro="Creează cont", de="Konto erstellen",
                     hu="Fiók létrehozása", fr="Créer un compte",
                     es="Crear cuenta", it="Crea account"),
    "noAccount": dict(en="No account? ", ro="Nu ai cont? ", de="Kein Konto? ",
                      hu="Nincs fiókod? ", fr="Pas de compte ? ",
                      es="¿No tienes cuenta? ", it="Non hai un account? "),
    "haveAccount": dict(en="Already have an account? ", ro="Ai deja cont? ",
                        de="Schon ein Konto? ", hu="Van már fiókod? ",
                        fr="Déjà un compte ? ", es="¿Ya tienes cuenta? ",
                        it="Hai già un account? "),
    "fullName": dict(en="Full name", ro="Nume complet", de="Vollständiger Name",
                     hu="Teljes név", fr="Nom complet", es="Nombre completo",
                     it="Nome completo"),
    "phone": dict(en="Phone", ro="Telefon", de="Telefon", hu="Telefon",
                  fr="Téléphone", es="Teléfono", it="Telefono"),
    "confirmPassword": dict(en="Confirm password", ro="Confirmă parola",
                            de="Passwort bestätigen", hu="Jelszó megerősítése",
                            fr="Confirmer le mot de passe",
                            es="Confirmar contraseña", it="Conferma password"),
    "passwordsDoNotMatch": dict(en="Passwords do not match", ro="Parolele nu coincid",
                                de="Passwörter stimmen nicht überein",
                                hu="A jelszavak nem egyeznek",
                                fr="Les mots de passe ne correspondent pas",
                                es="Las contraseñas no coinciden",
                                it="Le password non coincidono"),
    "invalidEmail": dict(en="Invalid email address", ro="Adresă de email invalidă",
                         de="Ungültige E-Mail-Adresse", hu="Érvénytelen e-mail cím",
                         fr="Adresse e-mail invalide",
                         es="Dirección de correo no válida",
                         it="Indirizzo email non valido"),
    "passwordTooShort": dict(en="At least 8 characters",
                             ro="Minim 8 caractere", de="Mindestens 8 Zeichen",
                             hu="Legalább 8 karakter", fr="Au moins 8 caractères",
                             es="Mínimo 8 caracteres", it="Almeno 8 caratteri"),
    "logout": dict(en="Sign out", ro="Deconectare", de="Abmelden",
                   hu="Kijelentkezés", fr="Se déconnecter", es="Cerrar sesión",
                   it="Esci"),
    "newAccount": dict(en="New account", ro="Cont nou", de="Neues Konto",
                       hu="Új fiók", fr="Nouveau compte", es="Cuenta nueva",
                       it="Nuovo account"),
    "fillDetails": dict(en="Fill in the details below",
                        ro="Completează datele de mai jos",
                        de="Fülle die folgenden Daten aus",
                        hu="Töltsd ki az alábbi adatokat",
                        fr="Remplis les informations ci-dessous",
                        es="Completa los datos siguientes",
                        it="Compila i dati qui sotto"),
    "minChars3": dict(en="At least 3 characters", ro="Minim 3 caractere",
                      de="Mindestens 3 Zeichen", hu="Legalább 3 karakter",
                      fr="Au moins 3 caractères", es="Mínimo 3 caracteres",
                      it="Almeno 3 caratteri"),
    "phoneOptional": dict(en="Phone (optional)", ro="Telefon (opțional)",
                          de="Telefon (optional)", hu="Telefon (opcionális)",
                          fr="Téléphone (facultatif)", es="Teléfono (opcional)",
                          it="Telefono (facoltativo)"),
    "passwordRulesHint": dict(en="Min. 8 characters, 1 uppercase, 1 digit",
                              ro="Min. 8 caractere, 1 majusculă, 1 cifră",
                              de="Mind. 8 Zeichen, 1 Großbuchstabe, 1 Ziffer",
                              hu="Min. 8 karakter, 1 nagybetű, 1 számjegy",
                              fr="Min. 8 caractères, 1 majuscule, 1 chiffre",
                              es="Mín. 8 caracteres, 1 mayúscula, 1 dígito",
                              it="Min. 8 caratteri, 1 maiuscola, 1 cifra"),
    "passwordNeedsUpper": dict(en="Must contain at least one uppercase letter",
                               ro="Trebuie cel puțin o literă mare",
                               de="Muss mindestens einen Großbuchstaben enthalten",
                               hu="Legalább egy nagybetűt kell tartalmaznia",
                               fr="Doit contenir au moins une majuscule",
                               es="Debe contener al menos una mayúscula",
                               it="Deve contenere almeno una maiuscola"),
    "passwordNeedsDigit": dict(en="Must contain at least one digit",
                               ro="Trebuie cel puțin o cifră",
                               de="Muss mindestens eine Ziffer enthalten",
                               hu="Legalább egy számjegyet kell tartalmaznia",
                               fr="Doit contenir au moins un chiffre",
                               es="Debe contener al menos un dígito",
                               it="Deve contenere almeno una cifra"),

    # ── Navigare ─────────────────────────────────────────────────
    "navHome": dict(en="Home", ro="Acasă", de="Start", hu="Kezdőlap",
                    fr="Accueil", es="Inicio", it="Home"),
    "navCars": dict(en="Cars", ro="Mașini", de="Fahrzeuge", hu="Autók",
                    fr="Voitures", es="Coches", it="Auto"),
    "navAlerts": dict(en="Alerts", ro="Alerte", de="Warnungen",
                      hu="Riasztások", fr="Alertes", es="Alertas", it="Avvisi"),
    "navProfile": dict(en="Profile", ro="Profil", de="Profil", hu="Profil",
                       fr="Profil", es="Perfil", it="Profilo"),
    "navAdmin": dict(en="Admin", ro="Admin", de="Admin", hu="Admin",
                     fr="Admin", es="Admin", it="Admin"),

    # ── Pornire aplicatie ────────────────────────────────────────
    "startingService": dict(en="Starting service...", ro="Se pornește serviciul...",
                            de="Dienst wird gestartet...", hu="Szolgáltatás indítása...",
                            fr="Démarrage du service...", es="Iniciando servicio...",
                            it="Avvio del servizio..."),
    "searchingServer": dict(en="Searching for the server...",
                            ro="Se caută serverul în rețea...",
                            de="Server wird gesucht...", hu="Szerver keresése...",
                            fr="Recherche du serveur...", es="Buscando el servidor...",
                            it="Ricerca del server..."),
    "connecting": dict(en="Connecting...", ro="Se conectează...",
                       de="Verbindung wird hergestellt...", hu="Csatlakozás...",
                       fr="Connexion...", es="Conectando...", it="Connessione..."),
    "checkingUpdates": dict(en="Checking for updates...",
                            ro="Se verifică actualizări...",
                            de="Suche nach Updates...", hu="Frissítések keresése...",
                            fr="Recherche de mises à jour...",
                            es="Buscando actualizaciones...",
                            it="Ricerca aggiornamenti..."),
    "connected": dict(en="Connected!", ro="Conectat!", de="Verbunden!",
                      hu="Csatlakozva!", fr="Connecté !", es="¡Conectado!",
                      it="Connesso!"),
    "serverNotFound": dict(en="Server not found", ro="Server negăsit",
                           de="Server nicht gefunden", hu="A szerver nem található",
                           fr="Serveur introuvable", es="Servidor no encontrado",
                           it="Server non trovato"),
    "serverNotFoundHintMobile": dict(
        en="Make sure your computer is on and connected to the same Wi-Fi network.",
        ro="Asigură-te că PC-ul este pornit și conectat la aceeași rețea Wi-Fi.",
        de="Stelle sicher, dass dein PC eingeschaltet und im selben WLAN ist.",
        hu="Győződj meg róla, hogy a számítógép be van kapcsolva és ugyanazon a Wi-Fi hálózaton van.",
        fr="Vérifie que ton ordinateur est allumé et connecté au même réseau Wi-Fi.",
        es="Asegúrate de que tu ordenador está encendido y conectado a la misma red Wi-Fi.",
        it="Assicurati che il computer sia acceso e collegato alla stessa rete Wi-Fi."),
    "serverNotFoundHintDesktop": dict(
        en="Make sure the app is installed correctly and try again.",
        ro="Asigură-te că aplicația este instalată corect și încearcă din nou.",
        de="Stelle sicher, dass die App korrekt installiert ist, und versuche es erneut.",
        hu="Ellenőrizd, hogy az alkalmazás helyesen van telepítve, majd próbáld újra.",
        fr="Vérifie que l'application est correctement installée et réessaie.",
        es="Comprueba que la aplicación está instalada correctamente e inténtalo de nuevo.",
        it="Verifica che l'app sia installata correttamente e riprova."),
    "searchAgain": dict(en="Search again", ro="Caută din nou", de="Erneut suchen",
                        hu="Keresés újra", fr="Rechercher à nouveau",
                        es="Buscar de nuevo", it="Cerca di nuovo"),

    # ── Ecran principal ──────────────────────────────────────────
    "greeting": dict(en="Hi, {name}! 👋", ro="Bună, {name}! 👋",
                     de="Hallo, {name}! 👋", hu="Szia, {name}! 👋",
                     fr="Salut, {name} ! 👋", es="¡Hola, {name}! 👋",
                     it="Ciao, {name}! 👋"),
    "myCars": dict(en="My cars", ro="Mașinile mele", de="Meine Fahrzeuge",
                   hu="Autóim", fr="Mes voitures", es="Mis coches",
                   it="Le mie auto"),
    "viewAll": dict(en="View all", ro="Vezi toate", de="Alle anzeigen",
                    hu="Összes", fr="Voir tout", es="Ver todo", it="Vedi tutti"),
    "statActiveAlerts": dict(en="Active alerts", ro="Alerte active",
                             de="Aktive Warnungen", hu="Aktív riasztások",
                             fr="Alertes actives", es="Alertas activas",
                             it="Avvisi attivi"),
    "statExpired": dict(en="Expired", ro="Expirate", de="Abgelaufen",
                        hu="Lejárt", fr="Expirés", es="Caducados", it="Scaduti"),
    "addFirstCar": dict(en="Add your first car", ro="Adaugă prima mașină",
                        de="Erstes Fahrzeug hinzufügen", hu="Add hozzá az első autót",
                        fr="Ajoute ta première voiture", es="Añade tu primer coche",
                        it="Aggiungi la prima auto"),
    "noCarsYet": dict(en="No cars added yet", ro="Nu ai mașini adăugate",
                      de="Noch keine Fahrzeuge", hu="Még nincs autó hozzáadva",
                      fr="Aucune voiture ajoutée", es="Aún no hay coches",
                      it="Nessuna auto aggiunta"),
    "noCarsHint": dict(
        en="Add your first car to keep track of all its documents",
        ro="Adaugă prima ta mașină pentru a gestiona toate documentele",
        de="Füge dein erstes Fahrzeug hinzu, um alle Dokumente zu verwalten",
        hu="Add hozzá az első autót az összes dokumentum kezeléséhez",
        fr="Ajoute ta première voiture pour gérer tous ses documents",
        es="Añade tu primer coche para gestionar todos sus documentos",
        it="Aggiungi la prima auto per gestire tutti i suoi documenti"),
    "addCar": dict(en="Add car", ro="Adaugă mașină", de="Fahrzeug hinzufügen",
                   hu="Autó hozzáadása", fr="Ajouter une voiture",
                   es="Añadir coche", it="Aggiungi auto"),
    "carsCount": dict(en="{count}/{max} cars", ro="{count}/{max} mașini",
                      de="{count}/{max} Fahrzeuge", hu="{count}/{max} autó",
                      fr="{count}/{max} voitures", es="{count}/{max} coches",
                      it="{count}/{max} auto"),
    "deleteCar": dict(en="Delete car", ro="Șterge mașina", de="Fahrzeug löschen",
                      hu="Autó törlése", fr="Supprimer la voiture",
                      es="Eliminar coche", it="Elimina auto"),
    "deleteCarConfirm": dict(
        en='Delete "{name}"? All related data will be removed.',
        ro='Ștergi "{name}"? Toate datele asociate vor fi șterse.',
        de='"{name}" löschen? Alle zugehörigen Daten werden entfernt.',
        hu='Törlöd: "{name}"? Minden kapcsolódó adat törlődik.',
        fr='Supprimer « {name} » ? Toutes les données associées seront effacées.',
        es='¿Eliminar "{name}"? Se borrarán todos los datos asociados.',
        it='Eliminare "{name}"? Tutti i dati associati verranno rimossi.'),

    # ── Limba ────────────────────────────────────────────────────
    "language": dict(en="Language", ro="Limbă", de="Sprache", hu="Nyelv",
                     fr="Langue", es="Idioma", it="Lingua"),
    "languageChoose": dict(en="Choose language", ro="Alege limba",
                           de="Sprache wählen", hu="Válassz nyelvet",
                           fr="Choisir la langue", es="Elegir idioma",
                           it="Scegli la lingua"),
}


def build():
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # Verificare: fiecare cheie are toate limbile
    problems = []
    for key, vals in T.items():
        missing = [lang for lang in LANGS if not vals.get(lang)]
        if missing:
            problems.append(f"  {key}: lipsesc {', '.join(missing)}")
    if problems:
        print("Traduceri incomplete:")
        print("\n".join(problems))
        raise SystemExit(1)

    for lang in LANGS:
        data = {"@@locale": lang}
        for key, vals in T.items():
            data[key] = vals[lang]
            # Declaram parametrii pentru sirurile cu substitutii ({msg} etc.)
            placeholders = {}
            text = vals[lang]
            for token in ("msg", "count", "name", "max", "version"):
                if "{" + token + "}" in text:
                    placeholders[token] = {"type": "int"} if token in ("count", "max") else {"type": "String"}
            if placeholders:
                data["@" + key] = {"placeholders": placeholders}

        path = OUT_DIR / f"app_{lang}.arb"
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                        encoding="utf-8")

    print(f"Generate {len(LANGS)} fisiere .arb cu {len(T)} chei fiecare, in:")
    print(f"  {OUT_DIR}")
    print(f"Limbi: {', '.join(LANGS)}")


if __name__ == "__main__":
    build()
