# JEKESA
An automated bacterial whole genome assembly and typing pipeline which primarily uses Illumina paired-end sequencing data. In addition, Jekesa performs extensive analyses for Streptococcus pneumoniae and Streptococcus pyogenes (Group A Streptococcus) using some of the [CDC Streptococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) scripts for PBP and EMM typing; as well as MIC (minimum inhibitory concentration) profiling.

## Required tools/dependencies
Jekesa (Illuminate) currently runs on a server (single compute node), and the folowing tools have to be installed or available in your path prior to running it. The pipeline is written in Bash and R, and generates the results report in an excel worksheet (.xlsx format).

#### _De novo_ genome assembly and classification
* [trim_galore]()
* [spades](http://cab.spbu.ru/software/spades/)
* [skesa](https://github.com/ncbi/SKESA)
* [kraken](https://github.com/DerrickWood/kraken)
* [MiniKraken DB_8GB](https://ccb.jhu.edu/software/kraken/)

#### MLST typing
* [mlst](https://github.com/tseemann/mlst)

#### Resistance profiling
- [ariba](https://github.com/sanger-pathogens/ariba)
- [CARD](https://card.mcmaster.ca/) (The Comprehensive Antibiotic Resistance Database)

#### _Streptococcus pneumoniae_ specific analysis
- [seroba](https://github.com/sanger-pathogens/seroba)
- Pili detection
- [CDC Streptococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) PBP gene typing scripts and databases

#### _Streptococcus pyogenes_ specific analysis
- [CDC Stretococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) EMM typing and MIC profiling scripts and databases

#### Visualization and reporting
* [QUAST](http://quast.sourceforge.net/quast)
* [MultiQC](https://github.com/ewels/MultiQC)
* R
* Rscript

## Usage
```
usage: jekesa [options]

OPTIONS:
        -p      Path to output directory or project name
        -f      Path to file with list of sample IDs (one ID per line)
        -a      Select the assembler to use. Options available: 'spades', 'skesa'
        -s      Species scheme name to use for mlst typing.
                Use: 'spneumoniae' or 'spyogenes', for streptococcus pneumoniae or  streptococcus pyogenes detailed analysis. 
                Otherwise for any other schema use: 'other'. To check other available schema names use: mlst --longList. 
        -t      Number of threads to use <integer>, (minimum value should be: 6)
        -h      Show this help
        -v      Show version
        
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
#### Setting up required databases
`````
## ARIBA database set-up
# 1. First install cd-hit and change the max_seq size
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

## SEROBA database set-up
# 1. Clone the git repository:
cd /opt # or any of your preferred location
git clone https://github.com/sanger-pathogens/seroba.git
cp -r /opt/seroba/database jekesa/db/seroba_db
seroba createDBs jekesa/db/seroba_db/ 71

## Minikraken_DB download and set-up
mkdir -p $HOME/minikraken_db # choose most appropriate location for your system
wget -c -P $HOME/minikraken_db/ https://ccb.jhu.edu/software/kraken/dl/minikraken_20171019_8GB.tgz
cd $HOME/minikraken_db
tar xzvf minikraken_db/minikraken_20171019_8GB.tgz
rm $HOME/minikraken_db/minikraken_20171019_8GB.tgz
ln -s $HOME/minikraken_db/minikraken_20171019_8GB jekesa/db/kraken_db
`````
#### Setting-up environment for srst2 and its dependencies

`````
cd jekesa
conda env create -n srst2 --file ./lib/srst2.yml
`````
