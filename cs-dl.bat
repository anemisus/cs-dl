: ------------------------------------------------------------------------------
: HEADER
: ------------------------------------------------------------------------------
:
: cs-dl.bat
:
: Copyright 2023 Anemisus
:
: This program is free software: you can redistribute it and/or modify
: it under the terms of the GNU General Public License as published by
: the Free Software Foundation, either version 3 of the License,
: or (at your option) any later version.
:
: This program is distributed in the hope that it will be useful,
: but WITHOUT ANY WARRANTY; without even the implied warranty of
: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
: See the GNU General Public License for more details.
:
: You should have received a copy of the GNU General Public License
: along with this program. If not, see <http://www.gnu.org/licenses/>.
:
: ------------------------------------------------------------------------------
:
: History:
:     2022/12/19 : Anemisus : Skript erstellt.
:     2023/02/26 : Anemisus : Problem bei Authentifizierung behoben.
:     2023/03/18 : Anemisus : Cookie-Recycling hinzugefügt.
:     2023/03/18 : Anemisus : Umgang mit nicht-ASCII-Zeichen verbessert.
:     2023/03/23 : Anemisus : Fehlerbehandlung hinzugefügt. Code bereinigt.
:
: ------------------------------------------------------------------------------
: END_OF_HEADER
: ------------------------------------------------------------------------------

:RESTART
SET version=23w12a
RMDIR /S /Q temp

:NEXT
@ECHO OFF
CLS

CALL:HEADER
ECHO     Bitte gib eine Content-Select URL in einem der folgenden Formate an:
ECHO     (ohne Leerzeichen oder neue Zeilen, nur aus der URL-Zeile kopieren)
ECHO.
ECHO     --^> https://content-select.com/de/portal/media/view/
ECHO             012ab345-6c7d-89e0-1f2a-34b56789cd01
ECHO     --^> https://content-select.com/media/moz_viewer/
ECHO             012ab345-6c7d-89e0-1f2a-34b56789cd01
ECHO     --^> https://content-select.com/media/moz_viewer/
ECHO             012ab345-6c7d-89e0-1f2a-34b56789cd01/language:de
ECHO.
ECHO -------------------------------------------------------------------------------
ECHO.
SET /P csl="--> "
CLS

CALL:HEADER
IF NOT EXIST .\temp\ (
    ECHO Bereite Arbeitsverzeichnis vor ...
    MKDIR temp
)
CD temp
ECHO Extrahiere Buch-UUID ...
ECHO %csl% | ..\lib\grep -Po "[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}" > uuid.txt
SET /P uuid=<uuid.txt
IF "%uuid%" == "" (
    ECHO.
    ECHO Keine UUID gefunden, URL scheint falsch zu sein.
    ECHO.
    ECHO Beliebige Taste, um von vorne zu beginnen.
    ECHO.
    PAUSE > NUL
    CD ..
    GOTO NEXT
)
IF EXIST .\cookie.txt (
    ECHO Cookie wird wiederverwendet ...
    ECHO.
    CALL:AUTH --cookie cookie.txt
) ELSE (
    ECHO Auf Content-Select Server wird gewartet ...
    ECHO.
    CALL:AUTH --cookie-jar cookie.txt
)
CLS

