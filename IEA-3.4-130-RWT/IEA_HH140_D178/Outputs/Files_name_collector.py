import os
import pandas as pd
 
# Define the folder path (use raw string)
folder_path = r"C:\Users\carlo\Documents\GitHub\Optimus2024\IEA-3.4-130-RWT\IEA_HH140_D178\Outputs\Data\DLC14"
 
# Specify the prefix to add before each file name (single backslash)
prefix = ".\\Data\\DLC14\\"
 
# Get a list of all files in the folder and add the prefix
file_names = [prefix + file_name for file_name in os.listdir(folder_path)]
 
# Create a DataFrame
df = pd.DataFrame(file_names, columns=["File Names"])
 
# Save to Excel
output_file = "file_names_list_with_prefix.xlsx"
df.to_excel(output_file, index=False)
 
print(f"File names with prefix have been saved to {output_file}")