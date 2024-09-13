# Python Environment

Dieses Verzeichnis enthält die Python-Umgebung für die Datenverarbeitung.

## Systemvoraussetzungen

- **Conda**: [Miniconda](https://docs.conda.io/en/latest/miniconda.html) oder [Anaconda](https://www.anaconda.com/products/distribution) muss installiert sein.
- **Python**: Version 3.11 (wird durch Conda bereitgestellt).
- **Bilddateien**: Die Verzeichnisse müssen von Google Drive bezogen und heruntergeladen werden unter folgendem [Link](https://drive.google.com/drive/folders/1datYVXUdwlbb4LL0PCkf67TQHw-Zrb_q?usp=sharing)
und in /line_detection/ abgelegt werden damit so in den python Dateien verwendet werden können.

## Einrichtung der Python-Umgebung

Um die Python-Umgebung einzurichten, sind folgende Schritte erforderlich:

1. **Conda-Umgebung erstellen**:

   Die Conda-Umgebung wird mit diesem Befehl erstellt:

   ```bash
   conda env create -f environment.yml
   ```

2. **Umgebung aktivieren**:

   Die Umgebung kann mit folgendem Befehl aktiviert werden:

   ```bash
   conda activate myenv
   ```

3. **Installation überprüfen**:

   Um sicherzustellen, dass alle Pakete korrekt installiert sind, kann folgender Befehl ausgeführt werden:

   ```bash
   python -c "import numpy; import cv2; import skopt; print('All packages are working!')"
   ```

4. **Optimierung starten**:

   ```bash
   python3 optimizer.py
   ```

   Nachdem die optimierung durchgeführt wurde, werden am Ende die besten Ergebnisse auf der Konsole ausgegeben. Diese müssen dann manuell in die test.py übernommen werden.

5. **Testdatensatz prüfen**:

   Beim Ausführen der test.py wird dann geprüft, in welchen Test-Bildern Linien mit den eingestellten Parametern erkannt wurden.

   ```bash
   python3 test.py
   ```
