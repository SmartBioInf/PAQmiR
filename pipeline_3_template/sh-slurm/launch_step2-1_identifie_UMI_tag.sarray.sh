
# load project configuration
source config.txt

# create results folder
mkdir $UMI_tagged;

# read query configuration file and create command line foreach file
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	echo "# Create sarray job file $shell_scripts/step2-1_identifie_UMI_tag.sarray.sh";
	awk -F '\t' -v sources=$sources -v umi_path=$UMI_tagged -v mod_UMItools=$UMItools -v UMI_Adaptor=$UMI_adaptor "BEGIN{
			i=1;
		}{
		# retrive header information in first line
		if(i==1){
			# print \"# Read samples description file : $sample_desc\" ;
			# test presence of mandatory columns
			if(\$1!=\"source_fastq.gz\"){
				print \"ERROR: samples description file : $sample_desc doesn't contain the mandatory 'Source_fastq.gz' column\";
				exit 1;
			}else if(\$2!=\"miRDeep2_id\"){
                print \"ERROR: samples description file : $sample_desc doesn't contain the mandatory 'miRDeep2_id' column\";
				exit 1;
            }
            # print \"\n# create sarray file containing all jobs \" \$1 ;
		}else{
			# print \"\n# Work on \" \$1 ;		
			out=\$1;
			gsub(\".fastq.gz\",\".tag.fastq.gz\",out);
			cmd1=\"module load \" mod_UMItools \"; \";
			cmd1=cmd1 \"umi_tools extract -I \" sources \"/\" \$1 \" -S \" umi_path \"/\" out \" --extract-method=regex --bc-pattern='.*(?P<discard_1>\" UMI_Adaptor \"{s<=1})(?P<umi_1>.{12})(?P<discard_2>.*)' > \" umi_path \"/\" out \".log\";
			print cmd1;
		}
		i++;
	}" $sample_desc > $shell_scripts/step2-1_identifie_UMI_tag.sarray.sh
fi

echo "# launch jobs whith sarray"
sarray \
-J identifie_UMI_tag \
-o $UMI_tagged/%j.out \
-e $UMI_tagged/%j.err \
-t 04:00:00 \
--mem=2G \
--mail-type=FAIL \
$shell_scripts/step2-1_identifie_UMI_tag.sarray.sh