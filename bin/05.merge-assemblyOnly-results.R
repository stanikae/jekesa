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

######################
# get input using arguments
args <- commandArgs(TRUE)

#getwd()
dir <- file.path(args[1])
#print(dir)

countReads <- read_excel(paste(dir,"03.countReads.xlsx", sep = "/"), col_names = TRUE)
covDepth <- read_excel(paste(dir,"03.coverageDepth.xlsx", sep = "/"), col_names = TRUE)
bactIns <- read_excel(paste(dir,"04.bactInspector.xlsx", sep = "/"), col_names = TRUE)
conFin <- read_excel(paste(dir,"04.confindr.xlsx", sep = "/"), col_names = TRUE)
kraken <- read_excel(paste(dir, "04.kraken.xlsx", sep = "/"), col_names = TRUE)
metrics <- read_excel(paste(dir,"05.quast.xlsx", sep = "/"), col_names = TRUE)
mlst <- read_excel(paste(dir, "05.mlst.xlsx", sep = "/"), col_names = TRUE)

############# filter quast results ####################################
metrics1 <- metrics %>% dplyr::filter(Assembly %in% c("# contigs (>= 200 bp)", "Largest contig", "Total length","GC (%)", "N50"))
# remove additional strings to remain with only sample ID
colnames(metrics1) <- str_remove(colnames(metrics1), "_scaffolds|_assembly")
# transpose data using dplyr and tidyr
metrics2 <- metrics1 %>%
                gather(assembly, metrics, -Assembly) %>%
                spread(names(metrics1)[1], "metrics")
# reorder columns
col_order <- c("assembly","# contigs (>= 200 bp)", "GC (%)", "N50", "Largest contig", "Total length")
metrics2 <- metrics2 %>% select(col_order)

################# filter MLST results ##################################
mlst$FILE <- str_remove(mlst$FILE, "_scaffolds.fasta|_assembly.fasta")

################# rename colnames ######################################
names(countReads)[1] <- "SampleID"
names(covDepth)[1] <- "SampleID"
names(bactIns)[1] <- "SampleID"
names(conFin)[1] <- "SampleID"
colnames(kraken) <- c("SampleID","kraken2_match_#1","kraken2_match_#2","kraken2_match_#3","kraken2_match_#4","kraken2_X")
colnames(metrics2) <- c("SampleID","Contig.num", "Contigs.GC.content", "N50.value", "Longest.contig", "Total.bases.assembly")
names(mlst)[1] <- "SampleID"
names(mlst)[2] <- "Scheme.MLST"
################# remove unwanted columns ###############################
covDepth <- select(covDepth, -Est.GenomeSize)
kraken <- dplyr::select(kraken, -kraken2_X)

################# join data by group/section ############################
# metrics
metric_df <- plyr::join_all(list(countReads,covDepth,metrics2,mlst), by='SampleID', type='full')
# contamination check
contam_df <- plyr::join_all(list(bactIns,conFin,kraken), by='SampleID', type='full')
# CGE AMR and mutations
################ Join and write results to .xlsx file ###################
 # Merging the data sets
cmd_df <- plyr::join_all(list(contam_df,metric_df), by='SampleID', type='full')
cmd_df <- cmd_df %>% arrange(SampleID)

sheetNames <- c("Denovo-Assembly-Report")
brack <- openxlsx::createWorkbook()
sh_name <- sheetNames
## create and add a style to the column headers
headerStyle <- createStyle(fontName ="Times New Roman",fontSize =11, textDecoration ="bold") #, halign = "center")
bodyStyle <- createStyle(fontName ="Times New Roman",fontSize =11,)
row_n <- nrow(cmd_df) + 1
col_n <- ncol(cmd_df)
openxlsx::addWorksheet(brack, sheetName = sh_name)
openxlsx::writeData(brack, sheet = sh_name, cmd_df)
openxlsx::freezePane(brack, sheet = sh_name, firstRow = T)
openxlsx::addStyle(brack, sheet = sh_name, headerStyle, rows = 1, cols = 1:col_n,gridExpand = TRUE)
openxlsx::addStyle(brack, sheet = sh_name, bodyStyle, rows = 2:row_n, cols = 1:col_n,gridExpand = TRUE)
# write results to xlsx file
openxlsx::saveWorkbook(brack, paste(dir,args[2], sep = "/"), overwrite = T)

