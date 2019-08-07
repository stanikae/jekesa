**JEKESA**
***
An automated bacterial whole genome assembly and typing pipeline which primarily uses Illumina paired-end sequencing data.

***
**Usage**
***

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
