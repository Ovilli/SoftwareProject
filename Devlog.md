# Projekt: Rundenbasiertes Würfelspiel (Tactix)

## Allgemeine Informationen

**Mitarbeiter**
* Maxim Zlatin
* Minko Gohl

**Verwendete Programme & Tools**
* Godot Engine
* MagicaVoxel
* GitHub
* GitHub Desktop

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

**Verschiedene Hintergründe (Scenen)**
  * Strand Scene
  * Park
  * Andere Orte die eine Umgebung Interessant machen (etc.) 

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
* Eine möglichkeit sein Feedback an die DEV's zu senden

---

## Debug Steps

* `Debug.log("Ein einfaches Tool um zu debuggen")`
* `Globals.DEBUG : Bool = FALSE` (um den Debug Mode zu starten)
* Default Debug Menu von Godot

---

## Fails

* Multiplayer
* Schöne Modelle
* Outline

---

## Entwicklungszeitstrahl

### Entwicklung 2026

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


**2.-13.02.2026**
* Devlog Updates
* Erweiterung des Devlogs


**17.02.2026**
* Bug Fixes (Camera Pice Rotation)

**22.02.2026**
* Bug Fixes (Faces Values Updated)

**24.02.2026**
* Kleine Bug Fixes 
* Camera (Rotation) Verbessert
*Cube (Rotation)

**26.02.2026**
* Code Cleanup
* Kleine Fixes

**27.02.2026**
* Großes Update von Light Up Pieces 
* Überarbeitung und Turn MNG 
* Neu Todos hinzugefügt 
* Bug Fixes

**28.02.2026**
* Kleine Fixes für Light Up Pieces 
* Noch mehr Bug Fixes 
* Bug Fixes

**1.03.2026**
* Overlay Improvement

**5.03.2026**
* End Screen 
* Todos
* Qualtiy of Life Updates

**6.03.2026**
* Ui Bug Fixes

**13.03.2026**
* 2'ter versuc von Multiplayer
* UI (Multi) Hinzugefügt
* Windowmng
* Small Fixes

**14.03.2026**
* Added Tutorials
* Added Credits
* Added Skins
* Added Sound effects

**15.03.2026**
* Small Fixes

**16.03.2026**
* Skin Support Working

**18.03.2026**
* Fixes
* Small test Animation

**19.l03.2026**
* Added Test Scene
* Small Anim Fixes

**20.03.20206**
* Fixes to Camera
* Git











---
# Scripts

**Turn Mng.gd**

**Globals.gd**


<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/ad05190c-c049-4e03-85e8-8557552aa627" />

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/5eab3823-ff99-46aa-941d-c4e23fe49902" />

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/e725e20e-006d-4697-8004-5ee44daf05a0" />

<img width="963" height="624" alt="image" src="https://github.com/user-attachments/assets/92941d56-c569-4d32-a66f-deeb5620ebd0" />

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/2a189950-9250-4b72-8d74-c6c2543d7f90" />
 
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/074c61b6-5c2b-497b-8d55-4082124cf172" />

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/8944f538-c0e6-4f28-b5d6-4bab45118d3d" />

### Danke fürs Durchlesen

-----
[![Godot](https://img.shields.io/badge/Godot-Blue-667eea?style=for-the-badge&logo=godot-engine&logoColor=white)](https://godotengine.org/)


[![GitHub](https://img.shields.io/badge/GitHub-Ovilli-181717?style=for-the-badge&logo=github)](https://github.com/Ovilli)

[![GitHub](https://img.shields.io/badge/GitHub-Hell0Tears-181717?style=for-the-badge&logo=github)](https://github.com/Hell0Tears)

[![License](https://img.shields.io/badge/License-MIT-667eea?style=for-the-badge)](LICENSE)
