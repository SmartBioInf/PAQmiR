#!/bin/bash
#
#       step0_preprocess_2_download_and_index_bosTau9.sh
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

################################
# create index folder (if needed)
echo "\n#### Create index folder"
mkdir $project_path/index/

cd $project_path/index/

# download reference fasta file
wget http://hgdownload.soe.ucsc.edu/goldenPath/bosTau9/bigZips/bosTau9.fa.gz

# unzip reference genome
gzip -d bosTau9.fa.gz

# download reference genome 

module load bioinfo/bowtie-1.2.1.1

# Launch quantifier.pl with new sets
bowtie-build $genome $genome_bwt
