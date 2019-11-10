# remove all after id in fasta header
cat ${1} | perl -p -e 's/(>\S+)\s.+/\1/' > ${2}
