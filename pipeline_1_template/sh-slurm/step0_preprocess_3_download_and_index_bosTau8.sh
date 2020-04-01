#!/bin/bash

# load project configuration
source config.txt

################################
# create index folder (if needed)
echo "\n#### Create index folder"
#mkdir $project_path/index/

cd $project_path/index/

# make genome download (if needed)
echo "Download reference genome"
#wget http://hgdownload.soe.ucsc.edu/goldenPath/bosTau8/bigZips/bosTau8.fa.gz

# unzip reference genome
echo "Unzip reference genome"
# gzip -d bosTau8.fa.gz

module load bioinfo/bowtie-1.2.1.1;
module load bioinfo/samtools-1.10;

# index reference genome (if needed)
echo "Index reference genome for Bowtie"

# create bowtie index
bowtie-build -f bosTau8.fa bosTau8

# create samtools index
samtools faidx bosTau8.fa