#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


#.libPaths("~/repos/jekesa/lib/Rlib")

library(plyr)
library(tidyverse)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)
library(openxlsx)
library(readxl)

# get input using arguments
args <- commandArgs(TRUE)

dir <- file.path(args[1])
#print(dir)
file1 <- read_excel(paste(dir,args[2], sep = "/"), col_names = TRUE)
file2 <- read_excel(paste(dir, args[3], sep = "/"), col_names = TRUE)

file1$AMRGenes <- rep("AMR", nrow(file1))
file2$VFGenes <- rep("VFs", nrow(file1))

file1 <- file1 %>% dplyr::select(name,AMRGenes, everything())
file2 <- file2 %>% dplyr::select(name,VFGenes, everything())

cmd_df <- dplyr::full_join(file1, file2, by='name')


# write results to xlsx file
openxlsx::write.xlsx(cmd_df, paste(dir, args[4], sep = "/"), overwrite = T)


