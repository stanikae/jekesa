# JEKESA
An automated bacterial whole genome assembly and typing pipeline which primarily uses Illumina paired-end whole genome sequencing (WGS) data. In addition, Jekesa performs extensive analyses for _Escherichia coli_, Salmonella, _Streptococcus pneumoniae_ and _Streptococcus pyogenes_ (Group A Streptococcus), including in-depth virulence predicitions for various other pathogens (refer to sections below). Furthermore, Jekesa, also performs whole-genome reference-free alignments, pairwise SNP-site analysis and clustering, and generates a neighbor-joining tree which can be easily visualized using e.g. [Microreact](https://microreact.org/showcase).

## Pipeline overview
Jekesa (Illuminate) currently runs on a server (single compute node). The pipeline is written in Bash, R, and Rmarkdown, and generates the results report in an excel worksheet (.xlsx format) and html format.

#### _De novo_ genome assembly and classification
* QC and read filtering using [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and [trim_galore](https://github.com/FelixKrueger/TrimGalore).
* Species identification and closest reference detection using [Bactinspector](https://gitlab.com/antunderwood/bactinspector). 
* Check for contamination using [ConFindr](https://github.com/OLC-Bioinformatics/ConFindr), [kraken2](https://ccb.jhu.edu/software/kraken2/index.shtml) and [MiniKraken2_v2_8GB](https://ccb.jhu.edu/software/kraken2/index.shtml?t=downloads)
* De novo assembly using either [SKESA](https://github.com/ncbi/SKESA), [SPAdes](http://cab.spbu.ru/software/spades/), [MEGAHIT](https://github.com/voutcn/megahit), or [velvet](https://github.com/dzerbino/velvet) as implemented in [Shovill](https://github.com/tseemann/shovill).
* Generation of assembly metrics using [QUAST](http://quast.sourceforge.net/quast)

#### MLST typing
* Multi-locus sequence typing based on assembled contigs using [mlst](https://github.com/tseemann/mlst) and PubMLST database.

#### Resistance profiling
- Detection of acquired AMR genes and chromosomal mutations and their associated resistance phenotypes performed using [resfinder](https://bitbucket.org/genomicepidemiology/resfinder/src/master/), [AMRFinderPlus](https://github.com/ncbi/amr/wiki/Running-AMRFinderPlus) and [pointfinder](https://bitbucket.org/genomicepidemiology/pointfinder_db/src/master/). 
- Optionally, known and novel variants in anti-microbial resistance genes, predicted from clean reads using [ariba](https://github.com/sanger-pathogens/ariba) and either [CARD](https://card.mcmaster.ca/) (The Comprehensive Antibiotic Resistance Database) or [resfinder database](https://bitbucket.org/genomicepidemiology/resfinder_db/src/master/).

#### Virulence gene predicition
- Virulence genes detected using [AMRFinderPlus](https://github.com/ncbi/amr/wiki/Running-AMRFinderPlus). 
- In addition, in-depth virulence gene detection for specific pathogens such as *E. coli, E. faecalis, E. faecium, S aureus and L. monocytogenes* is performed using [VirulenceFinder](https://bitbucket.org/genomicepidemiology/virulencefinder/src/master/).
- Optionally, detection of variants (known/novel) in virulence factor genes, from cleaned reads, using [ariba](https://github.com/sanger-pathogens/ariba) and the [VFDB](http://www.mgc.ac.cn/VFs/). *ARIBA can be activated by uncommenting the ARIBA specific scripts in the main JEKESA script.*

#### Plasmid detection
- Coming soon

#### _Escherichia coli_ specific analysis
- Serotyping using [SerotypeFinder](https://bitbucket.org/genomicepidemiology/serotypefinder/src/master/).

#### _Salmonella enterica_ specific analysis
- Serotyping using both [SISTR](https://github.com/phac-nml/sistr_cmd) and [SeqSero2](https://github.com/denglab/SeqSero2).

#### _Streptococcus pneumoniae_ specific analysis
- Serotyping using [seroba](https://github.com/sanger-pathogens/seroba)
- Pili detection based on reference sequences used in [Nakano et. al, 2018](https://wwwnc.cdc.gov/eid/article/24/2/17-1268-techapp1.pdf)
- PBP gene typing and MIC profiling using [CDC Streptococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) SPN scripts and sequence databases.
- Calculate core and accessory distances and cluster genomes (assigning global pneumococcal sequence clusters; GPSCs) using [PopPUNK](https://github.com/johnlees/PopPUNK), as well as assign new genomes to clusters.

#### _Streptococcus pyogenes_ specific analysis
- EMM typing and MIC profiling using [CDC Stretococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) GAS scripts and sequence databases.
- Calculate core and accessory distances and cluster/define genomes/strains using [PopPUNK](https://github.com/johnlees/PopPUNK), as well as assign new genomes to clusters.

#### Reference-free alignments, pairwise SNP differences, and neighbor-joining tree construction
- Reference free alignments performed using [SKA](https://github.com/simonrharris/SKA). In addition, SKA distance is used to calculate pairiwise SNP differences between samples and assign SNP-based clusters.
- The generated variant alignments are used to generate a neighbor-joining tree using [rapidNJ](https://birc.au.dk/software/rapidnj/) with 1000 bootstrap replicates.

#### Output and reporting
All results will be strored in `Results-ProjectName` including:
* The final report named `ProjectName-WGS-typing-report.xlsx`
* Results from each step of the analysis in .xlsx format
* Neighbor joining tree file (and associated files) generated using [PopPUNK](https://github.com/johnlees/PopPUNK).
* Subfolders contatining:
  * assembled-contigs
  * additional results from [SKA](https://github.com/simonrharris/SKA).
  * additional reports from ARIBA, including files for generating trees showing clustering of samples based on detected variants
  * [MultiQC](https://github.com/ewels/MultiQC) reports for visualization of quality control reports, pre- and post- filtering of sequence reads.
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
        -c      Path to assembled contigs to include in the typing analysis (only mlst and resistance profiling).
        -h      Show this help
        -v      Show version

````
#### Example
````
cd jekesa
#This script will create analysis directory and soft link fastq files
bin/find-link-fastq.sh  path/to/analysis/directory path/to/sampleID/list  path/to/raw/fastqfiles 

# Now run the jekesa pipeline
conda activate jekesa
jekesa -p path/to/analysis/directory -a skesa -s spyogenes -t 16 &
````
## Installation
````
Clone the git repository:
git clone https://github.com/stanikae/jekesa.git
cd jekesa
````
After cloning the jekesa git repo, do the following to install the required dependencies and to setup the conda environment:
````
# JEKESA
wget -P lib https://anaconda.org/stanikae/jekesa/2021.01.15.141403/download/jekesa_v1.0.yml
conda env create -n jekesa --file ./lib/jekesa_v1.0.yml
````
### Installation of dependancies
#### 1. R packages
````
wget -P lib https://anaconda.org/stanikae/r_env/2021.01.15.141706/download/jekesa-v1.0_r_env.yml
conda env create -n r_env --file ./lib/jekesa-v1.0_r_env.yml
````
#### 2. [CGE tools](https://cge.cbs.dtu.dk/services/)
````
## ResFinder4 
wget -P lib https://anaconda.org/stanikae/resfinder/2021.06.18.105709/download/jekesa-v1.0_cge.yml
conda env create -n resfinder --file ./lib/jekesa-v1.0_cge.yml

## Other CGE tools
wget -P lib https://anaconda.org/stanikae/cge/2021.06.18.111232/download/jekesa-v1.0_resfinder4.yml
conda env create -n cge --file ./lib/jekesa-v1.0_resfinder4.yml
````
#### 3. srst2 env (For CDC StrepLab scripts)
````
wget -P lib https://anaconda.org/stanikae/srst2/2021.01.21.121312/download/jekesa-v1.0_srst2.yml
conda env create -n srst2 --file .lib/jekesa-v1.0_srst2.yml
conda activate srst2
pip install spn_scripts/srst2/
conda deactivate
````

````
## Activate jekesa
conda activate jekesa 
````

### If you already have jekesa installed, you can upgrade as follows:
`````
cd jekesa
git pull
wget -P lib https://anaconda.org/stanikae/jekesa/2021.01.15.141403/download/jekesa_v1.0.yml
conda env update -n jekesa --file ./lib/jekesa_v1.0.yml --prune
`````
#### Setting up required databases
To download and set-up required databases, execute the `00.download_databases.sh` script
`````
cd jekesa
conda activate jekesa
bash bin/00.download_databases.sh /path/to/installation/directory
`````
##### ConFindr databases
To set up ConFindr databases kindly follow instructions here: `https://olc-bioinformatics.github.io/ConFindr/install/` as this requires registration on PubMLST.

#### To deactivate jekesa (At the end of the analysis)
`````
conda deactivate jekesa
`````
## Author
Stanford Kwenda

## License
[GPL 3.0](https://github.com/stanikae/jekesa/blob/master/LICENSE)
## Citation
Kwenda S., Allam M., Khumalo Z.T.H., Mtshali S., Mnyameni F., Ismail A. _Jekesa: an automated easy-to-use pipeline for bacterial whole genome typing_ **Github** [https://github.com/stanikae/jekesa](https://github.com/stanikae/jekesa)

