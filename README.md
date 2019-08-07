# JEKESA
An automated bacterial whole genome assembly and typing pipeline which primarily uses Illumina paired-end sequencing data.

## Required tools/dependencies
Jekesa (Illuminate) currently runs on a server (single compute node), and the folowing tools have to be installed or in your path prior to running it. The pipeline is written in Bash and R, and is still under development.

#### _De novo_ genome assembly and classification
* spades
* skesa
* kraken
* minikraken database

#### MLST typing
* mlst

#### Resistance profiling
- ariba
- seroba

#### Visualization and reporting
* quast
* multiQC
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
