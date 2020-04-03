#!/bin/bash

# load project configuration
source config.txt

rm $project_path/sh-slurm/step2-2_merge_collapsed_files.sh;

# read query configuration file and split each fasta file
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	echo "# Create job file $project_path/sh-slurm/step2-2_merge_collapsed_files.sh";
	awk -F '\t' -v collapsed=$collapsed_reads_location -v min=$min_length -v fout=$processed_reads_path "BEGIN{
			i=1;
			print \"#!/bin/bash\";
			print \"rm -rf \" fout;
		}{
		# retrieve header information in first line
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
			cmd1=\"cat \" collapsed \"/\" \$1 \".l\" min \".collapsed.fasta >> \" fout ;
			print cmd1;
		}
		i++;
	}" $sample_desc > $project_path/sh-slurm/step2-2_merge_collapsed_files.sh
fi

sbatch \
-J multiqc \
-o $collapsed_reads_location/merge_all.out \
-e $collapsed_reads_location/merge_all.err \
--mem=2G \
--mail-type=FAIL \
step2-2_merge_collapsed_files.sh
