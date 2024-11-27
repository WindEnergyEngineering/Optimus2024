#Developed by Araz Hamayeli Mehrabani, Flensburg University of Applied Sciences
import os
import shutil
import subprocess
import pyautogui
import time
# from pyfiglet import Figlet

# Define the directory where your wind files are located
wind_directory = r'C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\Wind\DLC61_EWM50_37'  # Update this path to the actual location
#hydrodyn_directory = '../Wave'  # Update this path to the actual location
main_directory = r'C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_6_1'  # Update this path
second_directory = r'C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178'
# List all .bts files in the wind directory
wind_files = [file for file in os.listdir(wind_directory) if file.endswith('.bts')]

# Sort wind files based on wind speed and seed number
wind_files.sort(key=lambda x: (float(x.split('_')[0][1:]), int(x.split('Seed')[1].split('.bts')[0])))


for wind_file in wind_files:
    # Load the current IEA-3.4-130-RWT_InflowFile.dat file
    inflow_file_path = os.path.join(main_directory, 'IEA-3.4-130-RWT_InflowFile.dat')

    with open(inflow_file_path, 'r') as inflow_file:
        inflow_lines = inflow_file.readlines()

    # Find the line containing FileName_BTS and update it
    for i, line in enumerate(inflow_lines):
        if 'FileName_BTS' in line:
            inflow_lines[i] = f'"{os.path.join(wind_directory, wind_file)}" FileName_BTS - Name of the Full field wind file to use (.bts)\n'

    # Extract the wind speed and seed
    next_wind_speed = int(wind_file.split('_')[0][1:])
    next_seed = int(wind_file.split("Seed")[1].split(".bts")[0])

    # Find the appropriate hydrodyn file for the current wind speed
    #hydrodyn_filename = f'OPT-20-295-Monopile_HydroDyn{next_wind_speed}.dat'
    #hydrodyn_source_path = os.path.join(hydrodyn_directory, hydrodyn_filename)
    #hydrodyn_target_path = os.path.join(main_directory, hydrodyn_filename)

    # Write the modified inflow.dat file
    with open(inflow_file_path, 'w') as inflow_file:
        inflow_file.writelines(inflow_lines)

    # Create a list of previous hydrodyn files and remove them
    #previous_hydrodyn_files = [f'OPT-20-295-Monopile_HydroDyn{x}.dat' for x in range(1, next_wind_speed)]
    #for previous_hydrodyn_file in previous_hydrodyn_files:
    #    previous_hydrodyn_path = os.path.join(main_directory, previous_hydrodyn_file)
    #    if os.path.exists(previous_hydrodyn_path):
    #        os.remove(previous_hydrodyn_path)

    # Replace it with the new hydrodyn file
    #shutil.copy(hydrodyn_source_path, hydrodyn_target_path)
    print("########################################################################################")
    #print(f'Replaced previous hydrodyn files with {hydrodyn_filename} in {main_directory}')
    print(f'Updated inflow.dat with Wind Speed {next_wind_speed} and Seed {next_seed}')
    print("########################################################################################")
    
    # Modify the IEA-3.4-130-RWT.fst file to dynamically update HydroDyn reference
    fst_file_path = os.path.join(main_directory, 'IEA-3.4-130-RWT.fst')

    with open(fst_file_path, 'r') as fst_file:
        fst_content = fst_file.read()

    # Extract the line that contains HydroDyn reference
    #lines = fst_content.split('\n')
    #for i, line in enumerate(lines):
    #    if 'HydroFile' in line:
    #        current_hydrodyn_file = line.split('"')[1]
    #        new_hydrodyn_reference = f'OPT-20-295-Monopile_HydroDyn{next_wind_speed}.dat'
    #        lines[i] = f'"{new_hydrodyn_reference}"   HydroFile   - Name of file containing hydrodynamic input parameters (quoted string)'

    # Update the FST content
    #fst_content = '\n'.join(lines)

    with open(fst_file_path, 'w') as fst_file:
        fst_file.write(fst_content)

    #print(f'Updated fst file with HydroDyn reference to {new_hydrodyn_reference}')
    YawAngle = [-8.0, 0.0, 8.0]
    for j in YawAngle:
        elasto_file_path = os.path.join(main_directory, 'IEA-3.4-130-RWT_ElastoDyn.dat')

        with open(elasto_file_path, 'r') as elasto_file:
            elasto_lines = elasto_file.readlines()

            # Find the line containing FileName_BTS and update it
        for i, line in enumerate(elasto_lines):
            if 'Initial or fixed nacelle-yaw angle' in line:
                elasto_lines[i] = f'{j}                    NacYaw      - Initial or fixed nacelle-yaw angle (degrees)\n'

        with open(elasto_file_path, 'w') as elasto_file:
            elasto_file.writelines(elasto_lines)

        # Run start_OpenFAST_v3-41.bat with input redirection
        start_openfast_batch = os.path.join(main_directory, 'run_OpenFAST.bat')
        subprocess.call(f'cmd /c "{start_openfast_batch}" < nul', shell=True)

        # Automate "press any key to continue"
        time.sleep(5)  # Adjust this delay as needed to give the Command Prompt time to appear
        pyautogui.press('ctrl')

        # Define the output directory and DLC directory
        output_directory = os.path.join(second_directory, 'Outputs')

        #Check if the Outputs directory exists; if not, create it
        if not os.path.exists(second_directory):
            os.makedirs(output_directory)

        dlc_directory = os.path.join(output_directory, 'DLC61')

        # Check if the DLC directory exists; if not, create it
        if not os.path.exists(dlc_directory):
            os.makedirs(dlc_directory)

        # Move the output files to the DLC directory and rename them based on wind speed and seeds
        output_files = ['IEA-3.4-130-RWT.out', 'IEA-3.4-130-RWT.outb']
        new_output_name = f'OPT-MP-V{next_wind_speed}_S{next_seed}_{j}'

        for file in output_files:
            file_path = os.path.join(main_directory, file)
            if os.path.exists(file_path):
                new_file_name = new_output_name + file[file.rfind('.'):]
                new_file_path = os.path.join(dlc_directory, new_file_name)
                shutil.move(file_path, new_file_path)
                print(f'Moved and renamed {file} to {new_file_name}')
                print("/////////////////////////////////////////////////////////////////////////")