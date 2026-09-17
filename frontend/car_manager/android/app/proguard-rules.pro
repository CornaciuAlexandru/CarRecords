# Reguli de pastrare pentru build-ul de release.
#
# R8 elimina codul la care nu vede referinte directe. Bibliotecile care se
# folosesc de reflexie n-au astfel de referinte, deci sunt taiate - iar
# problema apare doar in release, unde e cel mai greu de gasit.

# ── Stocarea securizata a tokenurilor ────────────────────────────
#
# flutter_secure_storage foloseste EncryptedSharedPreferences, care sta pe
# Tink. Tink isi populeaza registrul de algoritmi prin reflexie, la rulare.
# Fara regulile astea, R8 a taiat 1848 de intrari din cele doua pachete, iar
# scrierea tokenului nu se mai termina niciodata: butonul de autentificare se
# invartea la infinit intr-un build de release, in timp ce in depanare mergea.
-keep class androidx.security.crypto.** { *; }
-keep class com.google.crypto.tink.** { *; }
-dontwarn androidx.security.crypto.**
-dontwarn com.google.crypto.tink.**

# Tink isi serializeaza cheile cu o copie interna de protobuf, care citeste
# campurile prin reflexie.
-keepclassmembers class * extends com.google.crypto.tink.shaded.protobuf.GeneratedMessageLite {
  <fields>;
}
