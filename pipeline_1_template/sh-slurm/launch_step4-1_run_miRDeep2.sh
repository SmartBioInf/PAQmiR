#!/bin/bash

# load project configuration
source config.txt

mkdir $mirdeep2_results

sbatch \
-J mirdeep2 \
-o $mirdeep2_results/mirdeep2.out \
-e $mirdeep2_results/mirdeep2.err \
--mem=16G \
--mail-type=FAIL \
step4-1_run_miRDeep2.sh
