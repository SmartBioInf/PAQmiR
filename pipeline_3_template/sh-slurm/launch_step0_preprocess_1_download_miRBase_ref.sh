#!/bin/bash

# load project configuration
source config.txt

mkdir ${mirbase_folder}

sbatch \
-J dl_mirbase \
-o ${mirbase_folder}/step0_preprocess_1_download_miRBase_ref.sh.out \
-e ${mirbase_folder}/step0_preprocess_1_download_miRBase_ref.sh.err \
-t 8:00:00 \
--mem=16G \
--mail-type=FAIL \
step0_preprocess_1_download_miRBase_ref.sh