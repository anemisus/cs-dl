[![cs-dl Logo](https://raw.githubusercontent.com/anemisus/cs-dl/main/logo.svg)](#readme)

**cs-dl ist ein Skript für Windows**, mit dem sich eBooks von der Plattform [Content-Select](https://content-select.com/) in vollem Umfang und ohne hässliche Wasserzeichen herunterladen lassen.

# Installation und Nutzung

1. Klicke auf den Button `<> Code ▾` und im Pop-Up unten auf [`Download ZIP`](https://github.com/anemisus/cs-dl/archive/refs/heads/main.zip).
2. Entpacke die heruntergeladene ZIP-Datei auf deinem Rechner.
3. Navigiere in den Ordner `cs-dl`.
4. Führe das Skript `cs-dl.bat` aus.
5. Folge den Anweisungen auf dem Bildschirm.

# FAQ

## F: Was ist das Problem mit Content-Select?

A: Normalerweise erlaubt Content-Select nur den Download einzelner Kapitel aus eBooks. Die so über einen Browser heruntergeladenen Dateien enthalten außerdem ein sichtbares Wasserzeichen auf jeder einzelnen Seite.

Aus dieser **Design-Entscheidung** ergeben sich **folgende Nachteile**:

- Die Bücher sind nicht mehr komplett digital durchsuchbar (`STRG + F`).
- Durch die vielen Dateien geht schnell die Übersicht verloren.
- Das Wasserzeichen ist optisch störend wie Fettflecken oder Eselsohren.
- Es ist hart nervig, 20 Kapitel einzeln ziehen zu müssen.

Hey Content-Select? Wie wäre es, wenn ihr einfach aufhört, uns damit auf den Sack zu gehen?

## F: Wo finde ich mein Buch?

A: Die fertigen Dateien landen im Hauptordner, wo auch das Skript liegt.

## F: Warum dauert das so lange?

A: Um Inhalte von Content-Select herunterzuladen, muss sich der Client dort authentifizieren können. Dazu braucht er ein Cookie. Anhand der IP-Adresse aus einem berechtigten Bereich (z. B. aus der Uni) prüft der Server die Erlaubnis zum **Erhalt des Cookies**. Bei der ersten Verbindung dauert das eine Weile. Vermutlich hat der Anbieter diese Verzögerung als Spam-Schutz implementiert.

💡 **Sobald das Cookie zugeteilt wurde, kann es mehrfach benutzt werden.**

Falls mehr du mehr als ein Buch herunterladen möchtest, starte daher nicht jedes Mal das Skript neu. Drücke nach erfolgtem Download eine beliebige Taste, um das Cookie weiter zu verwenden und die Wartezeit ab dem zweiten Download zu verkürzen.

## F: Ist das überhaupt erlaubt?

A: Vermutlich schon. Der Download ist nur Personen möglich, die grundsätzlich dazu berechtigt sind.

🧸 **Das Skript nutzt keine Sicherheitslücken aus.**

Es simuliert lediglich einen Browser, der die einzelnen Kapitel nacheinander abruft. Am Ende werden die Inhalte dann lokal zu einem kompletten Werk zusammengefügt.

## F: Warum ein Skript für Windows?

A: Viele Unis finden proprietäre Windows-Software toll und bürden ihren Studierenden gerne ein ganzes Konglomerat davon auf. Wenn ich mir für diese Schweinereien eh eine virtuelle Maschine aufsetzen muss, darf das Skript ruhig direkt mit da drin ausgeführt werden. 

Allerdings sollte eine Portierung nach Linux ziemlich einfach sein, weil das Skript ansonsten nur auf freie Standardsoftware zurückgreift, die sich schnell und einfach als Paket installieren lässt (curl, grep, sed, ...).

## F: Warum funktioniert es nicht?

A: Schwer zu sagen. Vielleicht hast du etwas falsch gemacht oder Skript beinhaltet einen Fehler?

Es kann aber auch sein, dass Content-Select eine Änderung an der Plattform vorgenommen hat, mit der das Skript noch nicht umgehen kann. Warte in diesem Fall auf ein Update.

## F: Fingerprint des Signaturschlüssels?

A: Er lautet `804ABD4A66A66E5242131FAB14AAF2972A56D0F8`.

Du kannst den Schlüssel z. B. auf [keys.openpgp.org](https://keys.openpgp.org/) suchen und herunterladen.

