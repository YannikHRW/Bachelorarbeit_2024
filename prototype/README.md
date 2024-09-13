# Einrichtung des Swift Projekts

## Systemvoraussetzungen

- **CocoaPods**:
   
   Es muss sichergestellt werden, dass CocoaPods auf dem System installiert ist. Falls dies noch nicht geschehen ist, kann CocoaPods mit folgendem Befehl installiert werden:

   ```bash
   sudo gem install cocoapods
   ```
## Installation der Pod-Abhängigkeiten

1. **Abhängigkeiten installieren**:

   Um die in der Podfile angegebenen Abhängigkeiten zu installieren, wird der folgende Befehl ausgeführt:

   ```bash
   pod install --repo-update
   ```

2. **Das Projekt mit der vorhandenen .xcworkspace-Datei öffnen**:

    Da die .xcworkspace-Datei bereits vorhanden ist, sollte das Projekt mit dieser Datei geöffnet werden, um sicherzustellen, dass die Abhängigkeiten korrekt integriert sind:

   ```bash
   open TestApp3.xcworkspace
   ```
