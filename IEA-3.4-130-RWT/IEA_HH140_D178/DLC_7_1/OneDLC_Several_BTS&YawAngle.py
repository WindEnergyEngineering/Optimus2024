import os
import shutil
import subprocess
import pyautogui
import time

# Define paths and directories
wind_directory = r'D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)\Local repos\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_7_1\Wind'  # Update this path
main_directory = r'D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)\Local repos\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_7_1'  # Update this path

# Define single output directory
output_directory = os.path.join(main_directory, 'Outputs')

# Ensure the output directory exists
def create_directory(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)

create_directory(output_directory)

# List all .bts files in the wind directory
def get_sorted_wind_files(directory):
    files = [file for file in os.listdir(directory) if file.endswith('.bts')]
    return sorted(files, key=lambda x: (float(x.split('_')[0][1:]), int(x.split('Seed')[1].split('.bts')[0])))

# Update inflow.dat file with the wind file information
def update_inflow_file(inflow_file_path, wind_file):
    with open(inflow_file_path, 'r') as inflow_file:
        inflow_lines = inflow_file.readlines()

    # Get the filename (without directory path)
    wind_file_name = os.path.basename(wind_file)

    # Use "./Wind\" explicitly to construct the relative path
    wind_file_relative_path = f'./Wind\\{wind_file_name}'

    # Update the line in inflow.dat
    for i, line in enumerate(inflow_lines):
        if 'FileName_BTS' in line:
            inflow_lines[i] = f'"{wind_file_relative_path}" FileName_BTS - Name of the Full field wind file to use (.bts)\n'

    # Write the modified inflow.dat back
    with open(inflow_file_path, 'w') as inflow_file:
        inflow_file.writelines(inflow_lines)


# Extract wind speed and seed from the filename
def extract_wind_speed_and_seed(wind_file):
    wind_speed_str = wind_file.split('_')[0][1:]  # Extract the part after 'V'
    wind_speed = float(wind_speed_str)  # Convert to float
    seed_str = wind_file.split('Seed')[1].split('.bts')[0]  # Extract the seed (e.g., '-368720836')
    seed = int(seed_str)  # Convert seed to integer
    return wind_speed, seed

# Update ElastoDyn.dat file for different yaw angles
def update_elastodyn_file(elasto_file_path, yaw_angle):
    with open(elasto_file_path, 'r') as elasto_file:
        elasto_lines = elasto_file.readlines()

    for i, line in enumerate(elasto_lines):
        if 'Initial or fixed nacelle-yaw angle' in line:
            elasto_lines[i] = f'{yaw_angle}                    NacYaw      - Initial or fixed nacelle-yaw angle (degrees)\n'

    with open(elasto_file_path, 'w') as elasto_file:
        elasto_file.writelines(elasto_lines)

# Run OpenFAST simulation
def run_openfast_simulation(batch_file):
    subprocess.call(f'cmd /c "{batch_file}" < nul', shell=True)
    time.sleep(5)  # Wait for the Command Prompt to appear
    pyautogui.press('ctrl')  # Automate "press any key to continue"

# Move and rename output files to a single output directory
def move_and_rename_output_files(wind_speed, seed, yaw_angle):
    output_files = ['IEA-3.4-130-RWT.out', 'IEA-3.4-130-RWT.outb']
    new_output_name = f'OPT-MP-V{wind_speed}_S{seed}_{yaw_angle}'

    for file in output_files:
        file_path = os.path.join(main_directory, file)
        if os.path.exists(file_path):
            new_file_name = new_output_name + file[file.rfind('.'):]
            new_file_path = os.path.join(output_directory, new_file_name)
            shutil.move(file_path, new_file_path)
            print(f'Moved and renamed {file} to {new_file_name}')
            print("/////////////////////////////////////////////////////////////////////////")

def main():
    # Process each wind file
    wind_files = get_sorted_wind_files(wind_directory)

    for wind_file in wind_files:
        # Update InflowFile.dat with wind file information
        inflow_file_path = os.path.join(main_directory, 'IEA-3.4-130-RWT_InflowFile.dat')
        update_inflow_file(inflow_file_path, wind_file)

        # Extract wind speed and seed
        wind_speed, seed = extract_wind_speed_and_seed(wind_file)
        print(f'Updated inflow.dat with Wind Speed {wind_speed} and Seed {seed}')

        # Update ElastoDyn for different yaw angles
        yaw_angles = [-8.0, 0.0, 8.0]
        elasto_file_path = os.path.join(main_directory, 'IEA-3.4-130-RWT_ElastoDyn.dat')
        for yaw_angle in yaw_angles:
            update_elastodyn_file(elasto_file_path, yaw_angle)

            # Run OpenFAST simulation
            start_openfast_batch = os.path.join(main_directory, 'run_OpenFAST.bat')
            run_openfast_simulation(start_openfast_batch)

            # Move and rename output files to a single output directory
            move_and_rename_output_files(wind_speed, seed, yaw_angle)

if __name__ == '__main__':
    main()
