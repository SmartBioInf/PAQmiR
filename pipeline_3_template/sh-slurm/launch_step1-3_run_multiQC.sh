#!/bin/bash

# load project configuration
source config.txt

sbatch \
-J multiqc \
-o $sources/mutiQC.out \
-e $sources/mutiQC.err \
--mem=8G \
--mail-type=FAIL \
step1-3_run_multiQC.sh
