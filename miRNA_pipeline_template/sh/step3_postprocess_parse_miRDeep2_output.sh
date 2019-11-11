 
echo "WARNING : parse result_01_03_2018_t_11_30_34.csv file, please update this file if you re-run mirdeep2";
# extract information of interest

tail -n+27 ../mirdeep2/result_01_03_2018_t_11_30_34.csv \
| awk -F '\t' '{if($2>=0 || $2 =="miRDeep2 score") {print "bta-" $1 "\t" $0}else{exit}}' > \
../mirdeep2/new_miRNA.csv

# extract mature sequence

awk -F '\t' '{if($1 !="bta-provisional id"){print ">" $1 "_mt\n" $15 }}' ../mirdeep2/new_miRNA.csv > \
../mirdeep2/new_miRNA.fa


# extract star sequence

awk -F '\t' '{if($1 !="bta-provisional id"){print ">" $1 "_st\n" $16 }}' ../mirdeep2/new_miRNA.csv >> \
../mirdeep2/new_miRNA.fa


# extract hairpin sequence 

awk -F '\t' '{if($1 !="bta-provisional id"){print ">" $1 "\n" $17 }}' ../mirdeep2/new_miRNA.csv > \
../mirdeep2/new_hairpin.fa

# merge Known and new

cat ../mirbase21/mature.fa ../mirdeep2/new_miRNA.fa > \
../mirdeep2/mature_and_new.fa

cat ../mirbase21/hairpin_bta.fa ../mirdeep2/new_hairpin.fa > \
../mirdeep2/hairpin_bta_and_new.fa

# remove whitespaces

perl -pi -e 's/(>\S+)\s.+/$1/'  ../mirdeep2/mature_and_new.fa

perl -pi -e 's/(>\S+)\s.+/$1/'  ../mirdeep2/hairpin_bta_and_new.fa

