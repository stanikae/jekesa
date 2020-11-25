#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


library("tidyverse")
library("openxlsx")

args <- commandArgs(TRUE)

# define path to tsv files
indir = file.path(args[1])
dir_vec <- list.dirs(indir, recursive = T)
dir_vec
if (str_detect(dir_vec,"TSVs")){
   # combine tsvs in one data frame
   tbl <- list.files(path = indir,pattern = "*.tsv", full.names = T) %>% 
       map_df(~read_delim(., delim = "\t", col_types = cols(.default = "c")))
}else{
  tbl <- list.files(path = indir,pattern = "*.csv", full.names = T) %>%
  map_df(~read_delim(., delim = ",", col_types = cols(.default = "c")))
}

# replace NAs with "No hit found"
tbl_logic_vec <- as.data.frame(sapply(tbl, is.na))
for(nm in names(tbl)){
  tbl[[nm]][tbl_logic_vec[[nm]]] = "No hit found"
}

# combine tsvs in one data frame
#tbl <- list.files(path = indir,pattern = "*.tsv", full.names = T) %>% 
#       map_df(~read_delim(., delim = "\t"))
#
#all_tsv <- lapply(list.files(path = indir,pattern = "*.tsv", full.names = T), 
#             read_delim, delim="\t")
#tbl <- do.call("rbind", all_tsv)
# write tsvs to one tsv file
#write_delim(tbl,args[2],delim = "\t")
# write tsv to .xlsx
write.xlsx(tbl, args[2], overwrite=T)

