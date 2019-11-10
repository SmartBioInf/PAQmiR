#!/bin/bash

directory=`dirname $0`

# Extraction of precursors corresponding to the selected species (by identification of 3 letter code at the begining of the identifier)
perl $directory/extract_seq_which_id_contains.pl --fasta_in ${1} --word ${3} --inverse no --begining no --file_out ${4} #extract sequence with word in the identifier
perl -pi -e 's/(>\S+)\s.+/\1/' ${4} #recuperate informations before the first space

# Extraction of matures corresponding to the selected species (by identification of 3 letter code at the begining of the identifier)
perl $directory/extract_seq_which_id_contains.pl --fasta_in ${2} --word ${3} --inverse no --begining no --file_out ${5} #extract sequence with word in the identifier
perl -pi -e 's/(>\S+)\s.+/\1/' ${5} #recuperate informations before the first space

# Extraction of matures which are not corresponding to the selected species (by identification of 3 letter code at the begining of the identifier)
perl $directory/extract_seq_which_id_contains.pl --fasta_in ${2} --word ${3} --inverse yes --begining no --file_out ${6} #extract sequence without word in the identifier
perl -pi -e 's/(>\S+)\s.+/\1/' ${6} #recuperate informations before the first space
