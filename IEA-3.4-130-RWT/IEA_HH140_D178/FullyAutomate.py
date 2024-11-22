#Developed by Araz Hamayeli Mehrabani, Flensburg University of Applied Sciences
import subprocess
import os
import sys
# from art import *
# from pyfiglet import Figlet

# List of dictionaries, each containing the script name and its directory
scripts = [
    {"script": "CaBru_DLC_12.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_1_2"},
    {"script": "CaBru_DLC_14.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_1_4"},
    {"script": "CaBru_DLC_51.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_5_1"},
    {"script": "CaBru_DLC_61.py", "directory": r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_6_1"},
]

for script_info in scripts:
    script = script_info["script"]
    directory = os.path.basename(script_info["directory"])
    

    print("############################################")
    print(f"Running {script} in {directory}...")
    print("############################################")
    # print("######################")
    # # tprint(f"Running {script} in {directory}...")
    # #tprint gives a random font which sometimes doesn't support all characters, therefore pyfiglet have been used
    # print(Figlet(font='slant', width=150).renderText(f"Running {script} in {directory}..."), end='')
    # print("######################")
    
    # Change to the script's directory
    os.chdir(script_info["directory"])
    
    # Run the script
    process = subprocess.Popen(["python", script], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1, universal_newlines=True, env=dict(os.environ, PYTHONUNBUFFERED="1"))
    
    # Read and print the output while the script is running
    for line in process.stdout:
        print(f"{directory}: {line.strip()}")
        sys.stdout.flush()  # Flush the buffer to ensure real-time printing
    
    for line in process.stderr:
        print(f"{directory}: Error: {line.strip()}")
        sys.stderr.flush()  # Flush the buffer to ensure real-time printing
    
    # Wait for the script to finish
    process.wait()
    
    # Print the final output and errors (if any)
    stdout, stderr = process.communicate()
    print(stdout)
    print(stderr)
    
    # Check if the script ran successfully
    if process.returncode == 0:
        print(f"{script} in {directory} completed successfully.")
    else:
        print(f"Error running {script} in {directory}.")
    
    print("=" * 40)

print("All scripts completed.")

