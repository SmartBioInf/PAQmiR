#!/bin/bash
#
#       step0_preprocess_1_download_miRBase_ref.sh
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

# create mirbase folder
mkdir $mirbase_folder

# move to folder
cd $mirbase_folder

# download mirbase files
echo "Download file containing matures sequences for all species"
wget ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz

#téléchargement
echo "Download file containing hairpin sequences for all species"
wget ftp://mirbase.org/pub/mirbase/CURRENT/hairpin.fa.gz

echo "uncompress mature file"
gunzip mature.fa.gz

echo "uncompress hairpin file"
gunzip hairpin.fa.gz

echo "extract the reference matures from the file containing the all-species matures"
$PAQmiR_bin/extract_seq_which_id_contains.pl --fasta_in mature.fa --word $species_code --file_out $miRNAs_ref --begining yes

echo "number of refrence mature sequences in the new file mature_${species_code}.fa" 
grep -c ">${species_code}" $miRNAs_ref

echo "extract the non reference matures from the file containing the all-species matures"
$PAQmiR_bin/extract_seq_which_id_contains.pl --fasta_in mature.fa --word ${species_code} --file_out $miRNAs_other --begining yes --inverse yes

echo "no. of total mature sequences in the miRbase mature.fa file"
grep -c ">" mature.fa

echo "no. of non-reference mature sequences in miRbase file mature_no_${species_code}.fa"
grep -c ">" $miRNAs_other

echo "extract the reference hairpins from the file containing all species hairpins"
$PAQmiR_bin/extract_seq_which_id_contains.pl --fasta_in hairpin.fa --word $species_code --file_out $precursors_ref --begining yes

echo "number of refrence hairpin sequences in miRbase hairpin_${species_code}.fa file"
grep -c ">" $precursors_ref

# Remove all information after space in sequences identifiers (for miRDeep2)
perl -pi -e 's/(>\S+)\s.+/\1/' $miRNAs_ref
perl -pi -e 's/(>\S+)\s.+/\1/' $miRNAs_other
perl -pi -e 's/(>\S+)\s.+/\1/' $precursors_ref
perl -pi -e 's/(>\S+)\s.+/\1/' mature.fa