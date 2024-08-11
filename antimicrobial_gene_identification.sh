#create amr for AMRFinderPlus environment
conda create amr
conda activate amr

#install appropriate packages
mamba install ncbi-amrfinderplus

#make output directory
mkdir -p amrfinder_output

#update/download the database (database version : 2024-01-31)
amrfinder -u

# go through the .faa files and run amrfinder
for faa_file in faa/*.faa; do
    base_name=$(basename "$faa_file" .faa)
    amr_output="amrfinder_output/${base_name}_amrfinder_output.tsv"
    amrfinder -p "$faa_file" --plus -o "$amr_output"
done

####### AMRfinder took ~20 seconds/faa files so about 10 minutes to complete 30.#######

#the files names are getting long so to shorten them, I will use a simple bash loop
# to reflect just the sample identifier
for file in processed_B*; do
    # take the B0... number from the filename and rename the file
    new_name=$(echo "$file" | grep -o 'B[0-9]*')
    mv "$file" "${new_name}.tsv"
done

# an amrfinder filtering script was adapted from https://github.com/michaelwoodworth/AMRFinder_scripts/blob/master/00_amrfinder_filter.py
# the purpose of the script was to filter for complete genes

for tsv in amrfinder_output/*.tsv; do
    base_name=$(basename "$tsv".tsv)
    python 00_amrfinder_filter.py -i $tsv -o "${base_name}_filtered.tsv" -m add_partial_end -j -v; 
done

#the next script was adapted from https://github.com/michaelwoodworth/AMRFinder_scripts/blob/master/01_amrfinder_binary_matrix.py
# the purpose of this one is to build a presence/absence matrix in binary format
touch binary_amr.tsv
python 01_amrfinder_binary_matrix.py -i filtered_amr -o binary_amr.tsv -v

## run script to generate more legible matrix.