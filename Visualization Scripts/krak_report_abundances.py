import pandas as pd
import numpy as np
import sys
import os
import matplotlib.pyplot as plt
import warnings

# Suppress FutureWarning
warnings.simplefilter(action='ignore', category=FutureWarning)

# Analyze Kraken Report

data_dir = "krak_report"

files_with_extension = []

# Iterate over all files in the directory
for file_name in os.listdir(data_dir):
    files_with_extension.append(file_name)
        
combined_kreport_dict = {}

for kreport in files_with_extension:
    file_path = os.path.join(data_dir, kreport)
    file_name = kreport.split(".")[0]
    # Read the TSV file into a DataFrame with no headers
    df = pd.read_csv(file_path, sep='\t', header=None)

    # Filter the DataFrame to include only lines where the 4th column is equal to "G" and 1st column (abundance) is more than 0.1
    filtered_df = df[( (df[3] == 'G') | (df[3] == 'U') ) & (df[0] >= 0)]
    
    # Make a copy of the DataFrame to avoid SettingWithCopyWarning
    filtered_df = filtered_df.copy()
    
    # Strip whitespace from values in column 5
    filtered_df[5] = filtered_df[5].str.strip()
    
    # Calculate the sum of abundance values
    sum_abundance = filtered_df[0].sum()

    # Calculate the remainder to make the total 100%
    remainder = 100 - sum_abundance

    # Sum up rows where abundance is less than 0.1
    other_row = filtered_df[filtered_df[0] < 0.1].sum(axis=0)

    # Add the remainder to the "Other" row
    other_row[0] += remainder

    # Set the genus name as "Other"
    other_row[5] = "Other"

    # Add the summed row to the DataFrame
    filtered_df = filtered_df.append(other_row, ignore_index=True)

    # Remove the rows where abundance is less than 0.1
    filtered_df = filtered_df[filtered_df[0] >= 0.1]
        
    genus_abundance_dict = dict(zip(filtered_df[5], filtered_df[0]))
    
    combined_kreport_dict[file_name] = genus_abundance_dict
    
# Create merged dataframe of combined_kreport_dict
merged_df = pd.DataFrame(combined_kreport_dict).fillna(0)  # Fill missing values with 0

# Calculate average abundance across all samples
average_abundance = merged_df.mean(axis=1)

# Sort genera based on average abundance and select the top 20
top_20_genera = average_abundance.sort_values(ascending=False)

# Filter merged DataFrame based on top 20 genera
filtered_merged_df = merged_df.loc[top_20_genera.index]

# Plotting
plt.figure(figsize=(20, 10))
plt.ylim(0, 100)

for i, genus in enumerate(filtered_merged_df.index):
    plt.bar(filtered_merged_df.columns, filtered_merged_df.loc[genus], bottom=filtered_merged_df.iloc[:i].sum(), label=genus)

plt.xlabel("Sample")
plt.ylabel("Relative Abundance %")
plt.legend()
plt.title("Kraken2: Relative Abundance per Sample")
plt.xticks(rotation=45)  # Rotate x-axis labels for better readability
plt.tight_layout()

# Save the figure to a PNG file
plt.savefig('krak_report_abundances.png')

plt.show()