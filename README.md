# JEKESA
An automated bacterial whole genome assembly and typing pipeline which primarily uses Illumina paired-end sequencing data.

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

#### _Streptococcus pneumoniae_ specific analysis
- [seroba](https://github.com/sanger-pathogens/seroba)
- Pili detection
- [PBP gene typing scripts and database adapted from the CDC Streptococcus Lab](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference)

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
                (default='spades')
        -s      Species scheme name to use for mlst typing.
                This option is required for streptococcus pneumoniae in order to allow detailed analysis. Use: 'spneumoniae'.
                To check other available schema names use: mlst --longList. Otherwise if you don't know your schema use: 'noScheme'.
        -t      Number of threads to use <integer>, (minimum value should be: 6)
        -h      Show this help
        -v      Show version
        
````
## Installation
