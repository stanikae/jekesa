#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)

#options(java.parameters = "-Xmx1024m")
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
#list.dirs(args)

#samples <- list.dirs(args, full.names = F,recursive = F)
#samples

# only get those directories that are either from a contig or a scaffold
#filter_samples <- str_detect(list.dirs(args, full.names = F,recursive = F), 'scaffolds')
# filter list of directories to remain with only those containing quast output for each genome assembly
#samples <- samples[filter_samples]
#samples

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
  #samples_list[[i]] <- as.data.frame(unique(complete_stats))
  #samples_list[[i]] %>% dplyr::distinct(Assembly, .keep_all = TRUE)
  samples_list[[i]] <- as.data.frame(dplyr::distinct(complete_stats, Assembly, .keep_all = TRUE))
  #samples_list[[i]] <- as.data.frame(samples_list[[i]])
  
}

glimpse(samples_list)

# merge multiple tables into one
joined_table <- samples_list %>% reduce(left_join, by = "Assembly")
#joined_table <- unique(joined_table, fromLast = T)
#glimpse(joined_table)
#tail(joined_table)
#nrow(joined_table)

# get unique rows
joined_table <- unique(joined_table)

# write combined table to file
#create excel workbook to load results
#deRes <- XLConnect::loadWorkbook("assembly_metrics.xlsx", create = T)
#deRes <- XLConnect::loadWorkbook(args[2], create = T)
#XLConnect::createSheet(deRes, name = "QUAST")#c("LVL_vs_VC","LVL_vs_HVL", "VC_vs_HVL"))
#XLConnect::writeWorksheet(deRes, joined_table, "QUAST")
# Save workbook as assembly_metrics.xlsx
#XLConnect::saveWorkbook(deRes, "assembly_metrics.xlsx")
#XLConnect::saveWorkbook(deRes, args[2])

# write combined table to file
#create excel workbook to load results
desRes <- openxlsx::createWorkbook()
openxlsx::addWorksheet(desRes, "QUAST")
openxlsx::writeData(desRes, "QUAST", joined_table)
# Save workbook as assembly_metrics.xlsx
openxlsx::saveWorkbook(desRes,args[2], overwrite = T)

