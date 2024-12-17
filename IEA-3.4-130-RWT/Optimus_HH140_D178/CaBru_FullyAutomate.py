#Developed by Araz Hamayeli Mehrabani, Flensburg University of Applied Sciences
import subprocess
import os
import sys
# from art import *
# from pyfiglet import Figlet

# List of dictionaries, each containing the script name and its directory
scripts = [
    #{"script": "CaBru_DLC_12.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\DLC_1_2"},
    {"script": "CaBru_DLC_13.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\DLC_1_3"},
    #{"script": "CaBru_DLC_14.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\DLC_1_4_HighWindSpeed"},
    #{"script": "CaBru_DLC_14.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\DLC_1_4_LowWindSpeed"},
    #{"script": "CaBru_DLC_51.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\DLC_5_1"},
    #{"script": "CaBru_DLC_61.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\DLC_6_1"},
]

def run_python_script(script_path):
    try:
        # Ausführen des Python-Skripts
        subprocess.run(['python', script_path], check=True)
        print(f"Skript {script_path} erfolgreich ausgeführt.")
    except subprocess.CalledProcessError as e:
        print(f"Fehler beim Ausführen des Skripts {script_path}: {e}")

# Durch die Liste der Skripte iterieren und jedes Skript ausführen
for script_info in scripts:
    # Zum angegebenen Ordner wechseln
    os.chdir(script_info["directory"])
    
    # Skript ausführen
    run_python_script(script_info["script"])