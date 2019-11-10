#!/bin/bash

#################################################################
################### creation new_mirna.csv ######################
errorcode=0

echo "extract new mature sequences from miRDeep2 results files"

echo "create filter condition"

condition='($2>='${3}''; #initialize the beginning of the condition to keep only mirna with a score higher than the one chosen

if [ ${4} = "yes" ] #check if option "etrieve only miRNA with significant randfold" is activated
then
	condition=${condition}' && ${9} =="yes"'	#if option randfold is true, implements the condition by asking it to verify if "yes" in the column significatively randfold
fi
if [ ${5} = "yes" ] # check if option "etrieve only miRNAs without example of same seed region in miRBase" is activated
then
	condition=${condition}' && $11 =="-"'  # icheck the presence of a name or "-" in column
fi

condition=${condition}') || $2=="miRDeep2 score"' #finish the condition with operator "OR" to keep the header

echo "condition applied : ${condition}"	#view the contents of the condition in stdout output

cmd="tail -n +27 $1 > new_mirna.raw.csv"	# extract from results the table containing all predicted miRNAs
cmd2="awk -F '\t' '{if(${condition}) {print \"${2}-\" \$1 \"\t\" \$0}else if(\$9 ==\"\"){exit}else{next}}' new_mirna.raw.csv > new_mirna.csv;" 	#apply filter options to keep interesting miRNAs

echo "extract from results the table containing all predicted miRNA :"
echo $cmd
(eval "$cmd")	#execute the command
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "apply filter options to keep interesting miRNAs"
echo $cmd2
(eval "$cmd2")	#execute the command 2
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "new_mirna.csv OK"
echo ""

###################################################################
###################### creation new_mirna.fa ######################
echo "creation of new fasta file contaning the new miRNAs new_mirna.fa"

echo "selected specie : ${2}"

cmd3="awk -F '\t' '{if(\$1 !=\"${2}-provisional id\"){print \">\" \$1 \"_mt\n\" \$15 }}' new_mirna.csv > new_mirna.fa"	#command to extract mirna where "_mt" is present in the identifier of file new_mirna.csv in the file new_mirna.fa
cmd4="awk -F '\t' '{if(\$1 !=\"${2}-provisional id\"){print \">\" \$1 \"_st\n\" \$16 }}' new_mirna.csv >> new_mirna.fa"	#command to extract mirna where "_st" is present in the identifier of file new_mirna.csv in the file new_mirna.fa

echo "extract _mt candidates"
echo $cmd3	
(eval "$cmd3")	#execute the command 3
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "extract _st candidates"
echo $cmd4
(eval "$cmd4")	#execute the command 4
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "number of new miRNAs"
grep -c '>' new_mirna.fa

echo "new_mirna.fa created with succes OK"
echo ""

#######################################################################
##################### creation new_hairpin.fa #########################
echo "creation of new fasta file contaning the new hairpins new_hairpin.fa"

echo "selected specie : ${2}"

cmd5="awk -F '\t' '{if(\$1 !=\"${2}-provisional id\"){print \">\" \$1 \"\n\" \$17 }}' new_mirna.csv > new_hairpin.fa"	#command to recuperate precursors'mirna of file new_mirna.csv in file new_hairpin.fa

echo "extract hairpins: "
echo $cmd5		#display the command used in stdout output

(eval "$cmd5")	#execute the command 5
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "number of new hairpins"
grep -c '>' new_hairpin.fa

echo "new_hairpin.fa OK"
echo ""

#####################################################################
################### creation new_predicted_precursors.gff ###########
echo "creation of new predicted precursors gff file new_predicted_precursors.gff"	#indicate the beginning of the creation of new_predicted_precursors.gff in stdout output

echo "selected specie : ${2}"

cmd6="awk -F '\t' '{if(\$1 !=\"${2}-provisional id\"){print \$1 \"\t\" \$18}}' new_mirna.csv | perl -p -e 's/:|\.\./\t/g' | awk -F '\t' '{print \$2 \"\tmiRDeep2\tnew_predicted_precursor\t\" \$3 \"\t\" \$4 \"\t.\t\" \$5 \"\t.\t\" \$1}' > news_predicted_precursors.gff"	#command to recuperate positions of precursors on the genome of file new_mirna.csv in file news_predicted_precursors.gff

echo "creation of gff file "
echo $cmd6	#display the command used in stdout output

(eval "$cmd6")	#execute the command 6
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "new_predicted_precursors.gff OK"
echo ""

#####################################################################
################# creation mature_and_new.fa ########################
echo "creation of new miRNA dataset : mature_and_new_predicted_matures.fa"	#indicate the beginning of the creation of mature_and_new.fa in stdout output

cmd12="cat new_mirna.fa ${7} | perl -p -e 's/(>\S+)\s.+/\1/' > mature_and_new.fa"	#command to concatenate files new_mirna.fa, predicted_know_mirna.fa and mature_sans_espace.fa in mature_and_new.fa

(eval "$cmd12")	#execute the command 12
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "mature_and_new_predicted_matures.fa OK"
echo ""

###################################################################
################ creation hairpin_${2}_and_new.fa #################
echo "creation de hairpin_${2}_and_new_predicted_hairpin.fa"	#indicate the beginning of the creation of hairpin_${2}_and_new.fa in stdout output

cmd13="cat new_hairpin.fa ${8} | perl -p -e 's/(>\S+)\s.+/\1/' > hairpin_espece_and_new.fa"	#command to concatenate new_hairpin.fa, predicted_know_hairpin.fa and no_identified_${2}_mirna.pre.fasta in hairpin_espece_and_new.fa

echo $cmd13

(eval "$cmd13")	#execute the command 13
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "hairpin_${2}_and_new_predicted_hairpin.fa OK"	
echo ""
