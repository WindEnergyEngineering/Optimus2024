import os
import pandas as pd

# Define the folder path (use raw string)
folder_path = r"D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)\Local repos\Optimus2024\IEA-3.4-130-RWT\Optimus_HH140_D178\DLC_4_2\Outputs\DLC42\NEW Mass and inertia\10 sec before shutdown"

# Specify the prefix to add before each file name (single backslash)
prefix = ".\\10_sec_before\\"

# Get a list of all files in the folder and add the prefix
file_names = [prefix + file_name for file_name in os.listdir(folder_path)]

# Create a DataFrame
df = pd.DataFrame(file_names, columns=["File Names"])

# Save to Excel
output_file = "file_names_list_with_prefix.xlsx"
df.to_excel(output_file, index=False)

print(f"File names with prefix have been saved to {output_file}")
