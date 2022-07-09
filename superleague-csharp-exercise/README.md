# Super League

In dieser Aufgabe geht es darum, aus (fiktiven) Ergebnissen von Fussballspielen
eine Tabelle zu erstellen.

**Diese Aufgabe wird am Ende des Semesters bewertet. Diese Bewertung fliesst in
Ihre Modulnote ein. Arbeiten Sie kontinuierlich an der Aufgabe, sodass der
Zwischenstand nach jeder Schulwoche besser ist als die Woche zuvor.**

Erstellen Sie gleich einen Fork von diesem Repository und klonen Sie es
anschliessend:

    $ git clone https://code.frickelbude.ch/[ihrName]/superleague.git

## Beispieldaten

Im Verzeichnis `data/` befinden sich folgende Dateien:

### `data/games.txt`

Dies ist eine Liste von absolvierten Spielen in beliebiger Reihenfolge (d.h. nicht
nach Spieltag sortiert). Pro Zeile wird ein Spielergebnis in der folgenden Form
ausgegeben:

    [Heimmannschaft] [Tore Heimmannschaft]:[Tore Auswärtsmannschaft] [Auswärtsmannschaft]

Zum Beispiel:

           FC Basel 1893 2:1 FC Zürich

Dies bedeutet: Der _FC Basel 1893_ (Heimmannschaft) hat mit 2 zu 1 Toren gegen
den _FC Zürich_ (Auswärtsmannschaft) gewonnen.

### `data/league.json`

Dies sind die gleichen Informationen wie in `data/games.txt`, nur dass sie hier
strukturiert im JSON-Format vorliegen. Das Beispiel von oben sieht darin
folgendermassen aus:

```json
{
    "homeTeam": "FC Basel 1893",
    "awayTeam": "FC Zürich",
    "homeGoals": 2,
    "awayGoals": 1
},
```

### `data/league.py`

Hierbei handelt es sich um ein Python-Skript, welches eine Super-League-Saison
der folgenden Mannschaften simuliert:

```python
teams = [
    'FC Basel 1893',
    'FC Zürich',
    'BSC Young Boys',
    'Grasshopper Club Zürich',
    'FC Lugano',
    'Servette FC',
    'FC St. Gallen 1879',
    'FC Sion',
    'FC Luzern',
    'FC Lausanne-Sport',
]
```

Den Code brauchen Sie nicht anzuschauen, er könnte aber für die Aufgabe, die
später folgt, sehr aufschlussreich sein.

### `data/table.txt`

