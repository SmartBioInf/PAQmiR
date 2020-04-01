#!/bin/bash

# load project configuration
source config.txt

################################
# create mirbase folder (if needed)
echo "##### create mirbase folder"
mkdir $project_path/mirbase22

################################
# create sources folder 
echo "##### create sources folder"
mkdir $sources

################################
# create sources folder 
echo "##### create collapsed reads folder"
mkdir $collapsed

################################
# create mapper folder 
echo "##### create mapper folder"
mkdir $project_path/mapper


################################
# create mirdeep2 folder 
echo "##### create mirdeep2 folder"
mkdir $project_path/mirdeep2

################################
# create quantifier folder 
echo "##### create quantifier folder"
mkdir $project_path/quantifier

################################
# create quantification_annotation folder 
echo "##### create quantification_annotation folder"
mkdir $project_path/quantification_annotation



