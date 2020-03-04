# command(s):
#Go into quantifier
cd ../quantifier

#without filtering 
echo 'WARNING: the quantification result file used is ../quantifier/miRNAs_expressed_all_samples_1519902888.csv'
cat ../quantifier/miRNAs_expressed_all_samples_1519902888.csv | ../bin/parse_miRDeep2_output.pl --mature_arf ../quantifier/expression_analyses/expression_analyses_1519902888/mature_and_new.fa_mapped.arf --structure_file ../quantifier/expression_analyses/expression_analyses_1519902888/miRBase.mrd --expression_file - > ../quantifier/miRNAs_expressed.pre_uniq.csv 2> ../quantifier/miRNAs_expressed.pre_uniq.log.txt

#Filtering one condition >1 for at least one library
cat ../quantifier/miRNAs_expressed_all_samples_1519902888.csv | awk -F '\t' '$2>=1' | perl -pi -e 's/(\d+)\.(\d{2})/\1\,\2/g' | ../bin/parse_miRDeep2_output.pl --mature_arf ../quantifier/expression_analyses/expression_analyses_1519902888/mature_and_new.fa_mapped.arf --structure_file ../quantifier/expression_analyses/expression_analyses_1519902888/miRBase.mrd --expression_file - > ../quantifier/miRNAs_expressed.pre_uniq.filter1.csv 2> ../quantifier/miRNAs_expressed.pre_uniq.filter1.log.txt

#Filtering condition, at least 10 reads mapping on corresponding hairpin
cat ../quantifier/miRNAs_expressed_all_samples_1519902888.csv | awk -F '\t' '$2>=10' | perl -pi -e 's/(\d+)\.(\d{2})/\1\,\2/g' | ../bin/parse_miRDeep2_output.pl --mature_arf ../quantifier/expression_analyses/expression_analyses_1519902888/mature_and_new.fa_mapped.arf --structure_file ../quantifier/expression_analyses/expression_analyses_1519902888/miRBase.mrd --expression_file - > ../quantifier/miRNAs_expressed.pre_uniq.filter10.csv 2> ../quantifier/miRNAs_expressed.pre_uniq.filter10.log.txt

#Filtering condition, at least 100 reads mapping on corresponding hairpin
cat ../quantifier/miRNAs_expressed_all_samples_1519902888.csv | awk -F '\t' '$2>=100' | perl -pi -e 's/(\d+)\.(\d{2})/\1\,\2/g' | ../bin/parse_miRDeep2_output.pl --mature_arf ../quantifier/expression_analyses/expression_analyses_1519902888/mature_and_new.fa_mapped.arf --structure_file ../quantifier/expression_analyses/expression_analyses_1519902888/miRBase.mrd --expression_file - > ../quantifier/miRNAs_expressed.pre_uniq.filter100.csv 2> ../quantifier/miRNAs_expressed.pre_uniq.filter100.log.txt
