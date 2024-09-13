# Installation der Pod-Abhängigkeiten in einem Swift/Xcode-Projekt

Diese Anleitung beschreibt die Schritte, um die Pod-Abhängigkeiten in einem bestehenden Swift/Xcode-Projekt zu installieren, wenn bereits eine `Podfile` vorhanden ist.

## Voraussetzungen

1. **CocoaPods**:
   
   Es muss sichergestellt werden, dass CocoaPods auf dem System installiert ist. Falls dies noch nicht geschehen ist, kann CocoaPods mit folgendem Befehl installiert werden:

  ```bash
  cd prototype
  sudo gem install cocoapods
  ```

2. **Abhängigkeiten installieren**:

   Um die in der Podfile angegebenen Abhängigkeiten zu installieren, wird der folgende Befehl ausgeführt:

   ```bash
   pod install
   ```

3. **Das Projekt mit der vorhandenen .xcworkspace-Datei öffnen**:

    Da die .xcworkspace-Datei bereits vorhanden ist, sollte das Projekt mit dieser Datei geöffnet werden, um sicherzustellen, dass die Abhängigkeiten korrekt integriert sind:

   ```bash
   open TestApp3.xcworkspace
   ```