Diese Datei enthält eine textuelle Ausgabe der Super-League-Tabelle am Ende der
Saison, d.h. nach 36 Spieltagen (10 Mannschaften spielen je viermal
gegeneinander, was `(10-1)*4=36` Runden ergibt.

Die Tabelle sieht folgendermassen aus:

                         Name  #  w  d  l  +  -   =  P
    --------------------------------------------------
                    FC Zürich  1 16 10 10 70 59  11 58
      Grasshopper Club Zürich  2 17  7 12 79 70   9 58
               BSC Young Boys  3 16 10 10 66 58   8 58
            FC Lausanne-Sport  4 16  6 14 58 63  -5 54
           FC St. Gallen 1879  5 14  9 13 59 58   1 51
                      FC Sion  6 14  8 14 55 62  -7 50
                  Servette FC  7 13  9 14 76 73   3 48
                    FC Luzern  8 14  6 16 75 79  -4 48
                FC Basel 1893  9 11  8 17 66 77 -11 41
                    FC Lugano 10 10  5 21 58 63  -5 35

Die Spalten haben die folgende Bedeutung:

1. `Name`: der Name der Mannschaft
2. `#`: der Schlussrang der Mannschaft (nach diesem Kriterium wird die Tabelle
   aufsteigend sortiert)
3. `w`: die Anzahl der Siege ("wins")
4. `d`: die Anzahl der Unentschieden ("draws")
5. `l`: die Anzahl der Niederlagen ("losses")
6. `+`: die Anzahl der erzielten Tore
7. `-`: die Anzahl der kassierten Tore
8. `=`: das Torverhältnis (Anzahl erzielte Tore minus Anzahl kassierte Tore)
9. `P`: die Anzahl Punkte (die Tabelle wird nach diesem Kriterium absteigend
   sortiert)

Die Sortierung des Ranges erfolgt mehrstufig:

1. Anzahl Punkte (absteigend)
2. Torverhältnis (absteigend)

Im obigen Beispiel ist der _FC Zürich_ auf Rang 1. Zwar hat der _Grasshopper
Club Zürich_ ebenfalls 58 Punkte, jedoch nur eine Tordifferenz von 9 (_FC
Zürich_ hat eine Tordifferenz von 11).

Punkte werden nach folgender Regel vergeben:

- Ein Sieg ergibt **drei** Punkte
- Ein Unentschieden ergibt **einen** Punkt
- Eine Niederlage ergibt **keine** Punkte

Beispiele:

- Beim Ergebnis `FC Basel 1893 2:1 FC Zürich` erhielten:
    - _FC Basel 1893_ **drei** Punkte
    - _FC Zürich_ **keine** Punkte
- Beim Ergebnis `FC Basel 1893 3:3 FC Zürich` erhielten:
    - _FC Basel 1893_ **einen** Punkt
    - _FC Zürich_ **einen** Punkt

### Weitere Beispieldaten

Die Dateien `data/challenge-league.json` und `data/challenge-league.txt` sowie
`data/plauschturnier.json` und `data/plauschturnier.txt` können ebenfalls zum
Testen der Anwendung verwendet werden.

Mithilfe der Dateien `data/sorting.json` bzw. `data/sorting.txt` kann man
testen, ob bei gleicher Punktzahl und gleicher Tordifferenz (Mannschaften "a"
und "b") die Anzahl Siege als Sortierkriterium verwendet wird.

## Projektstruktur

Das C#-Projekt besteht aus zwei Teilen:

1. `Superleague`: hier befindet sich der Produktivcode
2. `Superleague.Tests`: hier befinden sich die Testfälle

### `SuperLeague/Table.cs`

Diese Klasse verfügt über eine `Main`-Methode. Diese liest die Spielergebnisse
aus der JSON-Datei aus und gibt sie auf die Kommandozeile aus. Das Projekt kann
über die Kommandozeile folgendermassen gestartet werden, indem die JSON-Datei
mit den Spielergebnisse als Argument angegeben wird:

Linux:

    $ dotnet run --project SuperLeague/ data/league.json
    FC Zürich 3:0 FC Basel 1893
    BSC Young Boys 4:3 FC Basel 1893
    Grasshopper Club Zürich 4:4 FC Basel 1893
    ...

Windows:

    > dotnet run --project SuperLeague/ data\league.json
    FC Zürich 3:0 FC Basel 1893
    BSC Young Boys 4:3 FC Basel 1893
    Grasshopper Club Zürich 4:4 FC Basel 1893

Die Methode `ReadMatches` liest die Daten aus der JSON-Datei aus.

### `SuperLeague/Match.cs`

Diese Klasse repräsentiert ein Spielergebnis.

### `SuperLeague.Tests/MatchTest.cs`

Diese Klasse enthält einen Testfall für die `ToString()`-Methode der
`Match`-Klasse.

### `SuperLeague.Tests/TableTest.cs`

Diese Klasse enthält bisher nur einen Dummy-Test.

Die Tests können folgendermassen gestartet werden:

    $ dotnet test
    Passed!  - Failed:     0, Passed:     2, Skipped:     0, Total:     2, Duration: 6 ms

## Aufgabe

Schreiben Sie eine (statische) Methode in `SuperLeague/Table.cs` namens
`CreateTable` mit folgender Signatur:

```csharp
public static [Rückgabetyp] CreateTable(List<Match> results)
```

Das zurückgegebene Objekt soll die `ToString()`-Methode implementieren. Diese
gibt einen String zurück, welcher der Ausgabe von `data/table.txt` entspricht
(kleinere Abweichungen wie unterschiedliche Anzahl Leerzeichen sind erlaubt;
inhaltliche Unterschiede sind nicht zulässig).

Gehen Sie dabei folgendermassen vor:

1. Überlegen Sie sich eine geeignete Abstraktion für eine Tabellenzeile. Eine
   Klasse mit den Eigenschaft `name`, `rank`, `wins` usw. wäre eine Möglichkeit.
2. Die Methode `CreateTable` wird das Argument `List<Match> results` in einer
   Schleife (oder mit einem vergleichbaren Mechanismus) verarbeiten müssen.
   Überlegen Sie sich, welche Informationen sich pro verarbeitetem Spielergebnis
   in einer Tabellenzeile ändern können. (Den Rang ermitteln Sie am besten erst
   ganz am Schluss, indem Sie die Einträge sortieren und den Rang auf Basis des
   Index berechnen.)
3. Trennen Sie den Aufbau der Tabelle vom Bilden des Strings.
4. Schreiben Sie Unit Tests für die Methoden, die Sie programmieren.

## Definitive Bewertungskriterien

Als Abgabetermin gilt der 8. Dezember (23:59 Uhr). Das Repository muss mit dem
Tag `v0.1.0` versehen sein! Die Bewertung sollte bis Weihnachten erfolgen.

Die Aufgaben wird nach den folgenden Kriterien bewertet (Punktzahlen in eckigen
Klammern):

- [8] **Kontinuität**: Pro Schulwoche bis zum Abgabetermin gibt es mindestens einen
  substanziellen Commit, der auch gleich gepusht werden muss.
    - [2] Woche bis 17. November
    - [2] Woche bis 24. November
    - [2] Woche bis 1. Dezember
    - [2] Woche bis 8. Dezember
    - Wer den Tag `v0.1.0` früher setzt, erhält die Punkte für die
      darauffolgenden Wochen ebenfalls. Verpasste Wochen können nicht nachgeholt
      werden.
- [24] **Funktionalität**: Das Programm arbeitet korrekt gemäss den Anforderungen und
  gibt die erwünschte Tabelle aus.
    - [6] Verwendung des Programms:
        - [1] Das Programm kann mit dem Befehl `dotnet run --project SuperLeague
          data/league.json` gestartet werden und gibt die Tabelle auf die
          Standardausgabe aus.
        - [5] Das Programm kann auch andere JSON-Dateien der gleichen Struktur
          als Kommandozeilenargument entgegennehmen und verarbeiten.
    - [5] Darstellung der Tabelle:
        - [1] Die Tabelle verfügt über eine Titelzeile.
        - [1] Nach der Titelzeile folgt eine Trennzeile.
        - [1] Es folgen genau zehn Einträge; je ein Eintrag pro Mannschaft.
        - [1] Die Tabelle beinhaltet die folgenden Spalten: `Name` (Mannschaft), `#`
          (Rang), `w` (Anzahl Siege), `d` (Anzahl Unentschieden), `l` (Anzahl
          Niederlagen), `+` (Anzahl erzielter Tore), `-` (Anzahl kassierter Tore),
          `=` (Torverhältnis), `P` (Punkte).
        - [1] Die numerischen Angaben sind untereinander rechtsbündig
          angeordnet. (Der Mannschaftsname kann links- oder rechtsbündig
          angeordnet werden.)
    - [13] Inhalt der Tabelle:
        - [1] Jede in einem Spiel involvierte Mannschaft kommt mindestens einmal
          vor.
        - [1] Der Rang wird korrekt von 1 bis `n` angegeben, wobei `n` die
          Anzahl der Mannschaften ist.
        - [3] Die Anzahl der Siege, Unentschieden und Niederlagen wird korrekt
          berechnet und ergibt in der Summe die Anzahl absoliverter Spiele pro
          Mannschaft.
        - [3] Die Anzahl der erzielten und kassierten Tore wird korrekt
          berechnet und ergibt zusammengerechnet (erzielte Tore minus kassierte
          Tore) die Tordifferenz.
        - [1] Die Anzahl der Punkte wird korrekt berechnet.
        - [4] Die Sortierung der Tabelle erfolgt nach den folgenden Kriterien:
            1) Punkte (absteigend)
            2) Tordifferenz (absteigend)
            3) Anzahl Siege (absteigend)
            4) Mannschaftsname (alpahbetisch, aufsteigend)
