#!/bin/bash

# load project configuration
source config.txt

sbatch \
-J tag_stats \
-o ${UMI_tagged}/step2-2_make_stats_on_tag.out \
-e ${UMI_tagged}/step2-2_make_stats_on_tag.err \
--mem=8G \
--mail-type=FAIL \
step2-2_make_stats_on_tag.sh
