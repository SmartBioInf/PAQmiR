#!/bin/bash

# load config variables
source ./config.txt

mkdir $quantifier_results

sbatch \
-J quantifier \
-o $quantifier_results/quantifier_clust.out \
-e $quantifier_results/quantifier_clust.err \
--mem=16G \
--mail-type=FAIL \
step5-1_run_quantifier.sh

