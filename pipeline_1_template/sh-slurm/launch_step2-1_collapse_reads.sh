
# load project configuration
source config.txt

mkdir $collapsed;

# read query configuration file and split each fasta file
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	echo "# Create sarray job file $project_path/sh-slurm/step1-1_run_fasQC.sarray.sh";
	awk -F '\t' -v collapsed=$collapsed -v sources=$sources -v min=$min_length "BEGIN{
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
			cmd1=\"module load bioinfo/fastx_toolkit-0.0.14; \";
			cmd1=cmd1 \"zcat \" sources \"/\" \$1 \" | \";
			cmd1=cmd1 \"awk 'BEGIN{i=1}{if(i%4==1){id=\$0;}else if(i%4==2){seq=\$0;}else if(i%4==3){pl=\$0;}else if(i%4==0){qual=\$0;if(length(seq)>=\" min \"){print id; print seq; print pl; print qual ;}}i++;}' | \"
			cmd1=cmd1 \"fastx_collapser | \";
			cmd1=cmd1 \"perl -p -e 's/^>([0-9]+)-([0-9]+)$/>\" \$2 \"_\${1}_x\$2/' > \";
			cmd1=cmd1 collapsed \"/\" \$1 \".l\" min \".collapsed.fasta; \";
			print cmd1;
		}
		i++;
	}" $sample_desc > $project_path/sh-slurm/step2-1_run_collapse_reads.sarray.sh
fi

echo "# launch jobs whith sarray"
sarray \
-J _collapse \
-o $collapsed/%j.out \
-e $collapsed/%j.err \
-t 01:00:00 \
--mem=4G \
--mail-type=FAIL \
$project_path/sh-slurm/step2-1_run_collapse_reads.sarray.sh

