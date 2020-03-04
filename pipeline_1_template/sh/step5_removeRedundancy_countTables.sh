head -n 1 ../quantifier/miRNAs_expressed.pre_uniq.filter100.csv |  awk -F '\t' 'BEGIN {OFS="\t"}{print "mature-seq\t" $0}' > ../quantification_annotation/miRNAs_expressed.pre_uniq.filter100.raw.csv

grep -v 'read_count' ../quantifier/miRNAs_expressed.pre_uniq.filter100.csv | awk -F '\t' 'BEGIN {OFS="\t"}{if($2 > count[$12]){infos[$12] = $12"\t"$0;count[$12]=$2}} END {for (var in infos){print infos[var]}}' >> ../quantification_annotation/miRNAs_expressed.pre_uniq.filter100.raw.csv

cut -f 1-9 ../quantification_annotation/miRNAs_expressed.pre_uniq.filter100.raw.csv > ../quantification_annotation/miRNAs_expressed.pre_uniq.matureSEQ_unique.filter100.csv

sed -i -e 's/,/./g' ../quantification_annotation/miRNAs_expressed.pre_uniq.matureSEQ_unique.filter100.csv

rm ../quantification_annotation/miRNAs_expressed.pre_uniq.filter100.raw.csv
