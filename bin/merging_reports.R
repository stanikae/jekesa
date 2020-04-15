#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


#.libPaths("~/repos/jekesa/lib/Rlib")

library(plyr)
library(tidyverse)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)
#library(rJava)
#library(XLConnectJars)
#library(XLConnect)
library(openxlsx)
library(readxl)

######################
# get input using arguments
args <- commandArgs(TRUE)

#getwd()
dir <- file.path(args[1])
print(dir)
#print(args[8])
# read in mlst results, assembly metrics, and serotyping output
#metricsQC <- read_excel(paste(dir,args[2], sep = "/"), col_names = TRUE)
metrics <- read_excel(paste(dir,args[2], sep = "/"), col_names = TRUE)
mlst <- read_excel(paste(dir, args[3], sep = "/"), col_names = TRUE)
ariba <- read_excel(paste(dir, args[4], sep = "/"), col_names = TRUE)
kraken <- read_excel(paste(dir, args[5], sep = "/"), col_names = TRUE)
#pili <- read_excel(paste(dir, args[8], sep = "/"), col_names = TRUE)
#pbp <- read_excel(paste(dir, args[9], sep = "/"), col_names = TRUE)

#metrics1 <- metrics %>% dplyr::filter(Assembly %in% c("# contigs (>= 200 bp)", "Largest contig", "Total length","GC (%)", "N50","Coverage >= 10x (%)"))
metrics1 <- metrics %>% dplyr::filter(Assembly %in% c("# contigs (>= 200 bp)", "Largest contig", "Total length","GC (%)", "N50"))
# remove additional strings to remain with only sample ID
colnames(metrics1) <- str_remove(colnames(metrics1), "_scaffolds|_assembly")
#colnames(metricsQC) <- str_remove(colnames(metricsQC), "_scaffolds|_assembly")

# transpose data using dplyr and tidyr
metrics2 <- metrics1 %>%
                gather(assembly, metrics, -Assembly) %>%
                spread(names(metrics1)[1], "metrics")

#metricsQC <- metricsQC %>%
#                gather(assembly, metrics, -Assembly) %>%
#                spread(names(metricsQC)[1], "metrics")

# reorder columns
col_order <- c("assembly","# contigs (>= 200 bp)", "GC (%)", "N50", "Largest contig", "Total length")
metrics2 <- metrics2 %>% select(col_order)

# rename metrics column names
colnames(metrics2) <- c("SampleID","Contig_num", "GC_content", "N50_value", "Longest_contig", "Total_bases")
#colnames(metricsQC) <- c("assembly","Contigs (>=200bp)","CDS","Properly_paired_reads", "rRNA","Total_reads",
#                         "Avg_Coverage_Depth","Coverage (>=10x)", "GC%", "Largest_contig", "N50", "Total_length")


# check metricsQC
#print("Last check before merge")
#head(metricsQC);nrow(metricsQC)
################
# mlst data
#head(mlst)
mlst$FILE <- str_remove(mlst$FILE, "_scaffolds.fasta|_assembly.fasta")
names(mlst)[1] <- "SampleID"
# ariba data
names(ariba)[1] <- "SampleID"
#names(pili)[1] <- "SampleID"
#names(pbp)[1] <- "SampleID"

#print("metricsQC");head(metricsQC)
print("metrics2");head(metrics2)
print("mlst");head(mlst)
print("ariba");head(ariba)
#print("pili");head(pili)
#print("pbp");head(pbp)

# rename kraken column names 
colnames(kraken) <- c("SampleID","kraken2_match_#1","kraken2_match_#2","kraken2_match_#3","kraken2_match_#4","kraken2_X")
print("kraken");head(kraken)

# drop kraken last column
#krak_names <- colnames(kraken)
#krak_drop <- tail(krak_names, n=1)
#krak_names <- krak_names[! krak_names %in% krak_drop]
#kraken <- kraken[, names(kraken) %in% krak_names]
kraken <- dplyr::select(kraken, -kraken2_X)


if (length(args) == 9) {

	print(args[1]) # path denovo assembly reports directory
#	print(args[2]) # assembly metrics (sequencing QC)
	print(args[2]) # assembly metrics file
	print(args[3]) # mlst results file
	print(args[4]) # ariba results based on CARD database
	print(args[5]) # kraken results file
	print(args[6]) # seroba results file
	print(args[7]) # combined results output file
	print(args[8]) # pili
	print(args[9]) # pbp

	# serotyping
	seroba <- read_excel(paste(dir, args[6], sep = "/"), col_names = TRUE)
	pili <- read_excel(paste(dir, args[8], sep = "/"), col_names = TRUE)
	pbp <- read_excel(paste(dir, args[9], sep = "/"), col_names = TRUE)
	#head(seroba)
	names(seroba)[1] <- "SampleID"
	names(pili)[1] <- "SampleID"
	names(pbp)[1] <- "SampleID"
	# Merging the three data sets, metrics, mlst, and serotyping
	cmd_df <- plyr::join_all(list(kraken,metrics2,pili,seroba,mlst,ariba,pbp), by='SampleID', type='full')
	#nrow(cmd_df)
	head(cmd_df);tail(cmd_df);nrow(cmd_df)

	# write results to xlsx file
	openxlsx::write.xlsx(cmd_df, paste(dir, args[7], sep = "/"), overwrite = T)

} else if (length(args) == 7) {
        pbp <- read_excel(paste(dir, args[7], sep = "/"), col_names = TRUE)
        #head(seroba)
        names(pbp)[1] <- "SampleID"
        # Merging the three data sets, metrics, mlst, and serotyping
        cmd_df <- plyr::join_all(list(kraken,metrics2,mlst,ariba,pbp), by='SampleID', type='full')
	# write results to xlsx file
        openxlsx::write.xlsx(cmd_df, paste(dir, args[6], sep = "/"), overwrite = T)

} else {
	print(args[1]) # path denovo assembly reports directory
#	print(args[2]) # assembly metrics file (sequencing data QC)
	print(args[2]) # assembly metrics file
	print(args[3]) # mlst results file
	print(args[4]) # ariba results
	print(args[5]) # kraken results file
	print(args[6]) # combined results output file

	# Merging the three data sets, metrics, mlst, and serotyping
        head(metrics2); nrow(metrics2)
        head(mlst); nrow(mlst)
        #library(plyr)
        cmd_df <- plyr::join_all(list(kraken,metrics2,mlst,ariba), by='SampleID', type='full')
        #nrow(cmd_df)
        head(cmd_df);tail(cmd_df);nrow(cmd_df)

        # write results to xlsx file
        openxlsx::write.xlsx(cmd_df, paste(dir, args[6], sep = "/"), overwrite = T)
}


