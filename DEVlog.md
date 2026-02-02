# Projekt: Rundenbasiertes Würfelspiel (Tactix)

## Allgemeine Informationen

**Mitarbeiter**
* Maxim Zlatin
* Minko Gohl

**Verwendete Programme & Tools**
* Godot Engine
* MagicaVoxel
* GitHub

---

## Spielidee

Ein kompetitives, rundenbasiertes Brettspiel für **zwei Spieler**.

**Grundprinzip:**
* Zwei Spieler treten auf einem gemeinsamen Spielfeld gegeneinander an
* Jeder Spieler besitzt Würfel mit Augenzahlen
* Die Augenzahl bestimmt die möglichen Bewegungen
* Feste Spielregeln steuern den Spielfluss
* Am Spielende gibt es **einen Gewinner und einen Verlierer**

---

## Regeln

* Man kann jedes Piece nur die Augenzahl nach vorne bewegen
* Es gibt Könige und normale Pieces
* Könige können nur ein Feld nach vorne gehen
* Pieces können ihre Augenzahl nach vorne gehen
* Man kann nur Pieces "schlagen", wenn es der letzte Zug ist, bis man den Spielzug abgeben muss
* Man darf nur ein Piece pro Runde bewegen
* Man darf nicht auf dieselbe Position zurückkehren, wenn man im Zug davor schon auf derselben war
* Man darf keine Pieces überspringen
* Sobald ein König geschlagen wird, hat der schlagende Spieler gewonnen, der andere hat verloren

---

## Gameloop

* Runde beginnt – Spieler spielt
* Board füllt sich mit verschiedenen Pieces
* Lose High, Win Big
* Fair
* Deterministisch
* Gewinnen

---

## Ausbaufähigkeit

**Neue Modi**
* **Blitz**
  * Begrenzte Zeit, schnelle Züge
* **2 vs 2**
  * 1 gegen 1 zu einfach – try 2 gegen 2

**Weitere Verbesserungen**
* Bugs fixen
* Besseres Tutorial
* Rechte erfragen
* Besseres Intro
* Coole Music

---

## Debug Steps

* `Debug.log("Ein einfaches Tool um zu debuggen")`
* `Globals.DEBUG : Bool = FALSE` (um den Debug Mode zu starten)
* Default Debug Menu within Godot

---

## Fails

* Multiplayer
* Schöne Modelle
* Outline

---

## Entwicklungszeitstrahl

### Januar 2026

**01.01.2026**
* Erstellung des GitHub-Repositories

**08.01.2026**
* Erste Inhalte zum Repository hinzugefügt (Default-Spiel)
* Test der Entwicklungsumgebung (GitHub Desktop zeigte leere Ordner nicht an)
* Hinzufügen von Spieler-Icons und einem Test-Sound

**09.01.2026**
* Minko tritt dem Projekt bei (erster Test-Commit)
* Hinzufügen eines Game-Menüs mit Buttons
* Test-Szene mit Test-Cube (später entfernt)

**10.01.2026**
* Erste spielbare Testversion des Spiels
  * Game Board Manager
  * Ladebares Spielfeld
  * Voxel-Modelle
  * Hauptmenü mit Play- und Quit-Button
  * Debugging per Print
  * Saubere Projektstruktur

**11.01.2026**
* Der König wird als neue Spielfigur hinzugefügt

**12.01.2026**
* Version 2 des Spiels
  * Cursor und Kamera (Testzwecke)
  * Verbessertes Spielfeld
  * Grafik- und Bugfixes
  * Entfernen ungenutzter Dateien

**13.01.2026**
* Erstellung des Hauptraums, in dem das Spiel stattfindet
* Wechsel von Meshes zu Szenen für Spielobjekte
* Outline-Versuch für Cubes (verworfen)

**16.01.2026**
* Spieler-Logik hinzugefügt
* Große Probleme mit Zugriff auf das Schul-Repository
* GitHub dient als Zeitnachweis
* Einführung des Turn Managers

**17.01.2026**
* Verbesserungen an Tischkamera und Hauptmenü
* Komplettes Overhaul von Musik, Menüs und Core-Code

**18.01.2026**
* Quality-of-Life-Updates
* Immersionsverbesserungen
* Sprint-Tasten
* Multiplayer-Experiment (später entfernt)
* Überarbeitung des Turn Managers

**24.01.2026**
* Großes Core-Update
  * Piece-ID-System
  * Turn Manager
  * Spiellogik

**25.01.2026**
* Multiplayer entfernt
* Debug-Funktionen ergänzt
* Musik-Fix

**26.–27.01.2026**
* Kleine Bugfixes und Stabilitätsupdates
* Finale Spiellogik balancen
