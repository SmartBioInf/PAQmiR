#!/bin/bash
#
#       collapse_UMI_duplicates.sh
#
#       Copyright 2020 Sylvain Marthey <sylvain.marthey@inrae.fr>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 3 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, see <http://www.gnu.org/licenses/>.



# this awk script will :
# 1/ remove sequences contaning N
# 2/ collapse UMI duplicates (same sequence with same UMI Tag). The mean score of duplicates is calculated at each position and associated to the sequence in the result fastQ file.  
# 3/ discard sequences containing at least one nucleotide with a phred(33) score inferior to $3 (53)
# usage  : collapse_UMI_duplicates.sh <file_in> <file_out> <phred_thresold> 
# $1 file_in => fastQ input file containing tag (fastq.gz)
# $2 file_out => fastQ collapsed output (fastq.gz)
# $3 phred_thresold => Phred(33) thresold to use to remove reads after collapsing default value: 25 (58)

# TAGGED FILE IN (from command umi_tools extract)
TAGGED_FILE_IN=$1

# Collapsed file out
COLLAPSED_FILE_OUT=$2

# maximum number of observed sequences used to calculate sequence quality
# reduce this parameter to reduce memory consummation
NB_SEQS_USED_FOR_QUAL=5

# Phred thresold (phred33 based) [25]
PHRED_THRESOLD=$3
if [ !$PHRED_THRESOLD ]
then
   PHRED_THRESOLD=58;
fi

zcat $1 \
| perl -p -e 's/(@[^\n]+)\n/\1end/' \
| perl -p -e 's/(@[^_]+)_([^\s]+)(\s.*)end(.*)\n/\1_\2\3\n\4\2\n/' \
| awk -v maxSqual=$NB_SEQS_USED_FOR_QUAL -v phredTH=$PHRED_THRESOLD 'BEGIN{OFS = "\n"; 
         # initialisation of Nu <-> correspondance 
         for(n=0;n<256;n++){
           ord[sprintf("%c",n)]=n;
           chr[n]=sprintf("%c",n)
         }
} {
  # retrive read information
  header = $0 ; getline seq ; getline qheader ; getline qseq ; 
  # remove reads with N
  if (index(seq,"N")<1){
     seqs[seq]++;
	 nb_seqs++;
	 #if it the fisrst time we saw this sequence, we keep the quality as a string 
	 if(seqs[seq]==1){
		quals[seq][1]=qseq;
	 # if it s the second time we saw this sequence, we will convert the quality as an array of values
	 }else if(seqs[seq] ==2){
		split(quals[seq][1], seq_quals1 , "");
		split(qseq, seq_quals, "");
		for (i=1; i <= (length(seq)-11); i++) {
				quals[seq][i] = ord[seq_quals1[i]] + ord[seq_quals[i]];
		}
	 }else{
		 # sum sequence qualities
		 # if we want to limit the number of sequences used to make quality calculation
		 if(seqs[seq]<maxSqual){
			split(qseq, seq_quals, "");
			for (i=1; i <= (length(seq)-11); i++) {
				quals[seq][i]=quals[seq][i]+ord[seq_quals[i]];
			}
		 # if we reach the maximum number of sequences, we can calculate the quality score istead of strore the sum of sequence quality scores
		 }else if(seqs[seq]==maxSqual){
			split(qseq, seq_quals, "");
			for (i=1; i <= (length(seq)-11); i++) {
				quals[seq][i] = quals[seq][i]+ord[seq_quals[i]];
				quals[seq][i] = chr[sprintf("%.0f",(quals[seq][i]/seqs[seq]))];
			}
		 }
	 }
  }
}END{
	# print all seqs
	for (seq in seqs){
		seq_f=substr(seq,1,(length(seq)-12)); 
		OK=1;
		qual="";
		# check for quality thresold
		# if the seq was saw only one time
		if(seqs[seq]==1){
			qual = quals[seq][1];
		# if we need to calculate the score mean
		} else if(seqs[seq] < maxSqual){
			for (i=1; i <= length(seq_f); i++) {
				if((quals[seq][i]/seqs[seq])<phredTH){
						  OK=0;
						  break;
				}
				qual = qual chr[sprintf("%.0f",(quals[seq][i]/seqs[seq]))];
			}
		# if the score mean is already calculated
		}else{
			for (i=1; i <= length(seq_f); i++) {
				if(quals[seq][i]<phredTH){
						  OK=0;
						  break;
				}
				qual = qual quals[seq][i];
			}
		}
		if(OK== 1){
		 print "@" seq_f "_" seqs[seq] "\n" seq_f "\n+\n" qual;
		}
	}
}' | gzip > $2
