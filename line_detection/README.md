# Python Environment for Data Analysis

Dieses Verzeichnis enthält die Python-Umgebung für die Datenverarbeitung und Analyse.

## Systemvoraussetzungen

- **Conda**: [Miniconda](https://docs.conda.io/en/latest/miniconda.html) oder [Anaconda](https://www.anaconda.com/products/distribution) muss installiert sein.
- **Python**: Version 3.11 (wird durch Conda bereitgestellt).

## Einrichtung der Python-Umgebung

Um die Python-Umgebung einzurichten, sind folgende Schritte erforderlich:

1. **Repository klonen**:

   Das Repository kann mit folgendem Befehl geklont werden:

   ```bash
   git clone https://github.com/YannikHRW/Bachelorarbeit_2024.git
   cd Bachelorarbeit_2024/line_detection
   ```

2. **Conda-Umgebung erstellen**:

   Die Conda-Umgebung wird mit diesem Befehl erstellt:

   ```bash
   conda env create -f environment.yml
   ```

3. **Umgebung aktivieren**:

   Die Umgebung kann mit folgendem Befehl aktiviert werden:

   ```bash
   conda activate myenv
   ```

4. **Installation überprüfen**:

   Um sicherzustellen, dass alle Pakete korrekt installiert sind, kann folgender Befehl ausgeführt werden:

   ```bash
   python -c "import numpy; import cv2; import skopt; print('All packages are working!')"
   ```

5. **Optimierung starten**:

   ```bash
   python3 optimizer.py
   ```

6. **Testdatensatz prüfen**:

   ```bash
   python3 test.py
   ```
