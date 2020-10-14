#!/bin/bash

# load project configuration
source config.txt

# extract statistics from step2a results
grep 'INFO Input Reads' ${UMI_tagged}/*tag.fastq.gz.log | perl -pi -e 's/.*${UMI_tagged}\/(.*tag).*nput Reads: (.*)$/\1\t\2/' > ${UMI_tagged}/Input_Reads.tsv

grep 'Reads output' ${UMI_tagged}/*tag.fastq.gz.log | perl -pi -e 's/.*${UMI_tagged}\/(.*tag).*Reads output: (.*)$/\1\t\2/' > ${UMI_tagged}/Reads_output.tsv

grep 'not match read1' ${UMI_tagged}/*tag.fastq.gz.log | perl -pi -e 's/.*${UMI_tagged}\/(.*tag).*not match read1: (.*)$/\1\t\2/' > ${UMI_tagged}/not_match_read1.tsv

echo "" > ${UMI_tagged}/nb_reads_with_N.tsv
FILES=${UMI_tagged}/*.tag.fastq.gz
for f in $FILES
do
  zcat $f \
  | awk 'BEGIN {OFS = "\n"} {header = $0 ; getline seq ; getline qheader ; getline qseq ; if (index(seq,"N") >0) {print seq}}' \
  | wc -l | awk "{print \"$f\" \"\t\" \$0}" \
  | perl -pi -e 's/.*${UMI_tagged}\/(.*)\.tagged\.fastq\.gz\t(.*)$/\1.fastq.tagged\t\2/' \
  | perl -pi -e 's/.*${UMI_tagged}\/(.*tag)\.fastq\.gz\t(.*)$/\1\t\2/' \
  >> ${UMI_tagged}/nb_reads_with_N.tsv
  # take action on each file. $f store current file name
done

# merge statistiques

awk -F '\t' -v path=${UMI_tagged} 'BEGIN{
   no_match_path= path "/not_match_read1.tsv";
   while(( getline line< no_match_path) > 0 ) {
     split(line,ln,"\t");
     not_match[ln[1]]=ln[2];
   }
   read_output_path= path "/Reads_output.tsv"
   while(( getline line< read_output_path ) > 0 ) {
     split(line,ln,"\t");
     reads_out[ln[1]]=ln[2];
   }
   nb_reads_with_N_path= path "/nb_reads_with_N.tsv"; 
   while(( getline line< nb_reads_with_N_path) > 0 ) {
     split(line,ln,"\t");
     reads_N[ln[1]]=ln[2];
   }
   print "File\tnb reads input\tnb reads not match\t%reads not match\tnb reads match/output\t% reads match/output\tnb reads containing N (outputed)"
}{
	print $1 "\t" $2 "\t" not_match[$1] "\t" (not_match[$1]/$2) "\t" reads_out[$1] "\t" (reads_out[$1]/$2) "\t" reads_N[$1];
}' ${UMI_tagged}/Input_Reads.tsv \
> ${UMI_tagged}/UMI_tag_stats.tsv

rm ${UMI_tagged}/Input_Reads.tsv ${UMI_tagged}/Reads_output.tsv ${UMI_tagged}/not_match_read1.tsv ${UMI_tagged}/nb_reads_with_N.tsv





