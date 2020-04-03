#!/bin/bash

# load project configuration
source config.txt

sbatch \
-J dl_index \
-o ${project_path}/index/step0_preprocess_3_download_and_index_bosTau8.sh.out \
-e ${project_path}/index/step0_preprocess_3_download_and_index_bosTau8.sh.err \
-t 8:00:00 \
--mem=16G \
--mail-type=FAIL \
step0_preprocess_2_download_and_index_bosTau8.sh
