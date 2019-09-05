#!/bin/bash

#lib=${BASH_SOURCE%/*}
rlib="./lib/Rlib"
if ! [ -d "$rlib" ]; then
 mkdir -p "$rlib"
fi

Rscript -e 'install.packages("plyr", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("openxlsx", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("tidyverse", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("purrr", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("stringr", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("readxl", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'

# SPN typing packages
Rscript -e 'install.packages("methods", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("randomForest", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("iterators", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("foreach", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("glmnet", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'install.packages("Biostrings", lib="./lib/Rlib", repos="https://cloud.r-project.org/")'
Rscript -e 'if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager", lib="./lib/Rlib")'
Rscript -e '.libPaths("lib/Rlib"); BiocManager::install("Biostrings", lib="./lib/Rlib")'
Rscript -e '.libPaths("lib/Rlib"); BiocManager::install("randomForest", lib="./lib/Rlib")'
#export PATH="${BASH_SOURCE%/*}:$PATH"
