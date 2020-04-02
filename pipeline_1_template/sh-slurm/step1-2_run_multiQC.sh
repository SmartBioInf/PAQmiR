#!/bin/bash

# load project configuration
source config.txt

#Purge any previous modules
module purge

# run multiQC
module load bioinfo/MultiQC-v1.7

cd $sources
multiqc .

