#!/bin/bash
#
#       report_UMI_duplication_rate.sh
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



# This script will report Report UMI duplication count and rate (number/proportion of identical sequences observed with the same UMI).
# The number of time the sequence have been observed should be included in the sequence ID with this shape :
# "^@.*_[0-9]+$"
# exemple : @toto_7

# usage  : report_UMI_duplication_rate.sh <file_in> > <output file>
# $1 file_in => fastQ input file containing individual sequence count (fastq.gz)

zcat $1 \
| grep -E "^@.*_[0-9]+$" \
| cut -d '_' -f 2 \
| sort | uniq -c \
| awk '{print $2 "\t" $1}' \
| sort -n -k1 \
| awk '{
	count[$1]=$2;
	sum=sum+$2;max=$1
}END{
	for(i=1 ; i<=max; i++){
		line1 = line1 "\t" i;
		line2 = line2 "\t" count[i];
		line3 = line3 "\t" (count[i]/sum);
	} 
	print "nb dup" line1;
	print "nb seqs" line2;
	print "perc nb seqs" line3; 
}' 

