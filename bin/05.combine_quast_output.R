#!/usr/bin/env Rscript

#.libPaths("~/repos/jekesa/lib/Rlib")
library(plyr)
library(tidyverse)
#library(plyr)
library(tidyr)
library(dplyr)
library(purrr)
library(openxlsx)
library(stringr)

args <- commandArgs(TRUE)
print(args[1])

getwd()

# list directory names in the quast output folder
samples <- list.dirs(args[1], full.names = F,recursive = F)
# only get those directories that are either from a contig or a scaffold
filter_samples <- str_detect(list.dirs(args[1], full.names = F,recursive = F), "scaffolds|assembly")
#filter_samples <- str_detect(list.dirs(".", full.names = F,recursive = F), 
 #                            paste(c('scaffold', 'contig'), collapse="|"))
# filter list of directories to remain with only those containing quast output for each genome assembly
samples <- samples[filter_samples]

samples_list <- list()
for (i in samples){
  #print(i)
  contig_stats <- read_table(paste(args[1], paste0(i,"/report.txt"), sep = "/"), skip = 2, col_names = T)
  if(file.exists(paste(args[1], paste0(i,"/reads_stats/reads_report.txt"), sep ="/"))){
	read_stats <- read_table(paste(args[1], paste0(i,"/reads_stats/reads_report.txt"), sep ="/"), skip = 2, col_names = T)
  	complete_stats <- rbind(contig_stats, read_stats)
  	nrow(complete_stats)
  } else {
	complete_stats <- contig_stats
	nrow(complete_stats)
  }
  samples_list[[i]] <- as.data.frame(dplyr::distinct(complete_stats, Assembly, .keep_all = TRUE))
  
}

glimpse(samples_list)

# merge multiple tables into one
joined_table <- samples_list %>% reduce(left_join, by = "Assembly")

# get unique rows
joined_table <- unique(joined_table)

# write combined table to file
#create excel workbook to load results
desRes <- openxlsx::createWorkbook()
openxlsx::addWorksheet(desRes, "QUAST")
openxlsx::writeData(desRes, "QUAST", joined_table)
# Save workbook as assembly_metrics.xlsx
openxlsx::saveWorkbook(desRes,args[2], overwrite = T)

