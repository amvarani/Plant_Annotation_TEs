# Plant Genome Annotation
#### _Methods and recipes for Plant Genome Annotation with focus on Transposable Elements_

## Introduction
Transposable elements (TEs) are major features of a plant genome. During a plant genome annotation project, the TEs must be first identified before the structural gene annotation. After a proper TE annotation, all TE-derived regions in the genome must be masked (preferably soft-masked: repeats in lowercase rather than "N" or "X").

EDTA is one of the most powerfull and complete TE annotation pipeline. However, EDTA has low power to annotate SINEs and LINEs. In that sense, the pipeline describled here will create a non-redundant SINEs/LINEs library, of your species genome using structural based methods. These libraries can be further suplied to our modified version EDTA of pipeline  (--sine and --line flags).

Moreover, it is known that the EDTA pipeline often generates many false positives TE predictions (mainly represented by TIRs elements).To avoid false positives, we developed an adaptation on the EDTA pipeline that tries to lower the false positive prediction of TIR elements. This adapted EDTA version also provides a complete annotation of non-autonomous LTR elements (e.g., LARD, TRIM, TR-GAG, and BARE-2), and give a complete annotation of SINE, LTR and TIRs elements at their respective lineages. Furthermore, helitrons elements are divided into autonomous (contaning HEL domain) and non-autonomous (not contaning HEL domain). 

The input is a **fasta** file containing the plant genome in chromosme scale (preferably). The final result will be a augmented TE annotation (containing the outputs commonly genereated by EDTA pipeline), a proper masked genome for structural gene annotation, and a complete TE report showing TE lineages abundances.

Since this pipeline can retrieve complete CRM elements, it is also possible to figure out the potential centromeric regions, using additional approaches with trf tool.  

**Important Notice 1:** This pipeline was tested only on Ubuntu 20.20 and was made for Plant Genomes only.
**Important Notice 2:** This pipeline is not perfect, and is under development for improvements.


## Features

- SINE and LINE strucutural identification, validation and annotation.
- Autonomous LTR elements full annotation at superfamily and lineages. 
- Non-automous LTR elements full annotation: LARD, TRIM, TR_GAG, and BARE-2.
- Autonomous Helitron full annotation.
- Non-automous Helitron full annotation.
- Autonomous TIR elements full annotation at superfamily and lineages.
- Non-autonomous TIR elements: MITEs.
- All annotation follow the Rexdb and GyDB nomenclature as proposed by ``Orozco-Arias et al., 2019``.
- Proper soft-masking for downstream analysis (for structural gene annotation).
- Complete TE distribution Report (text file - a graphical version will be added). 
- Identification of potential (peri)centromeric regions of each chromosome. 
- Drawing of the Repeat Landscape.
- LTR Age Ploting using R (Gypsy and Copia). 
  

## Tools used

- SINE Annotation with a modified version of AnnoSINE pipeline: https://github.com/baozg/AnnoSINE
- LINE Annotation with mgescan nonltr and validation with TEsorter pipeline: https://github.com/MGEScan
- Global TE annotation with a modified version of EDTA pipeline (including all dependencies) tailored for non-model plant genomes and to remove potential false positive predictions: https://github.com/oushujun/EDTA.
- TE annotation and validation with TEsorter: https://github.com/zhangrengang/TEsorter
- Global TE report based on a modified version of ProcessRepeats scripts from RepeatMasker: https://www.repeatmasker.org/RepeatMasker/
- Repeat Landscape and LTR Age Ploting using RepeatMasker and R scripts. 

## Installation

The instalation is divided in four main steps

#### Step 01: Download the repository
In your terminal window, run:

```sh
git clone https://github.com/amvarani/Plant_Annotation_TEs $HOME/TEs
```
Now, enter into the folder
```sh
cd $HOME/TEs
```

#### Step 02: Install the Miniconda

* Download the Miniconda installer for Linux: https://docs.conda.io/en/latest/miniconda.html#linux-installers

In your terminal window, run:

```sh
bash Miniconda3-latest-Linux-x86_64.sh
```

Follow the prompts on the installer screens.

If you are unsure about any setting, accept the defaults. You can change them later.

To make the changes take effect, close and then re-open your terminal window.

Test your installation. In your terminal window or Anaconda Prompt, run the command ``conda list``. A list of installed packages appears if it has been installed correctly.


#### Step 03: Install other dependencies

In your terminal window, run:

