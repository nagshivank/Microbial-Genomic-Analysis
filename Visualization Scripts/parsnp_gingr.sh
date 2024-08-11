conda create -n harvestsuite -c bioconda parsnp harvesttools -y
conda activate harvestsuite

mkdir ~/project/parsnp_input_assemblies
cd ~/project/parsnp_input_assemblies

for file in ~/project/Assemblies/*.fasta; do
  ln -sv "${file}" "$(basename ${file})"
done


parsnp \
 -d parsnp_input_assemblies \
 -r ! \
 -o parsnp_outdir \
 -p 3
 
 
 
 # GINGR GUI installed separately (gingr-Linux64-v1.3.tar.gz)
 # Downloaded gingr https://github.com/marbl/gingr/releases/download/v1.3/gingr-Linux64-v1.3.tar.gz
 
 tar -xvzf gingr-Linux64-v1.3.tar.gz
 
 # Used .tree and .ggr file for visualization
 # Visualization done in GUI
