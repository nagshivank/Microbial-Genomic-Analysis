#!/bin/bash 
 
KRAKEN2_DB="/home/sgs/7210/proj/krakendb1/" 
FASTQ_DIR="/home/sgs/7210/proj/fastp_out/" 

OUTPUT_DIR="/home/sgs/7210/proj/krak_out/"
BRACK_OUTPUT_DIR="/home/sgs/7210/proj/braken_out/"
OUTPUT_REP_DIR="/home/sgs/7210/proj/krak_report/"  

sample_names=$(ls ${FASTQ_DIR} | sed 's/_R[12].fastq.gz//' | sort | uniq) 
echo "${sample_names}" | wc -w


for sample_name in ${sample_names}; do 

        # Define input file names
        file_R1="${FASTQ_DIR}/${sample_name}_R1.fastq.gz"
        file_R2="${FASTQ_DIR}/${sample_name}_R2.fastq.gz"
        report_file="${OUTPUT_REP_DIR}/${sample_name}.krak_report"
        kraken_file="${OUTOUT_DIR}/${sample_name}.kraken"
        bracken_file="${BRACK_OUTOUT_DIR}/${sample_name}.bracken.tsv"
   
        # Run Kraken2         

        echo "Running Kraken2 for ${sample_name}..." 
        kraken2 --use-names --db ${KRAKEN2_DB} --report ${report_file} --paired ${file_R1} ${file_R2} > /home/sgs/7210/proj/krak_out/${sample_name}.kraken
                        
        echo "Kraken2 analysis for ${sample_name} completed." 
        echo " Running Bracken for ${sample_name}..." 
              
        bracken -d ${KRAKEN2_DB} -i ${report_file} -l S -o /home/sgs/7210/proj/braken_out/${sample_name}.bracken.tsv
        echo "Bracken analysis for ${sample_name} completed." 
done 

echo "All Kraken2 analyses completed." 










