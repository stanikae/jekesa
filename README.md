# JEKESA
An automated bacterial whole genome assembly and typing pipeline which primarily uses Illumina paired-end whole genome sequencing (WGS) data. In addition, Jekesa performs extensive analyses for _Streptococcus pneumoniae_ and _Streptococcus pyogenes_ (Group A Streptococcus) using some of the [CDC Streptococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) scripts for PBP and EMM typing; as well as MIC (minimum inhibitory concentration) profiling. Furthermore, Jekesa, also performs in-depth analysis for salmonella, including antigen detection, serotyping, and assignment of subspecies groups based on cgMLST profiles

## Required tools/dependencies
Jekesa (Illuminate) currently runs on a server (single compute node), and the folowing tools have to be installed or available in your path prior to running it. The pipeline is written in Bash and R, and generates the results report in an excel worksheet (.xlsx format) and html format.

#### _De novo_ genome assembly and classification
* QC and read filtering using [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and [trim_galore](https://github.com/FelixKrueger/TrimGalore).
* Species identification and closest reference detection using [Bactinspector](https://gitlab.com/antunderwood/bactinspector). 
* Check for contamination using [ConFindr](https://github.com/OLC-Bioinformatics/ConFindr), [kraken2](https://ccb.jhu.edu/software/kraken2/index.shtml) and [MiniKraken2_v2_8GB](https://ccb.jhu.edu/software/kraken2/index.shtml?t=downloads)
* De novo assembly using either [SKESA](https://github.com/ncbi/SKESA), [SPAdes](http://cab.spbu.ru/software/spades/), [MEGAHIT](https://github.com/voutcn/megahit), or [velvet](https://github.com/dzerbino/velvet) as implemented in [Shovill](https://github.com/tseemann/shovill).
* Generation of assembly metrics using [QUAST](http://quast.sourceforge.net/quast)

#### MLST typing
* Multi-locus sequence typing based on assembled contigs using [mlst](https://github.com/tseemann/mlst) and PubMLST database.

#### Resistance profiling
- Both known and novel variants in anti-microbial resistance genes, predicted from clean reads using [ariba](https://github.com/sanger-pathogens/ariba) and either [CARD](https://card.mcmaster.ca/) (The Comprehensive Antibiotic Resistance Database) or [resfinder database](https://bitbucket.org/genomicepidemiology/resfinder_db/src/master/).
- Additional resistance profiling using [resfinder]() and [pointfinder]() to determine chromosomal mutations and acquired AMR genes, and their associated resistance phenotypes.

#### Virulence gene predicition
- Detection of variants (known/novel) in virulence factor genes, from cleaned reads, using [ariba](https://github.com/sanger-pathogens/ariba) and the [VFDB](http://www.mgc.ac.cn/VFs/).

#### Plasmid detection
- Coming soon

#### _Streptococcus pneumoniae_ specific analysis
- Serotyping using [seroba](https://github.com/sanger-pathogens/seroba)
- Pili detection based on reference sequences used in [Nakano et. al, 2018](https://wwwnc.cdc.gov/eid/article/24/2/17-1268-techapp1.pdf)
- PBP gene typing and MIC profiling using [CDC Streptococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) SPN scripts and sequence databases.
- Calculate core and accessory distances and cluster genomes (assigning global pneumococcal sequence clusters; GPSCs) using [PopPUNK](https://github.com/johnlees/PopPUNK), as well as assign new genomes to clusters.

#### _Streptococcus pyogenes_ specific analysis
- EMM typing and MIC profiling using [CDC Stretococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) GAS scripts and sequence databases.
- Calculate core and accessory distances and cluster/define genomes/strains using [PopPUNK](https://github.com/johnlees/PopPUNK), as well as assign new genomes to clusters.

#### _Salmonella enterica_ specific analysis
- Serotyping using both [SISTR](https://github.com/phac-nml/sistr_cmd) and [SeqSero2](https://github.com/denglab/SeqSero2).

#### Output and reporting
All results will be strored in `Results-ProjectName` including:
* The final report named `ProjectName-WGS-typing-report.xlsx`
* Results from each step of the analysis in .xlsx format
* Neighbor joining tree file (and associated files) generated using [PopPUNK](https://github.com/johnlees/PopPUNK).
* Subfolders contatining:
- assembled-contigsa
- additional reports from ARIBA, including files for generating trees showing clustering of samples based on detected variants
- [MultiQC](https://github.com/ewels/MultiQC) reports for visualization of quality control reports, pre- and post- filtering of sequence reads.
* Detailed HTML report generated using `rmarkdown`


## Usage
```
usage: jekesa <options>

OPTIONS:
        -p      Path to output directory or project name
        -a      Select the assembler to use. Options available: 'spades', 'skesa', 'velvet', 'megahit'
        -s      Species scheme name to use for mlst typing.
                Use: 'spneumoniae' or 'spyogenes' or 'senterica', for streptococcus pneumoniae or streptococcus pyogenes or salmonella
                detailed analysis. Otherwise for any other schema use: 'other'. To check other available schema names use: mlst --longList.
        -t      Number of threads to use <integer>, (minimum value should be: 6)
        -g      Only perform de novo assembly
        -h      Show this help
        -v      Show version

````
#### Example
````
cd jekesa
#This script will create analysis directory and soft link fastq files
bin/find-link-fastq.sh  path/to/analysis/directory path/to/sampleID/list  path/to/raw/fastqfiles 

# Now run the jekesa pipeline
jekesa -p path/to/analysis/directory -a skesa -s spyogenes -t 16 &
````
## Installation

````
Clone the git repository:
git clone https://github.com/stanikae/jekesa.git
````
After cloning the jekesa git repo, do the following to install the required dependencies and to setup the conda environment:
`````
cd jekesa
conda env create -n jekesa --file ./lib/jekesa.yml
`````
To activate JEKESA environment run:
`````
conda activate jekesa 
`````
If you already have jekesa installed, you can upgrade as follows:
`````
cd jekesa
git pull
conda env update -n jekesa --file ./lib/jekesa.yml --prune
`````
#### Setting up required databases
##### ARIBA database set-up

`````
# 1. First re-install cd-hit and change the max_seq size
cd /opt # or any of your preferred location
git clone https://github.com/weizhongli/cdhit.git
cd cdhit
make MAX_SEQ=10000000
export PATH="/opt/cdhit:$PATH"

# 2. Download and set-up the CARD database
# version ...  of CARD is already prepared and provided in jekesa/dbs/ariba_DBs
# only perform the following steps if you need a more recent CARD database
cd db/ariba_DBs
ariba getref card out.card
ariba prepareref -f out.card.fa -m out.card.tsv out.card.prepareref
`````
##### SEROBA database set-up
`````
# Clone the git repository:
cd /opt # or any of your preferred location
git clone https://github.com/sanger-pathogens/seroba.git
cp -r /opt/seroba/database jekesa/db/seroba_db
seroba createDBs jekesa/db/seroba_db/ 71
`````
##### Minikraken_DB download and set-up
`````
mkdir -p $HOME/minikraken_db # choose most appropriate location for your system
wget -c -P $HOME/minikraken_db/ ftp://ftp.ccb.jhu.edu/pub/data/kraken2_dbs/minikraken2_v2_8GB_201904_UPDATE.tgz
cd $HOME/minikraken_db
tar xzvf minikraken_db/minikraken2_v2_8GB_201904_UPDATE.tgz
rm $HOME/minikraken_db/minikraken2_v2_8GB_201904_UPDATE.tgz
ln -s $HOME/minikraken_db/minikraken2_v2_8GB_201904_UPDATE jekesa/db/kraken_db
`````
##### PopPUNK database set-up for S. pneumoniae and S. pyogenes
`````
mkdir -p $HOME/poppunk_db # choose most appropriate location for your system
wget -c -P $HOME/poppunk_db https://www.pneumogen.net/gps/GPS_query.tar.bz2
wget -c -P $HOME/poppunk_db https://www.pneumogen.net/gps/gpsc_definitive.csv
wget -c -P $HOME/poppunk_db https://s3-eu-west-1.amazonaws.com/pfigshare-u-files/17424146/GAS_query_v2.tar.bz2
cd $HOME/poppunk_db
tar -jxf GAS_query_v2.tar.bz2
tar -jxf GPS_query.tar.bz2
ln -s $HOME/poppunk_db jekesa/db/kraken_db
`````
##### ConFindr databases
To set up ConFindr databases kindly follow instructions here: `https://olc-bioinformatics.github.io/ConFindr/install/` as this requires registration on PubMLST.

#### Setting-up environment for srst2 and its dependencies

`````
cd jekesa
conda env create -n srst2 --file ./lib/srst2.yml
`````
#### Setting-up R environment and the required libraries

`````
cd jekesa
conda env create -n r_env --file ./lib/r_env.yml
`````
#### Setting-up environment for resfinder and pointfinder and their dependencies
`````
cd jekesa
conda env create -n resfinder --file ./lib/resfinder.yml
`````
#### To deactivate jekesa (At the end of the analysis)
`````
conda deactivate jekesa
`````
## Author
Stanford Kwenda

## License
[GPL 3.0](https://github.com/stanikae/jekesa/blob/master/LICENSE)
## Citation
Kwenda S., Allam M., Khumalo Z.T.H., Mtshali S., Mnyameni F., Ismail A. _Jekesa_ **Github** [https://github.com/stanikae/jekesa](https://github.com/stanikae/jekesa)

