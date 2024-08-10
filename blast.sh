#!/bin/bash

tcda=$1
tcdb=$2
assemblies_path=$3  # The directory containing the assembly files.
output_dir="outputs"  # Directory where the results will be stored. Modify if necessary.

#Ensuring the output directory is present
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

# Creating a BLAST database for each assembly
for assembly in "$assemblies_path"/*.fasta; do
    db_name=$(basename "$assembly" .fasta)
    makeblastdb -in "$assembly" -dbtype nucl -out "$output_dir/${db_name}_db"
done

# Running BLAST for tcdA and tcdB against each assembly database
for assembly in "$assemblies_path"/*.fasta; do
    db_name=$(basename "$assembly" .fasta)
    echo "Running BLAST for $db_name against tcdA"
    blastn -query "$tcda_ref" -db "$output_dir/${db_name}_db" -out "$output_dir/${db_name}_tcda_blast.out" -perc_identity 70 -qcov_hsp_perc 70 -outfmt 6
    echo "Running BLAST for $db_name against tcdB"
    blastn -query "$tcdb_ref" -db "$output_dir/${db_name}_db" -out "$output_dir/${db_name}_tcdb_blast.out" -perc_identity 70 -qcov_hsp_perc 70 -outfmt 6
done

# Parsing the output
for file in "$output_dir"/*_blast.out; do
    echo "Parsing results for $file"
    awk '{ if($3 >= 70 && ($4 / $5) * 100 >= 70) print $0; }' "$file" > "${file%.out}_parsed.out"
done
