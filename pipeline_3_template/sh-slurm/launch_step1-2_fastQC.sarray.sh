#!/bin/bash
#
#       launch_step1-2_fastQC.sarray.sh
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
	echo "# Create sarray job file $shell_scripts/step1-2_run_fasQC.sarray.sh";
	awk -F '\t' -v sources=$sources -v mod_fastQC=$FastQC "BEGIN{
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
			cmd1=\"module load \" mod_fastQC \"; fastqc \" sources \"/\" \$1 ;
			print cmd1;
		}
		i++;
	}" $sample_desc > $shell_scripts/step1-2_run_fasQC.sarray.sh
fi

echo "# launch jobs whith sarray"
sarray \
-J _fastQC \
-o $sources/%j.out \
-e $sources/%j.err \
-t 01:00:00 \
--mem=4G \
--mail-type=FAIL \
$shell_scripts/step1-2_run_fasQC.sarray.sh

