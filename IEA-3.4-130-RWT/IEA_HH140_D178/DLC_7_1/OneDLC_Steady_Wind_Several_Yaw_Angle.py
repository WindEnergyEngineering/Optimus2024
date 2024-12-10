import os
import subprocess
import time
import shutil

# Define main directory
main_directory = r'D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)\Local repos\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_7_1'  # Update this path
output_directory = r'D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)\Local repos\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\DLC_7_1\Outputs\DLC71\Steady'  # Specify the desired output directory
yaw_angles = [-15.0, 0.0, 15.0]  # Define yaw angles to iterate

# Ensure output directory exists
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# Retry mechanism for running OpenFAST
def run_openfast(batch_file, retries=3):
    for attempt in range(retries):
        try:
            print(f"Attempt {attempt + 1} to run OpenFAST...")
            subprocess.call(f'cmd /c "{batch_file}" < nul', shell=True, cwd=main_directory)
            return
        except Exception as e:
            print(f"Error: {e}. Retrying in 2 seconds...")
            time.sleep(2)
    print("Failed to run OpenFAST after multiple attempts.")

# Iterate through yaw angles
for yaw_angle in yaw_angles:
    # Update ElastoDyn file for each yaw angle
    elasto_file_path = os.path.join(main_directory, 'IEA-3.4-130-RWT_ElastoDyn.dat')
    
    with open(elasto_file_path, 'r') as elasto_file:
        elasto_lines = elasto_file.readlines()
    
    for i, line in enumerate(elasto_lines):
        if 'NacYaw' in line:  # Look for the yaw angle line
            elasto_lines[i] = f'{yaw_angle}                    NacYaw      - Initial or fixed nacelle-yaw angle (degrees)\n'
    
    with open(elasto_file_path, 'w') as elasto_file:
        elasto_file.writelines(elasto_lines)
    
    print(f"Updated yaw angle to {yaw_angle} in ElastoDyn file.")

    # Run OpenFAST
    start_openfast_batch = os.path.join(main_directory, 'run_OpenFAST.bat')
    run_openfast(start_openfast_batch)

    # Move output files to the specified directory
    output_files = ['IEA-3.4-130-RWT.out', 'IEA-3.4-130-RWT.outb']
    for file in output_files:
        file_path = os.path.join(main_directory, file)
        if os.path.exists(file_path):
            new_file_name = f'Yaw_{yaw_angle}{os.path.splitext(file)[1]}'
            new_file_path = os.path.join(output_directory, new_file_name)
            shutil.move(file_path, new_file_path)
            print(f"Moved and renamed {file} to {new_file_name} in {output_directory}")

print("Simulation completed for all yaw angles.")
