#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


library(tidyverse)
library("openxlsx")

args <- commandArgs(TRUE)

# define path to tsv files
indir = file.path(args[1])
# combine tsvs in one data frame
tbl <- list.files(path = indir,pattern = "*.tsv", full.names = T) %>% 
       map_df(~read_delim(., delim = "\t"))
# write tsvs to one tsv file
write.xlsx(tbl, args[2], overwrite=T)