CALL:HEADER
..\lib\grep -m 1 -e "data-title=" website.html | ..\lib\sed "s/^\s*//g" | ..\lib\sed "s/data-title=""//g" | ..\lib\sed "s/""$//g" | ..\lib\sed "s/[^\x00-\x7F\]//g" | ..\lib\recode -qf html | ..\lib\sed "s/[^\x00-\x7F\]//g" | ..\lib\sed "s/ \+/ /g" > title.txt
SET /P title=<title.txt
IF "%title%" == "" (
    ECHO Kein Buch-Informationen zur UUID gefunden.
    ECHO Wahrscheinlich ist die Authentifizierung fehlgeschlagen.
    ECHO.
    ECHO Beliebige Taste, um von vorne zu beginnen.
    ECHO.
    PAUSE > NUL
    CD ..
    GOTO RESTART
)
ECHO Folgendes Buch wurde gefunden:
ECHO.
ECHO|SET /P="--> %title%"
ECHO.
ECHO.
..\lib\grep -m 1 -e "data-publisher-name=" website.html | ..\lib\sed "s/data-publisher-name=""//g" | ..\lib\sed "s/""$//g" | ..\lib\sed "s/[^\x00-\x7F\]//g" | ..\lib\recode -qf html | ..\lib\sed "s/[^\x00-\x7F\]//g" | ..\lib\sed "s/ \+/ /g" | ..\lib\sed "s/^\s*/    Herausgeber: /g"
..\lib\grep -m 1 -e "data-ean=" website.html | ..\lib\sed "s/data-ean=""//g" | ..\lib\sed "s/""$//g" | ..\lib\sed "s/[^\x00-\x7F\]//g" | ..\lib\recode -qf html | ..\lib\sed "s/[^\x00-\x7F\]//g" | ..\lib\sed "s/ \+/ /g" | ..\lib\sed "s/^\s*/    ISBN:        /g"
ECHO.
ECHO Beliebige Taste zum Herunterladen.
ECHO.
PAUSE > NUL
CLS

CALL:HEADER
..\lib\grep -Po "[0-9a-f-]{16,}/[0-9]*" website.html > chapters.txt
FIND /V /C "" chapters.txt | ..\lib\grep -Po "\d{1,}" > chapcnt.txt
SET /P chapcnt=<chapcnt.txt
ECHO Lade %chapcnt% Kapitel der Reihe nach herunter ...
FOR /F "tokens=*" %%a IN (chapters.txt) DO (
    ..\lib\curl --silent -O -J https://content-select.com/media/display/%%a ^
    --cookie cookie.txt ^
    -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" ^
    -H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" ^
    -H "Accept-Encoding: gzip, deflate, br" ^
    -H "Connection: keep-alive" ^
    -H "Referer: https://content-select.com/js/pdf.worker.js" ^
    -H "Sec-Fetch-Dest: empty" ^
    -H "Sec-Fetch-Mode: cors" ^
    -H "Sec-Fetch-Site: same-origin"
)
..\lib\sed "s/[\/:\*\?\x22<>|]//g" title.txt | ..\lib\sed "s/ \+/ /g" | ..\lib\sed "s/^\s*//g" | ..\lib\sed "s/\s*$//g" > filename.txt
SET /P filename=<filename.txt
ECHO Schreibe einzelne Kapitel in eine komplette PDF-Datei ...
..\lib\pdftk *.pdf cat output "..\%filename%.pdf"
ECHO Bereinige Arbeitsverzeichnis ...
DEL *.pdf chapcnt.txt chapters.txt filename.txt title.txt uuid.txt website.html
CD ..
ECHO.
ECHO|SET /P="Fertig, gespeichert als: %filename%.pdf"
ECHO.
ECHO.
ECHO Beliebige Taste, um ein weiteres Buch herunterzuladen.
ECHO.
PAUSE > NUL
GOTO NEXT

:HEADER
    ECHO.
    ECHO -------------------------------------------------------------------------------
    ECHO                               _  _
    ECHO          ___  ___          __^| ^|^| ^|     Der Content-Select-Downloader:
    ECHO         / __^|/ __^| _____  / _` ^|^| ^|     komplette Werke statt nur Kapitel
    ECHO        ^| (__ \__ \^|_____^|^| (_^| ^|^| ^|
    ECHO         \___^|^|___/        \__,_^|^|_^|     Version %version%
    ECHO.
    ECHO -------------------------------------------------------------------------------
    ECHO.
EXIT /B 0

:AUTH
    ..\lib\curl --silent --location --compressed https://content-select.com/media/moz_viewer/%uuid% ^
    %* ^
    -o website.html ^
    -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" ^
    -H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" ^
    -H "Accept-Encoding: gzip, deflate, br" ^
    -H "Connection: keep-alive" ^
    -H "Sec-Fetch-Dest: document" ^
    -H "Sec-Fetch-Mode: navigate" ^
    -H "Sec-Fetch-Site: none" ^
    -H "Sec-Fetch-User: ?1"
EXIT /B 0
