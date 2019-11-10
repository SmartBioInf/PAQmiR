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

################################################################################
################### creation know_espece_mirna.csv #############################
echo "creation of file containing predicted miRNA identified as know : know_${2}_mirna.csv"	#

cmd7="cat ${1} | awk -F '\t' '{if(\$1 == \"mature miRBase miRNAs detected by miRDeep2\"){state=\"ok\"}else{if(state==\"ok\" && \$2 > ${6} ){print \"${2}-\" \$1 \"\t\" \$0}else{if(state==\"ok\"){exit}}}}' > know_${2}_mirna.csv"	

echo "extract from results the table containing all know miRNA :"
echo $cmd7	#display the command used in stdout output

(eval "$cmd7")	#execute the command 7
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "know_${2}_mirna.csv OK"	#display "know_${2}_mirna.csv OK" to show the end of the creation of know_espece_mirna.csv in stdout output
echo ""	#display a blank space in stdout output

##################################################################################
################# creation predicted_know_mirna.fa################################
echo "creation predicted_know_mirna.fa"	#indicate the beginning of the creation of predicted_know_mirna.fa in stdout output

cmd8="awk -F '\t' '{if(\$1 !=\"${2}-tag id\"){print \">\" \$1 \"_mt\n\" \$15 }}' know_${2}_mirna.csv > predicted_know_mirna.fa"		#command to recuperate mirna where "_mt" is present in the identifier of file know_${2}_mirna.csv in the file predicted_know_mirna.fa
cmd9="awk -F '\t' '{if(\$1 !=\"${2}-tag id\"){print \">\" \$1 \"_st\n\" \$16 }}' know_${2}_mirna.csv >> predicted_know_mirna.fa"	#command to recuperate mirna where "_st" is present in the identifier of file know_${2}_mirna.csv in the file predicted_know_mirna.fa

echo "extract _mt candidates"
echo $cmd8
(eval "$cmd8")	#execute the command 8
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "extract _st candidates"
echo $cmd9
(eval "$cmd9")	#execute the command 9
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "predicted_know_mirna.fa OK"
echo ""

##################################################################################
################### creation predicted_know_hairpin.fa############################
echo "creation predicted_know_hairpin.fa"

cmd10="awk -F '\t' '{if(\$1 !=\"${2}-tag id\"){print \">\" \$1 \"\n\" \$17 }}' know_${2}_mirna.csv > predicted_know_hairpin.fa" #command to recuperate precursors of file know_${2}_mirna.csv in the file predicted_know_hairpin.fa


echo "extratc know predicted precurssor  "
echo $cmd10

(eval "$cmd10")	#execute the command 10
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "predicted_know_hairpin.fa OK"
echo ""

####################################################################################
################# creation npp_with_know_espece_mirna.gff###########################
echo "creation de npp_with_know_${2}_mirna.gff"	#indicate the beginning of the creation of npp_with_know_espece_mirna.gff in stdout output

cmd11="awk -F '\t' '{if(\$1 !=\"${2}-tag id\"){print \$1 \"\t\" \$18}}' know_${2}_mirna.csv | perl -p -e 's/:|\.\./\t/g' | awk -F '\t' '{print \$2\"\tmiRDeep2\tpredicted_precursor_with_know_${2}_mature\t\" \$3 \"\t\" \$4 \"\t.\t\" \$5 \"\t.\t\" \$1}' > npp_with_know_${2}_mirna.gff"
	#command to recuperate positions of precursors on the genome of file know_${2}_mirna.csv in file npp_with_know_${2}_mirna.gff

echo $cmd11	#display the command used in stdout output

(eval "$cmd11")	#execute the command 11
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "npp_with_know_${2}_mirna.gff OK"	#display "npp_with_know_${2}_mirna.gff OK" to show the end of the creation of npp_with_know_espece_mirna.gff in stdout output
echo ""	#display a blank space in stdout output

#########################################################################
################ creation identified_espece_mira.pre.id##################
echo "create file contating miRNA id of identified miRNA : identified_espece_mirna.pre.id"	#indicate the beginning of the creation of identified_espece_mirna.pre.id in stdout output

cmd14="cat identified_${2}_mirna.id | perl -p -e 's/-5p|-3p//g' | perl -p -e 's/R/r/g' | sort -u > identified_${2}_mirna.pre.id"	#command to transform identifiers mirna in identifiers precursors

echo "extract miRNA id and convert it to precursor id : "
echo $cmd14	#display the command used in stdout output

(eval "$cmd14")	#execute the command 14
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "identified_espece_mirna.pre.id OK"	#display "identified_espece_mirna.pre.id OK" to show the end of the creation of identified_espece_mirna.pre.id in stdout output
echo ""	#display a blank space in stdout output

####################################################################################
############### creation no_identified_espece_mirna_pre.fasta ######################
echo "create fasta file containing no identified precursors : no_identified_espece_mirna_pre.fasta" #indicate the beginning of the creation of no_identified_espece_mirna_pre.fasta in stdout output

cmd15="$directory/extract_seqs_by_ids.pl --fasta_in ${8} --ids_file identified_${2}_mirna.pre.id --file_out no_identified_${2}_mirna.pre.fasta --precursor_shape yes --inverse yes"	
#command to recuperate identifiers without word of identified_${2}_mirna.pre.id in no_identified_${2}_mirna.pre.fasta

echo "remove identified predicted precursors from precursor reference file : "
echo $cmd15	#display the command used in stdout output

(eval "$cmd15")	#execute the command 15
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "no_identified_espece_mirna_pre.fasta OK"
echo ""

#####################################################################
################# creation mature_and_new.fa ########################
echo "creation of new miRNA dataset : mature_and_new_predicted_matures.fa"	#indicate the beginning of the creation of mature_and_new.fa in stdout output

cmd16="cat new_mirna.fa predicted_know_mirna.fa ${7} | perl -p -e 's/(>\S+)\s.+/\1/' > mature_and_new.fa"	#command to concatenate files new_mirna.fa, predicted_know_mirna.fa and mature_sans_espace.fa in mature_and_new.fa

echo $cmd16	#display the command used in stdout output

(eval "$cmd16")	#execute the command 16
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "mature_and_new.fa OK"	#display "mature_and_new.fa OK" to show the end of the creation of mature_and_new.fa in stdout output
echo ""	#display a blank space in stdout output

#################################################################
################creation hairpin_${2}_and_new.fa#################
echo "creation de hairpin_${2}_and_new_predicted_hairpin.fa"	#indicate the beginning of the creation of hairpin_${2}_and_new.fa in stdout output

cmd17="cat new_hairpin.fa predicted_know_hairpin.fa no_identified_${2}_mirna.pre.fasta | perl -p -e 's/(>\S+)\s.+/\1/' > hairpin_espece_and_new.fa"	
#command to concatenate new_hairpin.fa, predicted_know_hairpin.fa and no_identified_${2}_mirna.pre.fasta in hairpin_espece_and_new.fa

echo $cmd17	#display the command used in stdout output

(eval "$cmd17")	#execute the command 17
((errorcode+=$?)) ##check the run of commands
if [ $errorcode -gt 0 ] ; then exit 1 ; fi ##check the run of commands

echo "hairpin_${2}_and_new_predicted_hairpin.fa OK"	
echo ""	#display a blank space in stdout output
