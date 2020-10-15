#!/bin/bash
#
#       launch_step2-3_merge_dups_UMI.sarray.sh
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

# create results folder
mkdir $UMI_merged;

# read query configuration file and create command line foreach file
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	echo "# Create sarray job file $shell_scripts/step2-1_identifie_UMI_tag.sarray.sh";
	awk -F '\t' -v umi_path=$UMI_tagged -v umi_merged=$UMI_merged -v mod_UMItools=$UMItools -v bin=$PAQmiR_bin "BEGIN{
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
			inF=\$1;
			out=\$1;
			gsub(\".fastq.gz\",\".tag.fastq.gz\",inF);
			gsub(\".fastq.gz\",\".UMIMerged.fastq.gz\",out);
			cmd1=\"module load \" mod_UMItools \"; \";
			cmd1=bin \"/collapse_UMI_duplicates.sh \" umi_path \"/\" inF \" \" umi_merged \"/\" out ;
			print cmd1;
		}
		i++;
	}" $sample_desc > $shell_scripts/step2-3_merge_dups_UMI.sarray.sh
fi

echo "# launch jobs whith sarray"
sarray \
-J _merge_UMI_tag \
-o $UMI_merged/%j.out \
-e $UMI_merged/%j.err \
-t 12:00:00 \
--mem=150G \
--mail-type=FAIL \
$shell_scripts/step2-3_merge_dups_UMI.sarray.sh
