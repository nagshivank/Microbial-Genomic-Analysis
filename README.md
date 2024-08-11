# Microbial-Genomic-Analysis

## Setting up the Environment
The requisite packages to be installed for the QC and Assembly run are listed in the *qc_assembly_env.yml* file.
<br><br>
The Gene Prediction and Annotation pipeline requires several tools to be installed-
- tRNAscan-SE
- Aragorn
- INFERNAL
- PILER-CR
- Pyrodigal
- PyHMMER
- Diamond
- Blast+
- AMRFinderPlus
- DeepSig

The scripts in the remaining sections account for the packages required for their execution.

---
## Quality Control, Assembly and Quality Assessment of Paired-End Read Files
The below script should be executed to first trim the paired-end FASTQ files, then assemble them using the Shovill pipeline, before performing Quality Assessment on the assembly. It should be given the path to the directory containing paired-end FASTQ read files.
```sh
bash QC_and_Assembly.sh <FastQ file directory> <Output Directory>
```
---


## Gene Prediction and Annotation
This pipeline takes the assembled contig FASTA files as input, predicts likely genes from them and provides funtional annotation information in GFF and other formats. The pipeline uses the Bakta tool implemented from command line, which was selected after a comparitive analysis of alternative tools. The steps to set up the pipeline and execute it on the assembly files to generate the annotations are listed below-

Bakta can be installed into a conda environment as follows-
```sh
conda install -c conda-forge -c bioconda bakta
```
The Bakta database needs to be downloaded as follows-
```sh
bakta_db download --output <database directory> --type full
```
To run the pipeline the directories containing the input assemblies and the Bakta database should be specified-
```sh
chmod +x run_bakta.sh
./run_bakta.sh <database directory> <input files directory>
```
### Output Details
The pipeline outputs annotation information in several formats-
- tsv: annotations as simple human readble TSV.
- .gff3: annotations & sequences in GFF3 format.
- .gbff: annotations & sequences in (multi) GenBank format.
- .embl: annotations & sequences in (multi) EMBL format.
- .fna: replicon/contig DNA sequences as FASTA.
- .ffn: feature nucleotide sequences as FASTA.
- .faa: CDS/sORF amino acid sequences as FASTA.
- .hypotheticals.tsv: further information on hypothetical protein CDS as simple human readble tab separated values.
- .hypotheticals.faa: hypothetical protein CDS amino acid sequences as FASTA.
- .json: all (internal) annotation & sequence information as JSON.
- .txt: summary as TXT.
- .png: circular genome annotation plot as PNG.
- .svg: circular genome annotation plot as SVG.
---

## Quality Control, Assembly and Quality Assessment of Paired-End Read Files
The previous section identified the unknown bacterial genome as belonging to *Clostridium difficile*, recently renamed as *Clostridioides difficile*. This section runs FastANI to calculate Average Nucleotide Identity (ANI) between query genomes and a reference genome, performs quality assessment with QUAST and CheckM, and conducts taxonomic classification using Kraken2 and Bracken, followed by visualization with Krona. Additionally, it includes scripts for detecting virulence factors and generating various plots to analyze and visualize the results.
### Downloading reference file for *Clostridioides difficile*
```sh
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/018/885/085/GCF_018885085.1_ASM1888508v1/GCF_018885085.1_ASM1888508v1_genomic.fna.gz
gunzip GCF_018885085.1_ASM1888508v1_genomic.fna.gz
```
### Running FastANI
```sh
for file in *.fna; do
  query_file="$file"
  reference_file="path_to_reference_folder/$file" 
  output_file="${file%.fna}_Output.tsv"
  fastani -q "$query_file" -r "$reference_file" -o "$output_file"
done
```
### Combining the results
```sh
output_file="compiled_results.tsv"
header="Query\tReference\t%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments"
echo -e "$header" > "$output_file"
for file in fastani/*.tsv; do 
  tail -n +2 "$file" >> "$output_file"
done
```
### Quality Assessment
Performing Quality Assessment through QUAST-
```sh
conda install -c bioconda quast
mkdir quast_out
quast -o quast_out/ g3_fastas/*.fna -r GCA_018885085.1_ASM1888508v1_genomic.fna
```
To perform Quality Assessment through CheckM, we first need to download the CheckM database, and then look for the strain of interest (*C. difficile*). We then run CheckM analysis on two threads on the assembly files to generate the final file TSV file with completeness and contamination percentages.
```sh
wget https://zenodo.org/records/7401545/files/checkm_data_2015_01_16.tar.gz
tar zxvf checkm_data_2015_01_16.tar.gz
echo 'export CHECKM_DATA_PATH=$HOME/checkm/db' >> ~/.bashrc
source ~/.bashrc
echo "${CHECKM_DATA_PATH}"
checkm taxon_list | grep 'difficile'
checkm taxon_set species "Clostridium difficile" Cd.markers
mkdir analysis
checkm analyze Cd.markers -x fna g3_fastas/ analysis/ -t 2
checkm qa -f checkm.taxon.qa.out -o 1 Cd.markers analysis/
sed 's/ \+ /\t/g' checkm.taxon.qa.out > checkm.tax.qa.out.tsv
cut -f 2- checkm.tax.qa.out.tsv > tmp.tab && mv tmp.tab checkm.tax.qa.out.tsv
sed -i '1d; 3d; $d' checkm.tax.qa.out.tsv
cp checkm.tax.qa.out.tsv quality.tsv
```
---

### Taxonomic Classification
Using Kraken2 and Bracken
```sh
bash taxonomic_classification.sh
```
Visualizing the results using Krona
```sh
conda install -c bioconda krona
ktImportTaxonomy -t 5 -m 3 -o multi-krona.html <name_of_the_reports>
```
### Detection of Virulent Factors
tcdA and tcdB are known virulent factors enabling the pathogenecity of *C. difficile*. BLASTing their sequences against the assemblies can help validate the taxonomy of the bacterium.
```sh
./blast.sh <tcda.fasta file> <tcdb.fasta file> <directory containing assemblies
```
### Visualizing the Findings
The ```ani_dotplot.py``` file generates a dot plot of coverage versus ANI from FastANI results. 
The ```krak_report_abundances.py``` file takes the high-level taxa assignments generated from Kraken2 or Bracken and generates a stacked bar plot of relative abundances.
The ```assembly_comparison_dotplot.R``` script plots the total length of the contigs versus the total number of contigs from the QUAST results in a dot plot.

---

## Comparitive Genomic Analysis
The ```antimicrobial_gene_identification.sh``` script runs AMRFinderPlus on the FASTA files to identify antimicrobial resistance genes. It then filters the results to include only complete genes and generates a binary presence/absence matrix from the filtered data, summarizing the resistance profiles of the samples.<br><br>
Following this, the ```AMR_Visualization.sh``` script visualizes antimicrobial resistance (AMR) gene profiles for different samples. It creates a bar plot showing the presence or absence of specific genes across samples, calculates the cumulative presence of each gene, and then generates pie charts that display the overall distribution and grouping of these genes by category.<br><br>
The ```parsnp_ginger.sh``` script needs to be executed to visualize the taxonomic tree for the identified species as in *gingr_display.png* and the ```snippy.sh``` script can be run to infer phylogeny based on the Single Nucleotide Polymorphisms (SNPs) present in the sample, as displayed in *cole.aln.tree.jpg*.
