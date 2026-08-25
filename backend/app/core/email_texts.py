"""Textele emailurilor si ale paginilor web servite de backend.

Separate de traducerile aplicatiei (tools/build_translations.py): acolo sunt
sirurile din interfata Flutter, aici doar ce trimite serverul pe email sau
afiseaza in browser. Aceleasi 7 limbi.

Limba vine de la client (parametrul `lang`) sau, cand lipseste, din
antetul Accept-Language.
"""

LANGS = ("en", "ro", "de", "hu", "fr", "es", "it")
DEFAULT_LANG = "en"

T = {
    # ── Comune ───────────────────────────────────────────────────
    "hello": dict(
        en="Hi {name},", ro="Salut, {name},", de="Hallo {name},",
        hu="Szia {name},", fr="Bonjour {name},", es="Hola {name}:",
        it="Ciao {name},"),
    "fallback": dict(
        en="If the button does not work, copy this link into your browser:",
        ro="Dacă butonul nu funcționează, copiază acest link în browser:",
        de="Falls die Schaltfläche nicht funktioniert, kopiere diesen Link in deinen Browser:",
        hu="Ha a gomb nem működik, másold be ezt a linket a böngésződbe:",
        fr="Si le bouton ne fonctionne pas, copiez ce lien dans votre navigateur :",
        es="Si el botón no funciona, copia este enlace en tu navegador:",
        it="Se il pulsante non funziona, copia questo link nel browser:"),
    "footer": dict(
        en="Automated message from CarRecords. Please do not reply.",
        ro="Mesaj automat de la CarRecords. Te rugăm să nu răspunzi.",
        de="Automatische Nachricht von CarRecords. Bitte nicht antworten.",
        hu="Automatikus üzenet a CarRecords alkalmazástól. Kérjük, ne válaszolj rá.",
        fr="Message automatique de CarRecords. Merci de ne pas répondre.",
        es="Mensaje automático de CarRecords. Por favor, no respondas.",
        it="Messaggio automatico di CarRecords. Ti preghiamo di non rispondere."),

    # ── Resetare parola ──────────────────────────────────────────
    "resetSubject": dict(
        en="Reset your CarRecords password",
        ro="Resetarea parolei CarRecords",
        de="CarRecords-Passwort zurücksetzen",
        hu="CarRecords jelszó visszaállítása",
        fr="Réinitialisation de votre mot de passe CarRecords",
        es="Restablecer tu contraseña de CarRecords",
        it="Reimposta la tua password CarRecords"),
    "resetIntro": dict(
        en="You asked for a new password for your CarRecords account. Choose one here:",
        ro="Ai cerut o parolă nouă pentru contul tău CarRecords. O poți alege aici:",
        de="Du hast ein neues Passwort für dein CarRecords-Konto angefordert. Hier kannst du es festlegen:",
        hu="Új jelszót kértél a CarRecords-fiókodhoz. Itt tudod beállítani:",
        fr="Vous avez demandé un nouveau mot de passe pour votre compte CarRecords. Choisissez-le ici :",
        es="Has solicitado una contraseña nueva para tu cuenta de CarRecords. Elígela aquí:",
        it="Hai richiesto una nuova password per il tuo account CarRecords. Scegliela qui:"),
    "resetButton": dict(
        en="Set a new password", ro="Setează parola nouă",
        de="Neues Passwort festlegen", hu="Új jelszó beállítása",
        fr="Définir un nouveau mot de passe", es="Establecer contraseña nueva",
        it="Imposta la nuova password"),
    "resetExpiry": dict(
        en="The link works once and expires in {minutes} minutes.",
        ro="Linkul poate fi folosit o singură dată și expiră în {minutes} de minute.",
        de="Der Link funktioniert einmal und läuft in {minutes} Minuten ab.",
        hu="A link egyszer használható, és {minutes} perc múlva lejár.",
        fr="Le lien est à usage unique et expire dans {minutes} minutes.",
        es="El enlace se puede usar una sola vez y caduca en {minutes} minutos.",
        it="Il link è valido una sola volta e scade tra {minutes} minuti."),
    "resetIgnore": dict(
        en="If it was not you, ignore this message — your password stays unchanged.",
        ro="Dacă nu tu ai cerut asta, ignoră mesajul — parola rămâne neschimbată.",
        de="Warst du das nicht, ignoriere diese Nachricht — dein Passwort bleibt unverändert.",
        hu="Ha nem te kérted, hagyd figyelmen kívül ezt az üzenetet — a jelszavad változatlan marad.",
        fr="Si vous n'êtes pas à l'origine de cette demande, ignorez ce message : votre mot de passe reste inchangé.",
        es="Si no has sido tú, ignora este mensaje: tu contraseña no cambiará.",
        it="Se non sei stato tu, ignora questo messaggio: la password resta invariata."),

    # ── Confirmarea adresei ──────────────────────────────────────
    "verifySubject": dict(
        en="Confirm your CarRecords email address",
        ro="Confirmă adresa de email CarRecords",
        de="Bestätige deine CarRecords-E-Mail-Adresse",
        hu="Erősítsd meg a CarRecords e-mail-címedet",
        fr="Confirmez votre adresse e-mail CarRecords",
        es="Confirma tu dirección de correo de CarRecords",
        it="Conferma il tuo indirizzo email CarRecords"),
    "verifyIntro": dict(
        en="Welcome to CarRecords. Confirm your address so you can recover the account if you forget your password:",
        ro="Bine ai venit în CarRecords. Confirmă adresa ca să îți poți recupera contul dacă uiți parola:",
        de="Willkommen bei CarRecords. Bestätige deine Adresse, damit du dein Konto wiederherstellen kannst, falls du das Passwort vergisst:",
        hu="Üdv a CarRecordsban! Erősítsd meg a címedet, hogy vissza tudd szerezni a fiókodat, ha elfelejtenéd a jelszavad:",
        fr="Bienvenue dans CarRecords. Confirmez votre adresse afin de pouvoir récupérer le compte en cas d'oubli du mot de passe :",
        es="Bienvenido a CarRecords. Confirma tu dirección para poder recuperar la cuenta si olvidas la contraseña:",
        it="Benvenuto in CarRecords. Conferma il tuo indirizzo per poter recuperare l'account se dimentichi la password:"),
    "verifyButton": dict(
        en="Confirm address", ro="Confirmă adresa", de="Adresse bestätigen",
        hu="Cím megerősítése", fr="Confirmer l'adresse", es="Confirmar dirección",
        it="Conferma indirizzo"),
    "verifyExpiry": dict(
        en="The link is valid for {hours} hours.",
        ro="Linkul este valabil {hours} de ore.",
        de="Der Link ist {hours} Stunden gültig.",
        hu="A link {hours} óráig érvényes.",
        fr="Le lien est valable {hours} heures.",
        es="El enlace es válido durante {hours} horas.",
        it="Il link è valido per {hours} ore."),

    # ── Pagini in browser ────────────────────────────────────────
    "pageResetTitle": dict(
        en="New password", ro="Parolă nouă", de="Neues Passwort",
        hu="Új jelszó", fr="Nouveau mot de passe", es="Contraseña nueva",
        it="Nuova password"),
    "pageNewPassword": dict(
        en="New password", ro="Parola nouă", de="Neues Passwort",
        hu="Új jelszó", fr="Nouveau mot de passe", es="Contraseña nueva",
        it="Nuova password"),
    "pageConfirmPassword": dict(
        en="Confirm password", ro="Confirmă parola", de="Passwort bestätigen",
        hu="Jelszó megerősítése", fr="Confirmer le mot de passe",
        es="Confirmar contraseña", it="Conferma password"),
    "pageRules": dict(
        en="At least 8 characters, one uppercase letter and one digit.",
        ro="Minim 8 caractere, o literă mare și o cifră.",
        de="Mindestens 8 Zeichen, ein Großbuchstabe und eine Ziffer.",
        hu="Legalább 8 karakter, egy nagybetű és egy számjegy.",
        fr="Au moins 8 caractères, une majuscule et un chiffre.",
        es="Al menos 8 caracteres, una mayúscula y un dígito.",
        it="Almeno 8 caratteri, una maiuscola e una cifra."),
    "pageSubmit": dict(
        en="Save password", ro="Salvează parola", de="Passwort speichern",
        hu="Jelszó mentése", fr="Enregistrer le mot de passe",
        es="Guardar contraseña", it="Salva password"),
    "pageMismatch": dict(
        en="The passwords do not match.", ro="Parolele nu coincid.",
        de="Die Passwörter stimmen nicht überein.", hu="A jelszavak nem egyeznek.",
        fr="Les mots de passe ne correspondent pas.", es="Las contraseñas no coinciden.",
        it="Le password non coincidono."),
    "pageResetDone": dict(
        en="Password changed. Sign in to the app with the new one.",
        ro="Parola a fost schimbată. Autentifică-te în aplicație cu cea nouă.",
        de="Passwort geändert. Melde dich in der App mit dem neuen Passwort an.",
        hu="A jelszó megváltozott. Jelentkezz be az alkalmazásba az újjal.",
        fr="Mot de passe modifié. Connectez-vous à l'application avec le nouveau.",
        es="Contraseña cambiada. Inicia sesión en la aplicación con la nueva.",
        it="Password modificata. Accedi all'app con quella nuova."),
    "pageVerifyDone": dict(
        en="Email address confirmed. Thank you.",
        ro="Adresa de email a fost confirmată. Mulțumim.",
        de="E-Mail-Adresse bestätigt. Danke.",
        hu="Az e-mail-cím megerősítve. Köszönjük.",
        fr="Adresse e-mail confirmée. Merci.",
        es="Dirección de correo confirmada. Gracias.",
        it="Indirizzo email confermato. Grazie."),
    "pageLinkInvalid": dict(
        en="The link is invalid or has expired. Ask for a new one from the app.",
        ro="Linkul este invalid sau a expirat. Cere unul nou din aplicație.",
        de="Der Link ist ungültig oder abgelaufen. Fordere in der App einen neuen an.",
        hu="A link érvénytelen vagy lejárt. Kérj újat az alkalmazásból.",
        fr="Le lien est invalide ou a expiré. Demandez-en un nouveau depuis l'application.",
        es="El enlace no es válido o ha caducado. Solicita uno nuevo desde la aplicación.",
        it="Il link non è valido o è scaduto. Richiedine uno nuovo dall'app."),
}


def t(key: str, lang: str = DEFAULT_LANG, **kwargs) -> str:
    """Textul unei chei in limba ceruta, cu revenire la engleza."""
    entry = T[key]
    text = entry.get(normalize_lang(lang)) or entry[DEFAULT_LANG]
    return text.format(**kwargs) if kwargs else text


def normalize_lang(lang: str) -> str:
    """ro-RO, RO sau gol -> ro; orice limba nesuportata -> engleza."""
    if not lang:
        return DEFAULT_LANG
    code = lang.split(",")[0].split("-")[0].strip().lower()
    return code if code in LANGS else DEFAULT_LANG