- [8] **Design**: Der Quellcode ist sinnvoll aufgebaut.
    - [2] Eine Tabellenzeile wird sinnvoll abstrahiert (z.B. mit einer Klasse).
    - [2] Die Tabelle als ganzes wird sinnvoll abstrahiert (z.B. mit einer Liste
      oder einer eigenen Klasse).
    - [2] Die Methode `CreateTable` produziert zunächst eine Datenstruktur,
      welche die Tabelle repräsentiert, aus der die textuelle Repräsentation der
      Tabelle in einem weiteren Schritt erstellt werden kann (z.B. mittels einer
      `ToString()`-Methode).
    - [2] Für die Sortierung der Tabelleneinträge verwenden Sie geeignete
      Mechanismen, welche Ihnen vom .NET-Framework zur Verfügung gestellt werden.
- [19] **Unit Tests**: Der Code wird sinnvoll mittels Unit Tests getestet.
    - [1] Pro Klasse im Projekt `SuperLeague` existiert eine entsprechende
      Testklasse im Projekt `SuperLeague.Tests`.
    - [1] Pro `public`-Methode im Projekt `SuperLeague` existiert mindestens
      eine Testmethode im Projekt `SuperLeage.Tests`.
    - [15] Für die folgenden Aspekte existiert je ein Testfall (pro Punkt ist ein
      Testfall verlangt):
        - [2] Sortierung der Tabelleneinträge
        - [1] Berechnung des Ranges
        - [3] Berechnung der Anzahl Siege, Unentschieden und Niederlagen
        - [2] Berechnung der Anzahl erzielter und kassierter Tore
        - [1] Berechnung der Tordifferenz
        - [3] Berechnung der Anzahl Punkte
        - [3] Ausgabe der Tabelle als String
    - [2] Die Unit Tests haben eine gut erkennbare Struktur (Arrange/Act/Assert
      bzw. Given/When/Then, wobei entsprechende Kommentare im Code freiwillig
      sind).
