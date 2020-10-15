#!/bin/bash
#
#       launch_step2-7_merge_UMI_stats.sh
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

# load project configuration
source config.txt

# read query configuration file and create command line foreach file
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	echo "# Create job file $shell_scripts/step2-7_merge_UMI_stats.sh";
	awk -F '\t' -v umi_merged=$UMI_merged "BEGIN{
			print \"#!/bin/bash\";
			print \"echo -e 'sample\t1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t11\t12\t13\t14\t15\t16\t17\t18\t19\t20\t21\t22\t23\t24\t25\t26\t27\t28\t29\t30\t31\t32\t33\t34\t35\t36\t37\t38\t39\t40\t41\t42\t43\t44\t45\t46\t47\t48\t49\t50' > \" umi_merged \"/UMI_duplication_count.txt\"; 
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
            # print \"\n# create job file \" \$1 ;
		}else{
			# print \"\n# Work on \" \$1 ;	
			out=\$1;
			sample=\$1;
			gsub(\".fastq.gz\",\".UMIMerged.fastq.gz\",out);
			gsub(\".fastq.gz\",\"\",sample);
			cmd1 = \"grep 'perc' \" umi_merged \"/\" out \".hist_UMI_count.txt | perl -p -e 's/perc nb seqs/\" sample \"/' >> \" umi_merged \"/UMI_duplication_count.txt\";
			print cmd1;
		}
		i++;
	}" $sample_desc > $shell_scripts/step2-7_merge_UMI_stats.sh
fi

echo "# launch jobs whith sbatch"
sbatch \
-J _merge_stats_UMI \
-o $UMI_merged/%j.out \
-e $UMI_merged/%j.err \
-t 01:00:00 \
--mem=2G \
--mail-type=FAIL \
step2-7_merge_UMI_stats.sh

