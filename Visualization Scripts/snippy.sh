#!/usr/bin/bash

conda install -c conda-forge -c bioconda -c defaults snippy iqtree figtree

#Run Snippy on all the assembly files (30 files total)

for assembly in scaffolds/processed*_shovill_spades.fasta; do
	sample_name=$(basename "${assembly}" _shovill_spades.fasta);
	snippy \
		--cpus 4 \
		--outdir mysnps-"${sample_name}" \
	--ref ~/GCA_018885085.1_ASM1888508v1_genomic.fna \
	--CT "${assembly}";
done

ls -alhtr mysnps-*/snps.vcf

#Identify core SNPs among all samples
snippy-core
	--prefix core \
	--ref ~/GCA_018885085.1_ASM1888508v1_genomic.fna \
	mysnps-*

#Infer phylogeny
iqtree \
	-nt AUTO
	-st DNA \
	-s core.aln

#View tree
figtree *.treefile
