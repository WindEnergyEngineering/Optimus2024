import os
import random
import subprocess
import shutil

# Function to update the TurbSim.inp file
def update_turbsim_file(file_path, seed, speed):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()

        # Update only the numeric value in line 4 (RandSeed1)
        parts = lines[3].split()
        parts[0] = str(seed)  # Replace the first part with the new seed
        lines[3] = " ".join(parts) + "\n"

        # Update only the numeric value in line 37 for speed
        lines[36] = f"{speed}\n"

        with open(file_path, 'w') as file:
            file.writelines(lines)

    except Exception as e:
        print(f"Error updating TurbSim file: {e}")
        raise

# Function to run TurbSim using PowerShell with output monitoring
def run_turbsim_in_powershell(turbsim_dir):
    try:
        # Define the PowerShell command to change directory and run TurbSim
        command = f'cd "{turbsim_dir}" ; .\\Turbsim64.exe .\\TurbSim.inp'

        # Run the command in PowerShell and capture the output
        process = subprocess.Popen(
            ["powershell", "-Command", command],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # Monitor the output for completion
        while True:
            output = process.stdout.readline()
            if output:
                print(output.strip())  # Print the output to the Python console
            if "TurbSim terminated normally." in output:
                print("TurbSim analysis completed successfully.")
                break  # Exit the loop when analysis is complete
            
            # Check if the process has terminated without the expected output
            if process.poll() is not None:
                break

        # Ensure the process has completely finished
        process.wait()

        if process.returncode != 0:
            print("Error: TurbSim execution failed.")
            raise Exception("TurbSim execution failed.")

    except Exception as e:
        print(f"Error running TurbSim in PowerShell: {e}")
        raise

# Function to run TurbSim and handle output file
def run_turbsim(turbsim_exe_path, turbsim_file_path, output_folder, seed, speed):
    try:
        # Ensure the output folder exists
        os.makedirs(output_folder, exist_ok=True)
        
        # Run TurbSim using PowerShell
        turbsim_dir = os.path.dirname(turbsim_exe_path)
        run_turbsim_in_powershell(turbsim_dir)

        # Rename the output file
        output_file = os.path.join(turbsim_dir, "TurbSim.bts")
        new_output_name = f"V{speed}_Seed{seed}.bts"
        new_output_path = os.path.join(output_folder, new_output_name)

        if os.path.exists(output_file):
            shutil.move(output_file, new_output_path)
            print(f"File saved: {new_output_path}")
        else:
            raise FileNotFoundError(f"Expected output file not found: {output_file}")

    except Exception as e:
        print(f"Error running TurbSim: {e}")
        raise

# Main automation function
def automate_turbsim(file_path, turbsim_exe, output_folder, speeds, seeds_per_speed):
    try:
        for speed in speeds:
            for i in range(seeds_per_speed):
                # Generate a random seed within the valid range
                seed = random.randint(-2147483648, 2147483647)
                print(f"Processing Speed: {speed}, Seed: {seed}")

                # Update TurbSim.inp file
                update_turbsim_file(file_path, seed, speed)

                # Run TurbSim
                run_turbsim(turbsim_exe, file_path, output_folder, seed, speed)

    except Exception as e:
        print(f"Automation failed: {e}")

# USER INPUTS
file_path = r"D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)\Local repos\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\Turbsim files\Turbsim\TurbSim.inp"  # Path to TurbSim.inp file
turbsim_exe = r"D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)\Local repos\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\Turbsim files\Turbsim\Turbsim64.exe"  # Path to TurbSim executable
output_folder = r"D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)\Local repos\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\Turbsim files\Turbsim\Output\DLC_4_2"  # Path to save output files
speeds = [9, 11, 13]  # Speeds to process
seeds_per_speed = 2  # Number of seeds per speed

# Run the automation
automate_turbsim(file_path, turbsim_exe, output_folder, speeds, seeds_per_speed)