```sh
sudo apt-get install lib32z1 python-is-python3 python3-setuptools python3-biopython python3-xopen trf hmmer2
sudo apt-get install hmmer emboss python3-virtualenv python2 python2-setuptools-whl python2-pip-whl cd-hit iqtree
sudo apt-get install python2-dev build-essential linux-generic libmpich-dev libopenmpi-dev bedtools pullseq bioperl
#
# R dependencies
sudo apt-get install r-cran-ggplot2 r-cran-tidyr r-cran-reshape2 r-cran-reshape rs r-cran-viridis r-cran-tidyverse r-cran-gridextra r-cran-gdtools
#
# Enter in R shell and install 
install.packages("hrbrthemes")
#
#
wget https://tandem.bu.edu/irf/downloads/irf305.linux.exe
mv irf305.linux.exe irf
sudo cp irf /usr/local/bin
sudo cp break_fasta.pl /usr/local/bin
```

#### Step 04: Install TEsorter
In your terminal window, run:
```sh
cd $HOME/TEs/TEsorter
sudo python3 setup.py install
# Hmmpress the databases (The path may be different depending on the python version - see the two examples below)
cd /usr/local/lib/python3.6/dist-packages/TEsorter-1.4.1-py3.6.egg/TEsorter/database/
or
cd /usr/local/lib/python3.10/dist-packages/TEsorter-1.4.1-py3.10.egg/TEsorter/database/ 
sudo hmmpress REXdb_v3_TIR.hmm
sudo hmmpress Yuan_and_Wessler.PNAS.TIR.hmm
sudo hmmpress REXdb_protein_database_viridiplantae_v3.0_plus_metazoa_v3.hmm
sudo hmmpress REXdb_protein_database_viridiplantae_v3.0.hmm
sudo hmmpress REXdb_protein_database_metazoa_v3.hmm
sudo hmmpress Kapitonov_et_al.GENE.LINE.hmm
sudo hmmpress GyDB2.hmm
sudo hmmpress AnnoSINE.hmm
cd $HOME/TEs 
```

#### Step 04 (optional): Download a genome example file

In your terminal window, run:
```sh
wget https://cocoa-genome-hub.southgreen.fr/sites/cocoa-genome-hub.southgreen.fr/files/download/Theobroma_cacao_pseudochromosome_v1.0_tot.fna.tar.gz
tar xvfz Theobroma_cacao_pseudochromosome_v1.0_tot.fna.tar.gz
mv Theobroma_cacao_pseudochromosome_v1.0_tot.fna Tcacao.fasta
##
##
## Or Arabidopsis thaliana 
wget https://www.arabidopsis.org/download_files/Genes/TAIR10_genome_release/TAIR10_chromosome_files/TAIR10_chr_all.fas.gz
gzip -d TAIR10_chr_all.fas.gz
cat TAIR10_chr_all.fas | cut -f 1 -d" " > At.fasta
rm TAIR10_chr_all.fas
```

#### Very Important:  
Please use simpe fasta headers! For example: >chr01, >scf001, >ctg001 and etc. 

Do not use (**NEVER**) characters like "_" , "-" , "/" , "|" , for example >chr_001, >scf-001, >ctg|001  and etc!   

The pipeline may crash if you dont't use simple fasta headers acording the above instructions!


## SINE Annotation with a modified version of AnnoSINE pipeline
This version of AnnoSINE was optimized to deal with chromosome scale genomes. Therefore, most of the optimizations were made to make the pipeline faster and to accept larger fasta files.

* Enter into the SINE folder:

In your terminal window, run:
```sh
cd SINE
cd AnnoSINE/
```
* Create and activate the AnnoSINE conda enviroment:

In your terminal window, run (only necessary to run once):
```sh
conda env create -f AnnoSINE.conda.yaml
```
* Run the test data (_A. thaliana_ chromosome 4) to verify the instalation:

In your terminal window, run:
```sh
cd bin
conda activate AnnoSINE
python3 AnnoSINE.py 3 ../Testing/A.thaliana_Chr4.fasta ../Output_Files
``` 
A 'Seed_SINE.fa' file must be created on the '../Output_Files'. This file contains all predicted SINE elements and will be used later in the pipeline next steps. This step should be fast and run in less than 5 minutes.

Now, we are ready to annotate the SINE elements from your genome project file.

* Copy or create a symbolic link of your genome file in the AnnoSINE bin folder. 

In this example we will run the pre-loaded _Arabidopsis_ genome which is already downloaded(instructions above):
Alternatively, you may use your own data.

Important: All genome files *must* have the .fasta extension. The AnnoSINE pipeline will crash if you use other file extension, for example ".fa"

In your terminal window, run:
```sh
cd bin
python3 AnnoSINE.py 3 $HOME/TEs/At.fasta At
#
# Copy the Seed_SINE.fa to the home of the TE folder
cp ./At/Seed_SINE.fa $HOME/TEs/At-Seed_SINE.fa
``` 

**Important**: Depending on the genome size and number of SINE, this step may take couple hours to run.


* Deactivate the AnnoSINE conda environment and return to the main folder

