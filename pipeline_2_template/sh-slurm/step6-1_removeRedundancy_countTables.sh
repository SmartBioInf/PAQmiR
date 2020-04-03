#!/bin/bash

# load project configuration
source config.txt 

mkdir $final_results

nb_columns_1=$(($nb_samples+6))
nb_columns_2=$((($nb_samples*2)+6))

head -n 1 $quantifier_results/miRNAs_expressed.pre_uniq.filter100.csv \
|  awk -F '\t' 'BEGIN {OFS="\t"}{print "mature-seq\t" $0}' \
| cut -f 1-$nb_columns_1 > $final_results/miRNAs_expressed.pre_uniq.matureSEQ_unique.filter100.csv

grep -v 'read_count' $quantifier_results/miRNAs_expressed.pre_uniq.filter100.csv \
| perl -pi -e 's/,00\t/\t/g' | perl -pi -e 's/,/\./g' \
| awk -F '\t' -v last_col="$nb_columns_2" 'BEGIN {OFS="\t"}{
	if($2 > count[$(last_col)]){
		infos[$(last_col)]=$(last_col)"\t"$0;
		count[$(last_col)]=$2
	}} 
	END {for (var in infos)
		{print infos[var]}
	}' > $final_results/miRNAs_expressed.pre_uniq.filter100.raw.csv

cut -f 1-$nb_columns_1 $final_results/miRNAs_expressed.pre_uniq.filter100.raw.csv | sort -k 3 -nr \
>> $final_results/miRNAs_expressed.pre_uniq.matureSEQ_unique.filter100.csv

rm $final_results/miRNAs_expressed.pre_uniq.filter100.raw.csv
