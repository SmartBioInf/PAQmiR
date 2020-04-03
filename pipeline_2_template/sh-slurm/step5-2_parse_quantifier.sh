#!/bin/bash

# load config variables
source ./config.txt

# quantifier analysis ID. Look into the quantifier folder expression_analyses/expression_analyses_XXXX where XXXX is the ID
quantifier_ID="1585898428" 
echo "WARNING : parse miRNAs_expressed_all_samples_${quantifier_ID}.csv file, please update this file if you re-run quantifier";

# command(s):
# Go into quantifier
cd $quantifier_results

#Filtering condition, at least 100 reads mapping on corresponding hairpin
cat $quantifier_results/miRNAs_expressed_all_samples_${quantifier_ID}.csv \
| awk -F '\t' '$2>=100' \
| perl -pi -e 's/(\d+)\.(\d{2})/\1\,\2/g' \
| $PAQmiR_bin/parse_miRDeep2_output.pl \
--mature_arf $quantifier_results/expression_analyses/expression_analyses_${quantifier_ID}/mature_and_new.fa_mapped.arf \
--structure_file $quantifier_results/expression_analyses/expression_analyses_${quantifier_ID}/miRBase.mrd \
--expression_file - \
> $quantifier_results/miRNAs_expressed.pre_uniq.filter100.csv \
2> $quantifier_results/miRNAs_expressed.pre_uniq.filter100.log.txt