In your terminal window, run:
```sh
conda deactivate
cd $HOME/TEs
``` 


## LINE Annotation with MGEScan-non-LTR and primary validation with TEsorter
We will use the MGEScan-non-LTR to identify LINE elements. However, this approach generates several false positive elements (e.g., real LTR elements). 
Therefore, we need to filter the results, and identify potential LINES elements. 

Other important information: MGEScan-non-LTR pipeline uses a older version of hmmer. Therefore, we need to install an older hmmer version (3.2).

* Enter into the non-LTR folder:

In your terminal window, run:
```sh
cd non-LTR
cd mgescan
```
* Create a proper python virtualenv to run mgescan:

In your terminal window, run (remember that you must deactive the conda enviroment) (only necessary to run once):
```sh
virtualenv -p /usr/bin/python2 mgescan-virtualenv
source mgescan-virtualenv/bin/activate
pip2 install biopython==1.76
pip2 install bcbio-gff==0.6.6
pip2 install docopt==0.6.1
python setup.py install
```
Follow the prompts on the installer screens.

If you are unsure about any setting, accept the defaults.

* Now the mgescan is instaled and ready to run. Test the installation:

In your terminal window, run:
```sh
mgescan --help
```
* Now you need to compile the hmmer version 3.2 (already downloaded, and almost ready to go) and set the PATH enviroment to use this version:

In your terminal window, run (only necessary to run once):
```sh
cd ..
cd hmmer-3.2
make clean
./configure
make -j
```
* Set the 3.2 version first in our PATH enviroment. 

In your terminal window, run:
```sh
PATH=$HOME/TEs/non-LTR/hmmer-3.2/src/:$PATH 
```
* Finally, you are ready to run the MGEScan-non-LTR with a __A. thaliana__ genome  (you may replace the test data with your genome sequence):

In your terminal window, run:
```sh
# Go back to the non-LTR folder
cd $HOME/TEs/non-LTR
#
# Create a project dir and link your genome file to this folder
mkdir At-LINE
cd At-LINE
ln -s $HOME/TEs/At.fasta At.fasta
cd ..
#
# Set the ulimit higher value - See below
ulimit -n 8192
#
# Run MGEScan-non-LTR
mgescan nonltr $HOME/TEs/non-LTR/At-LINE --output=$HOME/TEs/non-LTR/At-LINE-results --mpi=4
```
**Note 1:** Sometimes is necessary to set an ulimit higher value. This is extremely necessary to run large chromosome scale genomes (chromosmes larger than >80Mb).   

**Note 2:** Set the number of threads avaliable in your computer or server. Please set the half of the total avaliable threads. 

**Note 3:** Always remember to deactive completely the conda enviroment and activate the python virtualenv before run MGEScan-non-LTR. 


* Processing the MGEScan-non-LTR results: removing false positives with TEsorter, and generating the pre-final non-redundant LINE library showing compatible input for the modifed EDTA pipeline

First, enter into the folder contaning the results
```sh 
cd At-LINE-results
```

Then, in your terminal window, copy and paste the code below and run. This will generate the non-redundant LINE-lib.fa file :

```sh 
cat info/full/*/*.dna > temp.fa
cat temp.fa | grep \>  | sed 's#>#cat ./info/nonltr.gff3 | grep "#g'  | sed 's#$#" | cut -f 1,4,5#g'  > ver.sh
bash ver.sh  | sed 's#\t#:#' | sed 's#\t#\.\.#'   > list.txt
#
mkdir TMP
break_fasta.pl < temp.fa TMP/
cat temp.fa | grep \> | sed 's#>#cat ./TMP/#g' | sed 's#$#.fasta#g' > A.txt
cat temp.fa | grep \> > list2.txt
paste list2.txt list.txt | sed 's/>/ sed "s#/g'  | sed 's/\t/#/g' | sed 's/$/#g"/g'   > B.txt
paste A.txt B.txt  -d"|"  > rename.sh
bash rename.sh > candidates.fa
#
/usr/local/bin/TEsorter -db rexdb-plant --hmm-database rexdb-plant -pre LINE -p 22 -rule 60-60-60 candidates.fa
more LINE.cls.lib  | sed 's/#/__/g'  | sed 's#.fa##g' | cut -f 1 -d" " | sed 's#/#-#g'  > pre1.fa
mkdir pre1
break_fasta.pl < pre1.fa pre1
cat pre1/*LINE.fasta  | sed 's#__#\t#g' | cut -f 1  > pre2.fa
/usr/local/bin/TEsorter -db rexdb-line --hmm-database rexdb-line -pre LINE2 -p 22 -rule 60-60-60 pre2.fa
more LINE2.cls.lib  | sed 's/#/__/g'  | sed 's#.fa##g' | cut -f 1 -d" " | sed 's#/#-#g'  > pre-final.fa
mkdir pre-final
break_fasta.pl < pre-final.fa pre-final
cat pre-final/*LINE*.fasta  > pre-final2.fa
cdhit-est -i pre-final2.fa -o clustered -c 0.8 -G 1 -T 22 -d 100 -s 0.6 -aL 0.6 -aS 0.6
cat clustered | sed 's/__/#/g' | sed 's#-#/#g'  > LINE-lib.fa
#
rm -rf pre1/ pre-final/ TMP/
rm LINE2*
rm LINE.cls.*
rm A.txt B.txt clustered.clstr clustered LINE.dom* list2.txt list.txt pre1.fa pre2.fa pre-final2.fa pre-final.fa rename.sh temp.fa ver.sh candidates.fa
cp LINE-lib.fa $HOME/TEs/At-LINE-lib.fa 
```

