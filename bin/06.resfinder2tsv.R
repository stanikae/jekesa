#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


library("tidyverse")
library("openxlsx")

args <- commandArgs(TRUE)

# define path to tsv files
indir = file.path(args[1])
# combine tsvs in one data frame
#tbl <- list.files(path = indir,pattern = "*.tsv", full.names = T) %>% 
#       map_df(~read_delim(., delim = "\t"))

all_tsv <- lapply(list.files(path = indir,pattern = "*.tsv", full.names = T), 
             read_delim, delim="\t")
tbl <- do.call("rbind", all_tsv)
# write tsvs to one tsv file
#write_delim(tbl,args[2],delim = "\t")
# write tsv to .xlsx
write.xlsx(tbl, args[2], overwrite=T)

