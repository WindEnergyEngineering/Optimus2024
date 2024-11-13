#Developed by Araz Hamayeli Mehrabani, Flensburg University of Applied Sciences
import subprocess
import os
import sys
# from art import *
# from pyfiglet import Figlet

# List of dictionaries, each containing the script name and its directory
scripts = [
    {"script": "DLC51.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC5.1\DLC51"},
    {"script": "DLC61.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC6.1_+8\DLC61"},
    {"script": "DLC61.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC6.1_-8\DLC61"},
    {"script": "DLC71.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC7.1_30\DLC71"},
    {"script": "DLC71.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC7.1_60\DLC71"},
    {"script": "DLC71.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC7.1_90\DLC71"},
    {"script": "DLC71.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC7.1_120\DLC71"},
    {"script": "DLC71.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC7.1_150\DLC71"},
    {"script": "DLC71.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC7.1_180\DLC71"},
    {"script": "DLC111.py", "directory": r"C:\Users\Araz\Desktop\Flensburg\Big P\295\V5\Opt_20_295\Autorun4Samaan\Autorun forme_VII\DLC11.1\DLC111"}
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
