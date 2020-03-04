# move to index directory
cd ../index/

# create bowtie index
bowtie-build -f bosTau8.fa bosTau8

# create samtools index
samtools faidx bosTau8.fa