#!/bin/bash

# load project configuration
source config.txt 

sbatch \
-J parse_quantifier \
-o $quantifier_results/parse_quantifier_clust.out \
-e $quantifier_results/parse_quantifier_clust.err \
-t 1:00:00 \
--mem=4G \
--mail-type=FAIL \
step5-2_parse_quantifier.sh
