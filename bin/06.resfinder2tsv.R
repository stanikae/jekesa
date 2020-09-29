#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


library(tidyverse)
library("openxlsx")

args <- commandArgs(TRUE)

# define path to tsv files
indir = file.path(args[1])
dir_vec <- list.dirs(indir, recursive = T)
dir_vec
if (str_detect(dir_vec,"TSVs")){
   # combine tsvs in one data frame
   tbl <- list.files(path = indir,pattern = "*.tsv", full.names = T) %>% 
       map_df(~read_delim(., delim = "\t"))
}else{
  tbl <- list.files(path = indir,pattern = "*.csv", full.names = T) %>%
  map_df(~read_delim(., delim = ","))
}

# write tsvs to one tsv file
#write_delim(tbl,args[2],delim = "\t")
# write tsv to .xlsx
write.xlsx(tbl, args[2], overwrite=T)

