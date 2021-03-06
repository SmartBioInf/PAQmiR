# PAQmiR
PAQmiR : Prediction Annotation and Quantification of miRNA with miRDeep2.
The PAQmiR approach was used in the following projects:

- **[1] Sunflower oil supplementation affects the expression of miR-20a-5p and miR-142-5p in the lactating bovine mammary gland.**
Mobuchon L, Le Guillou S, **Marthey S**, Laubier J, Laloë D, Bes S, Le Provost F, Leroux C.
PLoS One. 2017 Dec 27;12(12):e0185511. doi: 10.1371/journal.pone.0185511

- **[2] Deprivation Affects the miRNome in the Lactating Goat Mammary Gland.**
Mobuchon L, **Marthey S**, Le Guillou S, Laloë D, Le Provost F, Leroux C.
PLoS One. Food 2015 Oct 16;10(10):e0140111. doi: 10.1371/journal.pone.0140111.

- **[3] Annotation of the goat genome using next generation sequencing of microRNA expressed by the lactating mammary gland: comparison of three approaches.**
Mobuchon L, **Marthey S**, Boussaha M, Le Guillou S, Leroux C, Le Provost F.
BMC Genomics. 2015 Apr 11;16:285. doi: 10.1186/s12864-015-1471-y.

- **[4] Characterisation and comparison of lactating mouse and bovine mammary gland miRNomes.**
Le Guillou S, **Marthey S**, Laloë D, Laubier J, Mobuchon L, Leroux C, Le Provost F.
PLoS One. 2014 Mar 21;9(3):e91938. doi: 10.1371/journal.pone.0091938.

### Directory contents :  

**[/bin](bin)** contains all custom scripts used in the pipeline.  

**[/Galaxy directory](Galaxy)** contains all the wrappers to use the PAQmiR approach with Galaxy. Custom scripts used in the wrapper are symbolink links to the [bin](bin) folder.  

**[/pipeline_XX_template]** are examples of projects using the PAQmiR approach. 
It will help you understand what is used and produced at each step of the processing. 
The [/pipeline_XX_template/sh-[sge|slurm]] directory contains all the scripts required to run the PAQmiR approach on a calculation server. 
You will need to change the relative paths into absolute paths in the scripts to be executed on the cluster (sge/slurm). 

**[/pipeline_1_template](pipeline_1_template)** is the first and simplest version of the pipeline. It was the version used in publications [1-4].  
the main steps of the pipeline are :
   * reads collapsing and mapping against reference genome using mapper.pl (from miRDeep2 suite)  
   * precursor/miRNA prediction using mirdeep2.pl  
   * creation of new precursor/miRNA dataset by merging know and predicted precursors/miRNA  
   * quantification and annotation of the Know/novel miRNAs using quantifier.pl (from miRDeep suite)
   * post processing to remove redundancy between miRNAs  
More informations/descriptions of the pipeline can be found in the [/pipeline_1_template/documentation](pipeline_1_template/documentation) folder.  

*Comment : the shell scripts provided are set up for a cluster using a **sge** scheduler*  

**[/pipeline_2_template](pipeline_2_template)** This version is almost identical to template 1. The differences are as follows:
   * all the pipeline parameters are defined in a config.txt file
   * the samples to be analyzed must be described in a samples.txt file.
   * the files containing the reads must be in fastq.gz format instead of fastq
   * mapper.pl is replaced by the use of fastx_collapser + bowtie
   * slurm replaces sge

the main steps of the pipeline are :
   1. FASQC and multiQC 
   2. reads collapsing (fastx_collapser)
   3. reads mapping against reference genome using bowtie 
   4. precursor/miRNA prediction using mirdeep2.pl and create new dataset and creation of new precursor/miRNA dataset by merging know and predicted precursors/miRNA  
   5. quantification and annotation of the Know/novel miRNAs using quantifier.pl (from miRDeep suite)
   6. post processing to remove redundancy between miRNAs  
More informations/descriptions of the pipeline can be found in the [/pipeline_2_template/documentation](pipeline_2_template/documentation) folder.  

*Comment : the shell scripts provided are set up for a cluster using a **slurm** scheduler* and preconfigured for [Genotoul Bioinformatics Facility](http://bioinfo.genotoul.fr/)

**[/pipeline_3_template](pipeline_3_template)** is the second version of the pipeline. It is the version actually used in the majority of current projects.
the major additions to the pipeline_1 are :  
   * IsomiR analysis: creation of a count table of all the miRNA IsomiRs quantified by the miRDeep2 quantifier module. 
   * Generic sncRNA analysis: exploitation of all unique sequences (miRNA or not):  
      * creation of a general counting matrix of all the unique sequences  
      * annotation of sequences against reference databases  
      * merge with the results of the miRNA analysis  
More informations/descriptions of the pipeline can be found in the [/pipeline_3_template/documentation](pipeline_2_template/documentation) folder

*Comment : the shell scripts provided are set up for a cluster using a **slurm** scheduler*
