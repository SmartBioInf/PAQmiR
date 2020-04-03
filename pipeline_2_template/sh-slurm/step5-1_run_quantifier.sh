#!/bin/bash

# load config variables
source ./config.txt

# command(s):
# Go into quantifier
cd $quantifier_results

module load bioinfo/ViennaRNA-1.8.5
module load bioinfo/mirdeep2_0_0_8
module load bioinfo/bowtie-1.2.1.1

# Launch quantifier.pl with new sets
quantifier.pl \
-r $processed_reads_path \
-m $mirdeep2_results/mature_and_new.fa \
-p $mirdeep2_results/hairpin_${species_code}_and_new.fa \
-k -P
