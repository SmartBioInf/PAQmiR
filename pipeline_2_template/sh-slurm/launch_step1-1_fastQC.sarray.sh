
# load project configuration
source config.txt

# read query configuration file and split each fasta file
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	echo "# Create sarray job file $project_path/sh-slurm/step1-1_run_fasQC.sarray.sh";
	awk -F '\t' -v sources=$sources "BEGIN{
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
			cmd1=\"module load bioinfo/FastQC_v0.11.7; fastqc \" sources \"/\" \$1 ;
			print cmd1;
		}
		i++;
	}" $sample_desc > $project_path/sh-slurm/step1-1_run_fasQC.sarray.sh
fi

echo "# launch jobs whith sarray"
sarray \
-J _fastQC \
-o $sources/%j.out \
-e $sources/%j.err \
-t 01:00:00 \
--mem=4G \
--mail-type=FAIL \
$project_path/sh-slurm/step1-1_run_fasQC.sarray.sh

