
# load project configuration
source config.txt

mkdir $bowtie_results;

# read query configuration file and split each fasta file
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	echo "# Create sarray job file $project_path/sh-slurm/step3-1_run_bowtie.sarray.sh";
	awk -F '\t' -v genome=$genome_bwt -v collapsed=$collapsed_reads_location -v bowtie_r=$bowtie_results -v min=$min_length "BEGIN{
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
			cmd1=\"module load bioinfo/bowtie-1.2.1.1; module load bioinfo/ViennaRNA-1.8.5; module load bioinfo/mirdeep2_0_0_8; \"
			cmd1=cmd1 \"bowtie -S -f -p 1 -n 0 -e 80 -l 18 -a -m 5 --best --strata \" genome \" \" collapsed \"/\" \$1 \".l\" min \".collapsed.fasta \" bowtie_r \"/\" \$1 \".l\" min \".collapsed.sam ; \";
			cmd1=cmd1 \"cd \" bowtie_r \"; bwa_sam_converter.pl -i \" \$1 \".l\" min \".collapsed.sam -a \" \$1 \".l\" min \".collapsed.arf;\";
			print cmd1;
		}
		i++;
	}" $sample_desc > $project_path/sh-slurm/step3-1_run_bowtie.sarray.sh
fi

echo "# launch jobs whith sarray"
sarray \
-J _bowtie \
-o $bowtie_results/%j.out \
-e $bowtie_results/%j.err \
-t 04:00:00 \
--mem=6G \
--mail-type=FAIL \
$project_path/sh-slurm/step3-1_run_bowtie.sarray.sh

