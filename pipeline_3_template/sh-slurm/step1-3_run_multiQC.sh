#!/bin/bash

# load project configuration
source config.txt

#Purge any previous modules
module purge

# run multiQC
module load $MultiQC

cd $sources
multiqc .

