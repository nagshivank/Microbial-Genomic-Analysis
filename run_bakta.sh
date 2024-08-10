#!/bin/bash

# Get the database directory 
db_directory="$1"
# Get the input directory
input_directory="$2"

# Loop over the files in the input directory
for fasta_file in "$input_directory"/*.fasta; do
    # Create an output directory for each fasta file
    output_dir="./output/$(basename "$fasta_file" .fasta)"
    mkdir -p "$output_dir"

    # Run Bakta on each Assembly
    bakta --db "$db_directory" --threads 2 --force -o "$output_dir" "$fasta_file"
done