* Deactivate the python virtualenv and return to the main folder:

In your terminal window, run:
```sh
deactivate
cd $HOME/TEs
```

**IMPORTANT**: The pre-final non-redundant LINE library may still contain false positives (e.g., LTRs). The modified EDTA pipeline step will try to remove all potential false positives using their built-in scripts, and using the identified complete LTR, TIR, and Helitrons elements. 
Moreover, the RepeatModeler Step from the EDTA pipeline may also catch up with other LINEs. Therefore, the final LINE library is generated under the EDTA step. See instruction to retrieve all LINE elements fasta file in the next section.

Please don't use the library generated in this step as a __final and high-quality__ LINE prediciton. 



## TE Annotation with EDTA using the SINEs and LINEs previously identified
This version of the EDTA pipeline was modified to accomodate the SINE and LINE libraries generated above, with the use the "--line" and "--sine" flags. Moreover, this version is also capable to distingish LARDs, TRIMs, TR_GAGs, and BARE-2 elements from the identified LTR sequences on the structural step (TIR, LTR and Helitron). All TEs are classified at Superfamily and Lineages, using the nomenclature proposed by ``Orozco-Arias et al., 2019``. 
This version has also some enhacements in the Helitron detection steps (speed-up), and detection of LTR elements contaning non cannonical motifs and larger LTRs. The classification at superfamily and lineages present two different level: Complete and incomplete. For incomplete the suffix "-like" is added in the end of each element.
The outputs are exactly the same generated by the original EDTA pipeline, but contaning the complete TE annotation at Superfamily and Lineages in the fasta and gff3 files. 
This pipeline also generate a proper softmasked version of the genome that is ready for structural gene annotation. 


* Install and activate EDTA conda enviroment (only necessary to run once)

In your terminal window, run:
```sh
cd EDTA
# Re-start the conda enviroment 
bash
#
#
conda env create -f EDTA.yml
conda activate EDTA
cd $HOME/TEs
perl EDTA.pl
```

* run EDTA using the SINE and LINE libraries. 

In your terminal window, run (please note that we need to call our EDTA modified version located at $HOME/TEs/EDTA folder):
```sh
#
# Create and enter into the project folder
mkdir Athaliana
cd Athaliana
#
# Run EDTA in the backgroup
nohup $HOME/TEs/EDTA/EDTA.pl --genome ../At.fasta --species others --step all --line ../At-LINE-lib.fa --sine ../At-Seed_SINE.fa --sensitive 0 --anno 1 --threads 22 > EDTA.log & 
```

**Note 1:** Set the number of threads avaliable in your computer or server. Please set the maximum avaliable. 

**Note 2:** For a more precise TE detection and annotation, please enable the "sensitive" flag. This will activate RepeatModeler to identify remaining TEs and other repeats. The RepeatModeler step will also generate Superfamily and Lineages TE classification, and may catch other LINEs elements and others Unknown repeats. Our modified EDTA pipeline will do it automatically. 
This step is strongly recommend. 

* Keep track of the execution log 

In your terminal window, run:
```sh
tail -f EDTA.log
```
**Important**: Depending on the genome size and number of TEs this step may take several hours to run.

**Note 1**: The SINE and LINE structural annotation are avaliable on the $genome.EDTA.raw folder. Look for SINE.intact.fa, SINE.intact.gff3, LINE.intact.fa, and LINE.intact.gff3

**Note 2**: The final LINE library is embedded into the TElib.fa file. Therefore, if you want to retrieve all LINEs, use this file.


## Genome Soft-masking
Generally non-autonomous elements may carry passenger genes (e.g., non-autonomous LARDs and Helitrons). Therefore, for a proper genome annotation, these elements should not be entirely masked.
The modified EDTA pipeline will automatically take care on this and generating a proper masked genome sequence for structural gene annotation.
The softmasked genome sequence is avaliable in the EDTA folder, with the name **$genome-Softmasked.fa**.


