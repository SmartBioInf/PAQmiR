#!/bin/bash

# load project configuration
source config.txt 
 
echo "WARNING : parse result_02_04_2020_t_18_22_36.csv file, please update this file if you re-run mirdeep2";
# extract information of interest

tail -n+27 $mirdeep2_results/result_02_04_2020_t_18_22_36.csv \
| awk -F '\t' -v code=$species_code '{if($2>=0 || $2 =="miRDeep2 score") {print code "-" $1 "\t" $0}else{exit}}' > \
$mirdeep2_results/new_miRNA.csv

# extract mature sequence

awk -F '\t' -v code=$species_code '{if($1 !=(code "-provisional id")){print ">" $1 "_mt\n" $15 }}' $mirdeep2_results/new_miRNA.csv > \
$mirdeep2_results/new_miRNA.fa


# extract star sequence

awk -F '\t' -v code=$species_code '{if($1 !=(code "-provisional id")){print ">" $1 "_st\n" $16 }}' $mirdeep2_results/new_miRNA.csv >> \
$mirdeep2_results/new_miRNA.fa


# extract hairpin sequence 

awk -F '\t' -v code=$species_code '{if($1 !=(code "-provisional id")){print ">" $1 "\n" $17 }}' $mirdeep2_results/new_miRNA.csv > \
$mirdeep2_results/new_hairpin.fa

# merge Known and new

cat $mirbase_folder/mature.fa $mirdeep2_results/new_miRNA.fa > \
$mirdeep2_results/mature_and_new.fa

cat $mirbase_folder/hairpin_${species_code}.fa $mirdeep2_results/new_hairpin.fa > \
$mirdeep2_results/hairpin_bta_and_new.fa

# remove whitespaces

perl -pi -e 's/(>\S+)\s.+/$1/' $mirdeep2_results/mature_and_new.fa

perl -pi -e 's/(>\S+)\s.+/$1/' $mirdeep2_results/hairpin_${species_code}_and_new.fa

