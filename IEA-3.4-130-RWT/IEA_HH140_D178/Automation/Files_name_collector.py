import os
import pandas as pd

# Define the folder path (use raw string)
folder_path = r"D:\Masters\2024\3rd semester\WEC Development Project 202425 (WiSe 2024)"

# Get a list of all files in the folder
file_names = os.listdir(folder_path)

# Create a DataFrame
df = pd.DataFrame(file_names, columns=["File Names"])

# Save to Excel
output_file = "file_names_list.xlsx"
df.to_excel(output_file, index=False)

print(f"File names have been saved to {output_file}")
