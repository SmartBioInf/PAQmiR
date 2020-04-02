#!/bin/bash

# load project configuration
source config.txt

# Go into quantifier
cd $mirdeep2_results

module load bioinfo/ViennaRNA-1.8.5
module load bioinfo/mirdeep2_0_0_8
module load bioinfo/bowtie-1.2.1.1
module load bioinfo/randfold-2.0.1

# Launch miRDeep2.pl with new sets
miRDeep2.pl $processed_reads_path \
$genome \
$merged_arf_path \
$miRNAs_ref \
$miRNAs_other \
$precursors_ref \
-t human -P \
2> report_mirdeep2.pl.log

# -a  minimum read stack height that triggers analysis. Using this option disables
# => avoid long processing (several days)
# -t species species being analyzed 
# -P use this switch if mature_ref_miRNAs contain miRBase v18 identifiers (5p and 3p) instead of previous ids from v17

