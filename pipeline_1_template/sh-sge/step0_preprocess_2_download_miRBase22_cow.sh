#création du répertoire miRBase 22
#mkdir ../mirbase22

#se placer dans le bon répertoire 
cd ../mirbase22

#téléchargement
#echo "téléchargement des miARN mature toutes espèces"
wget ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz

#téléchargement
#echo "téléchargement des miARN précurseurs toutes espèces"
wget ftp://mirbase.org/pub/mirbase/CURRENT/hairpin.fa.gz

#echo "décompresser les fichiers"
gunzip mature.fa.gz

#echo "décompresser les fichiers"
gunzip hairpin.fa.gz

echo "extraire les matures bta du fichiers comportant les matures toutes espèces"
../bin/extract_seq_which_id_contains.pl --fasta_in mature.fa --word bta --file_out ./mature_bta.fa --begining yes

echo "nbre de séquences matures bta dans le fichier miRbase 22 mature.fa" 
grep -c ">bta" mature.fa

echo "nbre de séquences matures bta dans le nouveau fichier mature_bta.fa" 
grep -c ">bta" mature_bta.fa 

echo "extraire les matures non bta du fichier comportant les matures toutes espèces"
../bin/extract_seq_which_id_contains.pl --fasta_in mature.fa --word bta --file_out ./mature_no_bta.fa --begining yes --inverse yes

echo "nbre de séquences matures totales dans le fichier miRbase 22 mature.fa"
grep -c ">" mature.fa

echo "nbre de séquences matures non bta dans le fichier miRbase 22 mature_no_bta.fa"
grep -c ">" mature_no_bta.fa

echo "extraire les hairpins bta du fichier comportant les hairpins toutes espèces"
../bin/extract_seq_which_id_contains.pl --fasta_in hairpin.fa --word bta --file_out ./hairpin_bta.fa --begining yes

echo "nbre de séquences hairpin bta dans le fichier miRbase 22 hairpin_bta.fa"
grep -c ">" hairpin_bta.fa

#Retirer les espaces de ID des séquences miRbase 22 (pour miRDeep2)
perl -pi -e 's/(>\S+)\s.+/\1/' mature_bta.fa
perl -pi -e 's/(>\S+)\s.+/\1/' mature_no_bta.fa
perl -pi -e 's/(>\S+)\s.+/\1/' hairpin_bta.fa
perl -pi -e 's/(>\S+)\s.+/\1/' mature.fa
