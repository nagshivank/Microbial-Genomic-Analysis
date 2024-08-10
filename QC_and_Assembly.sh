#!/bin/bash

# Set bash options
set -eoux pipefail

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

input_dir="$1"
output_dir="$2"

# Iterate over each gzipped paired-end fastq file in the input directory
for file in "$input_dir"/*_R1.fastq.gz
do
    # Extract the file name without extension
    filename=$(basename -s '_R1.fastq.gz' -a $file)

    # Create file directories
    mkdir -p "$output_dir"/{fastqc,fastp,shovill,quast}/$filename

    # Run fastqc on the input fastq file
    fastqc "$file" -o "$output_dir"/fastqc/$filename

    # Run fastp on the input fastq file
    fastp \
        --in1 "$file" \
        --in2 $(echo $file | sed 's/_R1/_R2/') \
        --out1 "$output_dir/fastp/$filename/$filename"_R1_trimmed.fastq.gz \
        --out2 "$output_dir/fastp/$filename/$filename"_R2_trimmed.fastq.gz \
        --qualified_quality_phred 30 \
        --length_required 20 \
        --dedup \
        --cut_front \
        --cut_tail \
        --cut_front_mean_quality 30 \
        --cut_tail_mean_quality 30

    # Run shovill on the trimmed reads
    shovill \
        --outdir "$output_dir/shovill/$filename" \
        --R1 "$output_dir/fastp/$filename/$filename"_R1_trimmed.fastq.gz \
        --R2 "$output_dir/fastp/$filename/$filename"_R2_trimmed.fastq.gz \
        --force \
        --minlen 1000 \
        --mincov 5 \
        --assembler spades

    # Run quast on the assembly
    quast.py \
        --pe1 "$output_dir/fastp/$filename/$filename"_R1_trimmed.fastq.gz \
        --pe2 "$output_dir/fastp/$filename/$filename"_R2_trimmed.fastq.gz \
        "$output_dir/shovill/$filename/contigs.fa"
done