## Generating a complete TE report
To generate this report an modified version o ProcessRepeat script from RepeatMasker package will be used.
The necessery perl files are located on the $HOME/TEs/ProcessRepeats folder
The modified script name are _ProcessRepeats-complete.pl_ and _ProcessRepeats-lite.pl_

In your terminal window, run (Using Athaliana as example, you may change the folder names and files names for convenience):

**Remember to be inside the EDTA conda enviroment**
```sh
cd $HOME/TEs
cd Athaliana
mkdir TE-REPORT
cd TE-REPORT
ln -s ../At.fasta.mod.EDTA.anno/At.fasta.mod.cat.gz .
#
# Run the modifed process repeat script - This may take several minutes depending of the genome size (in this Athaliana example, should be less than 5 min)
$HOME/TEs/ProcessRepeats/ProcessRepeats-complete.pl -species viridiplantae -nolow -noint At.fasta.mod.cat.gz
#
# Rename the result file and move it to the main EDTA folder
mv At.fasta.mod.tbl ../TEs-Report-Complete.txt
```

The _ProcessRepeats-complete.pl_ script generate a result file named as: **TEs-Report-Complete.txt**.

In this report, partial elements will be named with the suffix "-like" (e.g., Angela-like)

![image](https://user-images.githubusercontent.com/3044067/198836679-2f215880-3934-4eb6-b9f0-9abb400e147a.png)





For a simple report you may repeat the process above using the _ProcessRepeats-lite.pl_ script instead
```sh
cd $HOME/TEs
cd Athaliana
mkdir TE-REPORT
cd TE-REPORT
ln -s ../At.fasta.mod.EDTA.anno/At.fasta.mod.cat.gz .
#
# Run the modifed process repeat script - This may take several minutes depending of the genome size (in this Athaliana example, should be less than 5 min)
 $HOME/TEs/ProcessRepeats/ProcessRepeats-lite.pl -species viridiplantae -nolow -noint -a At.fasta.mod.cat.gz
#
# Rename the result file and move it to the main EDTA folder
mv At.fasta.mod.tbl ../TEs-Report-lite.txt
```
The _ProcessRepeats-lite.pl_ script generate a result file named as: **TEs-Report-lite.txt**.

![image](https://user-images.githubusercontent.com/3044067/198836649-0965137b-9277-41f4-952e-220a86d9af8e.png)

## Drawing of the Repeat Landscape.
The repeat landscape graphs illustrates the relative amount of each TE class associated to the Kimura distance on the x-axis as a proxy for time, whereas the y-axis gives the relative coverage of each repeat class based on the genome size.
Therefore the repeat landscape graph is a good inference of the relative ages of each element identified in a given genome.

To generate the repeat landscape graph we need to use the *.align file generated in the previous step (Generating a complete TE report) located in the **TE-REPORT** folder.

In your terminal window, run (we are using Athaliana as example, you may change the folder names and files names for convenience):

**Remember to be inside the EDTA conda enviroment**

```sh
cd $HOME/TEs
cd Athaliana
cd TE-REPORT
#
# You may locate the *.align file as At.fasta.mod.align
#
cat At.fasta.mod.align  | sed 's#TIR/.\+ #TIR &#g'  | sed 's#DNA/Helitron.\+ #Helitron &#g' | sed 's#LTR/Copia.\+ #LTR/Copia &#g' | sed 's#LTR/Gypsy.\+ #LTR/Gypsy &#g'  | sed 's#LINE-like#LINE#g' | sed 's#TR_GAG/Copia.\+ #LTR/Copia &#g' | sed 's#TR_GAG/Gypsy.\+ #LTR/Gypsy &#g' | sed 's#TRBARE-2/Copia.\+ #LTR/Copia &#g' | sed 's#BARE-2/Gypsy.\+ #LTR/Gypsy &#g' | sed 's#LINE/.\+ #LINE &#g' > tmp.txt
#
#
# For convenience you may choose less elements just skipping the desirable lines below
#
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "LTR/Copia" -A 5 |  grep -v "\-\-"  > align2.txt
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "LTR/Gypsy" -A 5 |  grep -v "\-\-"  >> align2.txt
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "TIR" -A 5 |  grep -v "\-\-"  >> align2.txt
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "LINE" -A 5 |  grep -v "\-\-"  >> align2.txt
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "LARD" -A 5 |  grep -v "\-\-"  >> align2.txt
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "TRIM" -A 5 |  grep -v "\-\-"  >> align2.txt
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "Helitron" -A 5 |  grep -v "\-\-"  >> align2.txt
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "SINE" -A 5 |  grep -v "\-\-"  >> align2.txt
cat tmp.txt  | grep "^[0-9]"  -B 6 |  grep -v "\-\-"  | grep "Unknown" -A 5 |  grep -v "\-\-"  >> align2.txt
#
# Now calculate the divergence 
$HOME/TEs/ProcessRepeats/calcDivergenceFromAlign.pl -s At.divsum align2.txt
#
# Calculate genome size
genome_size="`perl $HOME/TEs/EDTA/util/count_base.pl ../At.fasta.mod | cut -f 2`" 
$HOME/TEs/ProcessRepeats/createRepeatLandscape.pl -g $genome_size -div At.divsum > ../RepeatLandscape.html
#
tail -n 72 At.divsum > divsum.txt
#
cat $HOME/TEs/Rscripts/plotKimura.R | sed "s#_SIZE_GEN_#$genome_size#g" > plotKimura.R
#
Rscript plotKimura.R
mv Rplots.pdf ../RepeatLandScape.pdf
#
rm align2.txt
rm tmp.txt
```

![image](https://user-images.githubusercontent.com/3044067/198374262-9c40aecf-8404-46a1-b5e4-73c606b1d40b.png)



The results files are: **RepeatLandscape.html** and **RepeatLandScape.pdf**

This Rscript was obtained from a previous thread at EDTA github: https://github.com/oushujun/EDTA/issues/92


## LTR Age Ploting (Gypsy and Copia). 
To plot the LTR Gypsy and LTR Copia elements age, we will use a ggplot2 Rscript. 


In your terminal window, run (Using Athaliana as example, you may change the folder names and files names for convenience):

```sh
cd $HOME/TEs
cd Athaliana
mkdir LTR-AGE
cd LTR-AGE
ln -s ../At.fasta.mod.EDTA.raw/At.fasta.mod.LTR-AGE.pass.list .
#
ln -s $HOME/TEs/Rscripts/plot-AGE-Gypsy.R .
ln -s $HOME/TEs/Rscripts/plot-AGE-Copia.R .
#
# Preparing the file
cat -n At.fasta.mod.LTR-AGE.pass.list  | grep Gypsy  | cut -f 1,13 | sed 's# ##g'  | sed 's#^#Cluster_#g' | awk '{if ($2 > 0) print $n}'   > AGE-Gypsy.txt
cat -n At.fasta.mod.LTR-AGE.pass.list  | grep Copia  | cut -f 1,13 | sed 's# ##g'  | sed 's#^#Cluster_#g' | awk '{if ($2 > 0) print $n}'   > AGE-Copia.txt
#
# Generating the plots
Rscript plot-AGE-Gypsy.R
Rscript plot-AGE-Copia.R
```

This will generate two PDF files showing the histogram plot of the LTR ages. The dashed vertical lines represents the median, while the vertical line represent the mean (in Mya).  


![image](https://user-images.githubusercontent.com/3044067/198373570-040b9dd7-dcda-4fe8-bae7-f0c748058d03.png)




## Figuring out the potential (peri)centromeric regions
Centromeres are defined epigenetically by the histone H3 variant, CENH3 (plants), the presence of which is necessary and sufficient for centromere formation (Musacchio and Desai 2017). Therefore, ChIP-seq approaches are necessary for a proper centromeric region identification. However, this method is labor intensive and thus difficult to do. 

The centromeric and pericentromeric regions of plant chromosomes are colonized by Ty3/gypsy retrotransposons from the chromovirus CRM clade. Moreover, centromeres often form tandem repeats that can be identified using sequence search approaches. 
This analysis is based on LTR/Gypsy/CRM elements previous mapping associated with the use of the trf tool for tandem repeats identification using the approach describled elsewhere (Melters, et al., 2013).
The method present here **is not perfect**, but can be used to estimate the centromeric/pericentromeric regions when only the genome sequence sequence is avaliable. 

In the first step, we will use the script **trf_wrapper.pl** avaliable at: http://korflab.ucdavis.edu/Datasets/Centromere_data/ (Melters et al., 2013) and ready to be used in our Scripts folder. 

In your terminal window, run (You may change the folder names and files names for convenience):
```sh
cd $HOME/TEs
cd Athaliana
mkdir centromer
cd centromer
$HOME/TEs/Scripts/trf_wrapper.pl -file At.fasta -match 1 -mismatch 1 -indel 2 -pmatch 80 -pindel 5 -min_score 200 -period 2000 -copies 2 -length 50 -low_repeat_cutoff 0.5 -high_repeat_cutoff 0.8 -slim 
#
$HOME/TEs/Scripts/trf_hos_finder.pl At.fasta.1.1.2.80.5.200.2000.dat  > HOS.txt
```

You may try to find out the largest repeat (LENGTH field) contaning the largest number of copies (COPIES field) in the HOS.txt file. 

In your terminal window, run
```sh
cat HOS.txt | grep Chr1 | sort -k5 -V
cat HOS.txt | grep Chr2 | sort -k5 -V
cat HOS.txt | grep Chr3 | sort -k5 -V
cat HOS.txt | grep Chr4 | sort -k5 -V
cat HOS.txt | grep Chr5 | sort -k5 -V
```

After manual inspection, you may select the HOS repeats and/or largest repeats. For instance, for A. thaliana: 

![image](https://user-images.githubusercontent.com/3044067/199091503-8b7c2007-aca1-4c9b-aaca-9fbe3153f400.png)


These are the regions showing proximity to the centromer and pericentromeric regions. 


In the second step, we will map the position of each CRM elements in the assembled chromossomes.

In your terminal window, run (You may change the folder names and files names for convenience):
```sh
cd $HOME/TEs/centromer
bp_gccalc  Bcaapi.fasta | grep "Len:" > length.txt
cat ../At.fasta.mod.EDTA.intact.gff3 | grep Gypsy_LTR_retrotransposon | grep "LTR/Gypsy/CRM" | cut -f 1,4,5 | grep Chr1
cat ../At.fasta.mod.EDTA.intact.gff3 | grep Gypsy_LTR_retrotransposon | grep "LTR/Gypsy/CRM" | cut -f 1,4,5 | grep Chr2
cat ../At.fasta.mod.EDTA.intact.gff3 | grep Gypsy_LTR_retrotransposon | grep "LTR/Gypsy/CRM" | cut -f 1,4,5 | grep Chr3
cat ../At.fasta.mod.EDTA.intact.gff3 | grep Gypsy_LTR_retrotransposon | grep "LTR/Gypsy/CRM" | cut -f 1,4,5 | grep Chr4
cat ../At.fasta.mod.EDTA.intact.gff3 | grep Gypsy_LTR_retrotransposon | grep "LTR/Gypsy/CRM" | cut -f 1,4,5 | grep Chr5
```

![image](https://user-images.githubusercontent.com/3044067/199092822-c86a145d-f087-4abb-866b-f30fc76f43fd.png)


**Where are the peri(centromeric) regions ?**

As stated before, this method give a idea of the location of the centromeric and pericentromeric region. It not perfect, but a good approach.
To estimate the peri(centromeric) region use the smallest and lorgest coordinates identified for each chromosome, and for potential centromer use the mean.

According the results showed above we will have: 

-For Chr1 - Between:  15,081,858 to 16,434,206  
-For Chr2 - Between:  2,793,404 to 5,201,882    
-For Chr3 - Between:  12,549,504 to 14,734,610   
-For Chr4 - Between:  2,090,153 to 4,251,681     
-For Chr5 - Between:  11,184,520 to 12,807,216   

According the literature, these are the centromeric coordinates for A. thaliana: 

-Chr1:	14,511,721 to 14,538,721

-Chr2:	3,611,838	to 3,611,883	

-Chr3:	13,589,756 to	13,589,816

-Chr4:	3,133,663	to 3,133,674	

-Chr5:	11,194,537 to	11,194,848	


## Plot Phylogeny of LTR elements
We will plot the phylogeny of the alignments of LTR-RTs full domains. For more details, please see TEsorter (https://github.com/zhangrengang/TEsorter)


In your terminal window, run (You may change the folder names and files names for convenience):
```sh
cd $HOME/TEs
cd Athaliana
mkdir TREE
cd TREE
ln -s ../At.fasta.mod.EDTA.TElib.fa .
ln -s $HOME/$TEs/Rscripts/LTR_tree.R .
#
/usr/local/bin/TEsorter -db rexdb-plant --hmm-database rexdb-plant -pre TE -dp2 -p 22 At.fasta.mod.EDTA.TElib.fa
concatenate_domains.py TE.cls.pep GAG PROT RH RT INT > GAG_PROT_RH_RT_INT.aln
iqtree2 -s GAG_PROT_RH_RT_INT.aln -alrt 1000 -bb 1000 -nt AUTO -m JTTDCMut+F+R5
#
Rscript LTR_tree.R GAG_PROT_RH_RT_INT.aln.contree TE.cls.tsv LTR_RT-Tree.pdf
```

![image](https://user-images.githubusercontent.com/3044067/200052059-180a3d81-7426-469b-a130-b52ecd661866.png)








## List of genomes tested in this pipeline

* Chromosome scale genomes:

*Arabidopsis thaliana* - Size: 115Mb

*Theobroma cacao* Criollo - Size: 330Mb

*Theobroma cacao* Matina - Size: 340Mb 

*Theobroma grandiflorum* C174 clone - Size: 415Mb

*Theobroma grandiflorum* C1074 clone - Size: 415Mb

*Theobroma grandiflorum* C174 clone - phased assembly - Size: 850Mb

*Theobroma grandiflorum* C1074 clone - phased assembly - Size: 850Mb

*Banisteriopsis caapi* Size: 1.2Gb



* Draft genomes:

*Passiflora organensis*  Size:250Mb



## References

Ou S, Su W, Liao Y, Chougule K, Agda JRA, Hellinga AJ, Lugo CSB, Elliott TA, Ware D, Peterson T, Jiang N, Hirsch CN, Hufford MB. 
*Benchmarking transposable element annotation methods for creation of a streamlined, comprehensive pipeline.*
**Genome Biol.** 2019 Dec 16;20(1):275. 
[PMID: 31843001](https://pubmed.ncbi.nlm.nih.gov/31843001/)

Zhang RG, Li GY, Wang XL, Dainat J, Wang ZX, Ou S, Ma Y. 
*TEsorter: an accurate and fast method to classify LTR-retrotransposons in plant genomes.*
**Hortic Res.** 2022 Feb 19;9:uhac017. 
[PMID: 35184178](https://pubmed.ncbi.nlm.nih.gov/35184178/)

Rho M, Tang H. 
*MGEScan-non-LTR: computational identification and classification of autonomous non-LTR retrotransposons in eukaryotic genomes.*
**Nucleic Acids Res.** 2009 Nov;37(21):e143. 
[PMID: 19762481](https://pubmed.ncbi.nlm.nih.gov/19762481/)

Li Y, Jiang N, Sun Y. 
*AnnoSINE: a short interspersed nuclear elements annotation tool for plant genomes.*
**Plant Physiol.** 2022 Feb 4;188(2):955-970. 
[PMID: 34792587](https://pubmed.ncbi.nlm.nih.gov/34792587/)

Orozco-Arias S, Isaza G, Guyot R. 
*Retrotransposons in Plant Genomes: Structure, Identification, and Classification through Bioinformatics and Machine Learning.*
**Int J Mol Sci.** 2019 Aug 6;20(15):3837. 
[PMID: 31390781](https://pubmed.ncbi.nlm.nih.gov/31390781/)

Orozco-Arias S, Jaimes PA, Candamil MS, Jiménez-Varón CF, Tabares-Soto R, Isaza G, Guyot R. 
*InpactorDB: A Classified Lineage-Level Plant LTR Retrotransposon Reference Library for Free-Alignment Methods Based on Machine Learning.*
**Genes (Basel).** 2021 Jan 28;12(2):190. 
[PMID: 33525408](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7910972/)

Argout X, Martin G, Droc G, Fouet O, Labadie K, Rivals E, Aury JM, Lanaud C. 
*The cacao Criollo genome v2.0: an improved version of the genome for genetic and functional genomic studies.*
**BMC Genomics.** 2017 Sep 15;18(1):730.
[PMID: 28915793](https://pubmed.ncbi.nlm.nih.gov/28915793/)

Costa ZP, Varani AM, Cauz-Santos LA, Sader MA, Giopatto HA, Zirpoli B, Callot C, Cauet S, Marande W, Souza Cardoso JL, Pinheiro DG, Kitajima JP, Dornelas MC, Harand AP, Berges H, Monteiro-Vitorello CB, Carneiro Vieira ML. 
*A genome sequence resource for the genus Passiflora, the genome of the wild diploid species Passiflora organensis.*
**Plant Genome.** 2021 Nov;14(3):e20117. 
[PMID: 34296827](https://pubmed.ncbi.nlm.nih.gov/34296827/)

Swarbreck D, Wilks C, Lamesch P, Berardini TZ, Garcia-Hernandez M, Foerster H, Li D, Meyer T, Muller R, Ploetz L, Radenbaugh A, Singh S, Swing V, Tissier C, Zhang P, Huala E. 
*The Arabidopsis Information Resource (TAIR): gene structure and function annotation.*
**Nucleic Acids Res.** 2008 Jan;36(Database issue):D1009-14. 
[PMID: 17986450](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2238962/)

Musacchio A, Desai A. 
*A Molecular View of Kinetochore Assembly and Function.*
**Biology (Basel).** 2017 Jan 24;6(1):5. 
[PMID: 28125021](https://pubmed.ncbi.nlm.nih.gov/28125021/)

Melters DP, Bradnam KR, Young HA, Telis N, May MR, Ruby JG, Sebra R, Peluso P, Eid J, Rank D, Garcia JF, DeRisi JL, Smith T, Tobias C, Ross-Ibarra J, Korf I, Chan SW. 
*Comparative analysis of tandem repeats from hundreds of species reveals unique insights into centromere evolution.*
**Genome Biol.**  2013 Jan 30;14(1):R10. 
[PMID: 23363705](https://pubmed.ncbi.nlm.nih.gov/23363705/)



## Author

* Alessandro Varani
* Web: https://www.fcav.unesp.br/genomics
* 11/2022

