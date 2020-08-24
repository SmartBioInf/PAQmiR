#!/bin/bash

# load project configuration
source config.txt

################################
# create index folder (if needed)
echo "\n#### Create index folder"
mkdir $project_path/index/

cd $project_path/index/

# download reference fasta file
wget http://hgdownload.soe.ucsc.edu/goldenPath/bosTau9/bigZips/bosTau9.fa.gz

# unzip reference genome
gzip -d bosTau9.fa.gz

# download reference genome 

module load bioinfo/bowtie-1.2.1.1

# Launch quantifier.pl with new sets
bowtie-build $genome $genome_bwt
