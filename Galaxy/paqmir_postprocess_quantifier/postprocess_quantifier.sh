#!/bin/bash

####filtering results of quantifier####
errorcode=0
directory=`dirname $0`

if [ $4 = "no" ]	# check if option filter is false
then
	cmd0="$directory/parse_miRDeep2_output.pl --mature_arf ${3} --structure_file ${2} --expression_file ${1} > miRNAs_expressed_all_samples.pre_uniq.csv"	#command used if there is not filter, assigns mature miRNAs to a set of precursors, and report the quantification of the best two mature (3p & 5p predicted from their position on the precursor) observed for each precursor.
fi

if [ $4 = "yes" ]	# check if option filter is true
then
	cmd1="perl -p -e 's/(\d+)\.(\d{2})/\1\,\2/g' ${1} > temp_output"	# change number format
	echo "change decimal separator (if needed):"
	echo $cmd1	#display the command used in stdout output
	(eval "$cmd1") #execute the command 1
	((errorcode+=$?)) ##check the run of commands
	if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands
	
	condition="awk -F '\t' '\$4>=${6}"	#create filter
	i=2
	#echo "i : ${i}"
	while [ $i -le ${5} ]
	do
		n=$(( $i+4 ))	#use to know the column in file ${1}
		#echo "n : ${n}"
		condition=${condition}" || \$${n}>=${6}"	#add informations for the condition
		i=$(( $i+1 ))	#incrementing of number to arrive at number of condition
		#echo "nouveau i : ${i}"
	done
	echo "condition : ${condition}"	#display the condition used in stdout output
	cmd2=${condition}"' temp_output > temp_output2"	#finish the command
	echo "apply condition to results:"
	echo $cmd2
	(eval "$cmd2") 
	((errorcode+=$?)) ##check the run of commands
	if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

	cmd0="$directory/parse_miRDeep2_output.pl --mature_arf ${3} --structure_file ${2} --expression_file temp_output2 > miRNAs_expressed_all_samples.pre_uniq.csv"	#command used if there is not filter, assigns mature miRNAs to a set of precursors, and report the quantification of the best two mature (3p & 5p predicted from their position on the precursor) observed for each precursor.
	
fi

echo "Use perl script to parse results and proceed annotation"
echo $cmd0	

#(eval "$cmd0") 2>>tableau_recapitulatif #execute the command 0 in a summary table ##redirect to log
(eval "$cmd0") 2>>annotation_statistics.txt #execute the command 0
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

#add header line to results files#
cmd3="head -n 1 miRNAs_expressed_all_samples.pre_uniq.csv > head_miRNAs_expressed_all_samples.pre_uniq.csv"	#recover the first line in the file miRNAs_expressed_all_samples.pre_uniq.csv in the file head_miRNAs_expressed_all_samples.pre_uniq.csv
cmd4="perl -p -e 's/\#//' head_miRNAs_expressed_all_samples.pre_uniq.csv > miRNAs_expressed_all_samples.pre_uniq.matureSEQ_uniq.csv" #modify the first line and create the file miRNAs_expressed_all_samples.pre_uniq.matureSEQ_uniq.csv
cmd5="perl -p -e 's/\#//' head_miRNAs_expressed_all_samples.pre_uniq.csv > miRNAs_expressed_all_samples.pre_uniq.matureID_uniq.csv"	#modify the first line and create the file miRNAs_expressed_all_samples.pre_uniq.matureID_uniq.csv

echo $cmd3	#display the command used in stdout output
echo $cmd4	#display the command used in stdout output
echo $cmd5	#display the command used in stdout output

(eval "$cmd3") 	#execute the command 3
((errorcode+=$?))
(eval "$cmd4") 	#execute the command 4
((errorcode+=$?))
(eval "$cmd5") 	#execute the command 5
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands


#mature sequence uniq#
n=5+${5}*2+1	#use to know the number of the last column

cmd6="grep -v 'read_count' miRNAs_expressed_all_samples.pre_uniq.csv | awk -F '\t' '{if(\$2 > count[\$${n}]){infos[\$${n}] = \$0;count[\$${n}]=\$2}} END {for  (var in infos){print infos[var]}}' >> miRNAs_expressed_all_samples.pre_uniq.matureSEQ_uniq.csv"	#recuperate mirna and add sequences of matures mirna

echo $cmd6	#display the command used in stdout output

(eval "$cmd6") 
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

mature id uniq#
cmd7="grep -v 'read_count' miRNAs_expressed_all_samples.pre_uniq.csv | perl -p -e 's/(\d+)\,(\d{2})/\1\.\2/g' | awk -F '\t' '{if(\$2 > count[\$1]){infos[\$1] = \$0;count[\$1]=\$2}} END {for (var in infos){print infos[var]}}' >> miRNAs_expressed_all_samples.pre_uniq.matureID_uniq.csv"

echo $cmd7	#display the command used in stdout output

(eval "$cmd7") 	#execute the command 7
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

