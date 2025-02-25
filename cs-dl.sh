#!/bin/bash

# ------------------------------------------------------------------------------
# HEADER
# ------------------------------------------------------------------------------
#
# cs-dl.sh
#
# Copyright 2025 hobyte
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# ------------------------------------------------------------------------------
#
# History:
#     2022/12/19 : Anemisus : Skript erstellt.
#     2023/02/26 : Anemisus : Problem bei Authentifizierung behoben.
#     2023/03/18 : Anemisus : Cookie-Recycling hinzugef�gt.
#     2023/03/18 : Anemisus : Umgang mit nicht-ASCII-Zeichen verbessert.
#     2023/03/23 : Anemisus : Fehlerbehandlung hinzugef�gt. Code bereinigt.
#
# ------------------------------------------------------------------------------
# END_OF_HEADER
# ------------------------------------------------------------------------------

HEADER() {
    echo
    echo "-------------------------------------------------------------------------------"
    echo "                               _  _                                          "
    echo "          ___  ___          __| | |     Der Content-Select-Downloader:       "
    echo "         / __|/ __| _____  / _\\\` | |     komplette Werke statt nur Kapitel     "
    echo "        | (__ \__ \_____| | (_| | |                                          "
    echo "         \___||___/        \__,_|_|     Version $version                     "
    echo "-------------------------------------------------------------------------------"
    echo
}

AUTH() {
    curl --silent --location --compressed "https://content-select.com/media/moz_viewer/$uuid" \
        "$@" \
        -o website.html \
        -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" \
        -H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" \
        -H "Accept-Encoding: gzip, deflate, br" \
        -H "Connection: keep-alive" \
        -H "Sec-Fetch-Dest: document" \
        -H "Sec-Fetch-Mode: navigate" \
        -H "Sec-Fetch-Site: none" \
        -H "Sec-Fetch-User: ?1"
}

version="23w12a"
rm -rf temp

while true; do
    clear
    HEADER
    echo "Bitte gib eine Content-Select URL in einem der folgenden Formate an:"
    echo "(ohne Leerzeichen oder neue Zeilen, nur aus der URL-Zeile kopieren)"
    echo
    echo "--> https://content-select.com/de/portal/media/view/"
    echo "    012ab345-6c7d-89e0-1f2a-34b56789cd01"
    echo "--> https://content-select.com/media/moz_viewer/"
    echo "    012ab345-6c7d-89e0-1f2a-34b56789cd01"
    echo "--> https://content-select.com/media/moz_viewer/"
    echo "    012ab345-6c7d-89e0-1f2a-34b56789cd01/language:de"
    echo
    echo "-------------------------------------------------------------------------------"
    echo
    read -p "--> " csl
    clear

    HEADER
    if [ ! -d "./temp" ]; then
        echo "Bereite Arbeitsverzeichnis vor ..."
        mkdir temp
    fi
    cd temp
    echo "Extrahiere Buch-UUID ..."
    echo "$csl" | grep -Po "[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}" > uuid.txt
    uuid=$(cat uuid.txt)
    if [ -z "$uuid" ]; then
        echo
        echo "Keine UUID gefunden, URL scheint falsch zu sein."
        echo
        read -p "Beliebige Taste, um von vorne zu beginnen."
        cd ..
        continue
    fi

    if [ -f "./cookie.txt" ]; then
        echo "Cookie wird wiederverwendet ..."
        echo
        AUTH --cookie ./cookie.txt
    else
        echo "Auf Content-Select Server wird gewartet ..."
        echo
        AUTH --cookie-jar ./cookie.txt
    fi
    clear

    HEADER
    ls
    grep -m 1 -e "data-title=" website.html | sed "s/^\s*//g" | sed "s/data-title=\"//g" | sed "s/\"//g" > title.txt
    title=$(cat title.txt)
    if [ -z "$title" ]; then
        echo "Kein Buch-Informationen zur UUID gefunden."
        echo "Wahrscheinlich ist die Authentifizierung fehlgeschlagen."
        echo
        read -p "Beliebige Taste, um von vorne zu beginnen."
        cd ..
        continue
    fi
    echo "Folgendes Buch wurde gefunden:"
    echo
    echo "--> $title"
    echo
    grep -m 1 -e "data-publisher-name=" website.html | sed "s/data-publisher-name=\"//g" | sed "s/\"//g" | sed "s/^\s*/    Herausgeber: /g"
    grep -m 1 -e "data-ean=" website.html | sed "s/data-ean=\"//g" | sed "s/\"//g" | sed "s/^\s*/    ISBN:        /g"
    echo
    read -p "Beliebige Taste zum Herunterladen."
    clear

    HEADER
    grep -Po "[0-9a-f-]{16,}/[0-9]*" website.html > chapters.txt
    chapcnt=$(grep -c . chapters.txt)
    echo "Lade $chapcnt Kapitel der Reihe nach herunter ..."
    while IFS= read -r chapter; do
        echo "Kapitel $chapter"
        curl --silent -O -J "https://content-select.com/media/display/$chapter" \
            --cookie cookie.txt \
            -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" \
            -H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" \
            -H "Accept-Encoding: gzip, deflate, br" \
            -H "Connection: keep-alive" \
            -H "Referer: https://content-select.com/js/pdf.worker.js" \
            -H "Sec-Fetch-Dest: empty" \
            -H "Sec-Fetch-Mode: cors" \
            -H "Sec-Fetch-Site: same-origin"
    done < chapters.txt

    filename=$(sed "s/[\/:\*\?\"<>|]//g" title.txt | sed "s/ \+/ /g" | sed "s/^\s*//g" | sed "s/\s*$//g")
    echo "Schreibe einzelne Kapitel in eine komplette PDF-Datei ..."
    pdftk *.pdf cat output "../$filename.pdf"
    echo "Bereinige Arbeitsverzeichnis ..."
    rm -f *.pdf chapcnt.txt chapters.txt filename.txt title.txt uuid.txt website.html
    cd ..
    echo
    echo "Fertig, gespeichert als: $filename.pdf"
    echo
    read -p "Beliebige Taste, um ein weiteres Buch herunterzuladen."
done

