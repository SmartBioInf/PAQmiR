#!/bin/bash

# load project configuration
source config.txt

rm $project_path/sh-slurm/step3-2_merge_Arfs_files.sh;

# read query configuration file and split each fasta file
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	echo "# Create job file $project_path/sh-slurm/step3-2_merge_Arfs_files.sh";
	awk -F '\t' -v bowtie_r=$bowtie_results -v project_path=$project_path -v min=$min_length -v merged_arf=$merged_arf_path "BEGIN{
			i=1;
			print \"#!/bin/bash\";
			print \"rm -rf \" project_path \"/sh-slurm/step3-2_merge_Arfs_files.sh\";
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
			cmd1=\"cat \" bowtie_r \"/\" \$1 \".l\" min \".collapsed.arf >> \" merged_arf ;
			print cmd1;
		}
		i++;
	}" $sample_desc > $project_path/sh-slurm/step3-2_merge_Arfs_files.sh
fi

sbatch \
-J merge_Arfs \
-o $bowtie_results/merge_Arfs.out \
-e $bowtie_results/merge_Arfs.err \
--mem=2G \
--mail-type=FAIL \
step3-2_merge_Arfs_files.sh