- [15] **Codequalität**: Der Code genügt den behandelten Kriterien zu "Clean Code"
    - [3] Formatierung: Der Code ist durchgehend sinnvoll formatiert.
    - [3] Kommentare: Kommentare werden verwendet, wo sie sinnvoll sind; sie
      sind gut formuliert. Die wichtigsten High-Level APIs werden mithilfe von
      [Documentation
      Comments](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/language-specification/documentation-comments)
      dokumentiert.
    - [3] Benennung: Die Bezeichner sind sinnvoll gewählt und selbsterklärend.
    - [3] Wiederverwendbarkeit: Code wird nicht dupliziert, sondern ausgelagert.
    - [3] Klarheit: Der Code ist gut verständlich und elegant.
- [5] **Abgabe**: Das Repository befindet sich in einem guten Zustand:
    - [1] Die Tests lassen sich mittels `dotnet test` alle erfolgreich
      ausführen.
    - [1] Es wurden keine unnötigen Dateien (z.B. Binärdaten) hinzugefügt.
    - [1] Die Commit-Messages sind aussagekräftig und durchgehend in der
      gleichen Sprache (Englisch oder Deutsch) gehalten.
    - [1] Die Abgabe ist korrekt getagt (`v0.1.0`).
    - [1] Anpassungen am Upstream-Repository wurden mittels Merge nachgetragen.

Substanzielle **Plagiate** werden mit null Punkten und mit der Note 1.0
bewertet. Die gegenseitige Hilfestellung mittels **Pair Programming** ist
hingegen erlaubt und und auf freiwilliger Basis erwünscht.
