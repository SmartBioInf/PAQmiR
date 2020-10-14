#!/bin/bash
#
#       launch_step1-1_make_links_to_raw_data.sh
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

mkdir $sources;

# read query configuration file create link
if [ ! -f $sample_desc ]; then
    echo "ERROR: Samples description file : $sample_desc not found"
    exit 1 
else 
	awk -F '\t' -v sources=$sources "BEGIN{
			i=1;
			print \"#!/bin/bash\";
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
            }else if(\$3!=\"original_location\"){
                print \"ERROR: samples description file : $sample_desc doesn't contain the mandatory 'original_location' column\";
				exit 1;
            }
            # print \"\n# create command to link data to original files \" \$1 ;
		}else{
			cmd=\"ln -s \" \$3 \"/\" \$1 \" $sources/\"; 
			print cmd;
		}
		i++;
	}" $sample_desc > $shell_scripts/step1-1_make_links_to_raw_data.sh
fi

sbatch \
-J link_sources \
-o $sources/step1-1_make_links_to_raw_data_and_unzip.sh.out \
-e $sources/step1-1_make_links_to_raw_data_and_unzip.sh.err \
-t 1:00:00 \
--mail-type=FAIL \
step1-1_make_links_to_raw_data.sh
