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
:
: ------------------------------------------------------------------------------
: END_OF_HEADER
: ------------------------------------------------------------------------------

SET version=23w11d
RMDIR /S /Q temp

:NEXT
@ECHO OFF
CLS

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
ECHO     Bitte gib eine Content Select URL in einem der folgenden Formate an:
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
IF EXIST .\temp\cookie.txt GOTO SKIP1
ECHO Bereite Arbeitsverzeichnis vor ...
MKDIR temp
:SKIP1
CD temp
ECHO Extrahiere Buch-UUID ...
ECHO %csl% | ..\lib\grep -Po "[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}" > uuid.txt
SET /P uuid=<uuid.txt
IF EXIST .\cookie.txt GOTO REUSE
ECHO Auf Content Select Server wird gewartet ...
ECHO.
..\lib\curl --silent --location --compressed https://content-select.com/media/moz_viewer/%uuid% ^
--cookie-jar cookie.txt ^
-o website.html ^
-H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" ^
-H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" ^
-H "Accept-Encoding: gzip, deflate, br" ^
-H "Connection: keep-alive" ^
-H "Sec-Fetch-Dest: document" ^
-H "Sec-Fetch-Mode: navigate" ^
-H "Sec-Fetch-Site: none" ^
-H "Sec-Fetch-User: ?1"
GOTO SKIP2
:REUSE
ECHO Cookie wird wiederverwendet ...
ECHO.
..\lib\curl --silent --location --compressed https://content-select.com/media/moz_viewer/%uuid% ^
--cookie cookie.txt ^
-o website.html ^
-H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" ^
-H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" ^
-H "Accept-Encoding: gzip, deflate, br" ^
-H "Connection: keep-alive" ^
-H "Sec-Fetch-Dest: document" ^
-H "Sec-Fetch-Mode: navigate" ^
-H "Sec-Fetch-Site: none" ^
-H "Sec-Fetch-User: ?1"
:SKIP2
CLS

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
ECHO Folgendes Buch wurde gefunden:
ECHO.
..\lib\grep -m 1 -e "data-title=" website.html | ..\lib\sed "s/^\s*//g" | ..\lib\sed "s/data-title=""//g" | ..\lib\sed "s/""$//g" | ..\lib\sed "s/[^\x00-\x7F\]//g" | ..\lib\recode -qf html | ..\lib\sed "s/[^\x00-\x7F\]//g" | ..\lib\sed "s/ \+/ /g" > title.txt
SET /P title=<title.txt
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
