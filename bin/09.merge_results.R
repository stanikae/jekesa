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
dir <- file.path(args[2])
#print(dir)

countReads <- read_excel(paste(dir,"03.countReads.xlsx", sep = "/"), col_names = TRUE)
covDepth <- read_excel(paste(dir,"03.coverageDepth.xlsx", sep = "/"), col_names = TRUE)
bactIns <- read_excel(paste(dir,"04.bactInspector.xlsx", sep = "/"), col_names = TRUE)
conFin <- read_excel(paste(dir,"04.confindr.xlsx", sep = "/"), col_names = TRUE)
kraken <- read_excel(paste(dir, "04.kraken.xlsx", sep = "/"), col_names = TRUE)
metrics <- read_excel(paste(dir,"05.quast.xlsx", sep = "/"), col_names = TRUE)
mlst <- read_excel(paste(dir, "05.mlst.xlsx", sep = "/"), col_names = TRUE)
resFin <- read_excel(paste(dir, "06.resfinder.xlsx", sep = "/"), col_names = TRUE)
#pointFin <- read_excel(paste(dir, "06.pointfinder.xlsx", sep = "/"), col_names = TRUE)
aribaAMR <- read_excel(paste(dir, "06.aribaAMR-known_variants.xlsx", sep = "/"), col_names = TRUE)
aribaVF <- read_excel(paste(dir, "06.aribaVFs-known_variants.xlsx", sep = "/"), col_names = TRUE)
aribaAMRn <- read_excel(paste(dir, "06.aribaAMR-novel_variants.xlsx", sep = "/"), col_names = TRUE)
aribaVFn <- read_excel(paste(dir, "06.aribaVFs-novel_variants.xlsx", sep = "/"), col_names = TRUE)

if(file.exists(paste(dir, "06.pointfinder.xlsx", sep = "/"))){
  pointFin <- read_excel(paste(dir, "06.pointfinder.xlsx", sep = "/"), col_names = TRUE)
}else{
  pointFin <- data.frame(matrix(ncol = 2, nrow = 0))
  colnames(pointFin) <- c("SampleID","PointFinder")
}
print("ALL data sets are loaded")

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
################# filter and join ARIBA results #################################
colnames(aribaAMR) <- str_remove(colnames(aribaAMR), ".match")
colnames(aribaVF) <- str_remove(colnames(aribaVF), ".match")
colnames(aribaAMRn) <- str_remove(colnames(aribaAMRn), ".match")
colnames(aribaVFn) <- str_remove(colnames(aribaVFn), ".match")
# join ariba known variants
aribaAMR$aribaAMR <- rep("AMRvariants", nrow(aribaAMR))
aribaVF$aribaVFs <- rep("VFvariants", nrow(aribaVF))
aribaAMR <- aribaAMR %>% dplyr::select(name,aribaAMR, everything())
aribaVF <- aribaVF %>% dplyr::select(name,aribaVFs, everything())
ariba_df <- dplyr::full_join(aribaAMR, aribaVF, by='name')
# join ariba novel variants
aribaAMRn$aribaAMRnovel <- rep("AMR-novel-variants", nrow(aribaAMRn))
aribaVFn$aribaVFsnovel <- rep("VF-novel-variants", nrow(aribaVFn))
aribaAMRn <- aribaAMRn %>% dplyr::select(name,aribaAMRnovel, everything())
aribaVFn <- aribaVFn %>% dplyr::select(name,aribaVFsnovel, everything())
aribaNovel_df <- dplyr::full_join(aribaAMRn, aribaVFn, by='name')

print("FORMATS FOR ALL FILES NOW REPORT READY")
################# rename colnames ######################################
names(countReads)[1] <- "SampleID"
names(covDepth)[1] <- "SampleID"
names(bactIns)[1] <- "SampleID"
names(conFin)[1] <- "SampleID"
colnames(kraken) <- c("SampleID","kraken2_match_#1","kraken2_match_#2","kraken2_match_#3","kraken2_match_#4","kraken2_X")
colnames(metrics2) <- c("SampleID","Contig.num", "Contigs.GC.content", "N50.value", "Longest.contig", "Total.bases.assembly")
names(mlst)[1] <- "SampleID"
names(mlst)[2] <- "Scheme.MLST"
names(resFin)[1] <- "SampleID"
#names(pointFin)[1] <- "SampleID"
names(ariba_df)[1] <- "SampleID"
names(aribaNovel_df)[1] <- "SampleID"

print("All sample IDs now uniform")
################# remove unwanted columns ###############################
covDepth <- select(covDepth, -Est.GenomeSize)
kraken <- dplyr::select(kraken, -kraken2_X)

################# join data by group/section ############################
# metrics
metric_df <- plyr::join_all(list(countReads,covDepth,metrics2,mlst), by='SampleID', type='full')
# contamination check
contam_df <- plyr::join_all(list(bactIns,conFin,kraken), by='SampleID', type='full')
# CGE AMR and mutations
if (nrow(pointFin) >= 1){
  names(pointFin)[1] <- "SampleID"
  cge_df <- dplyr::full_join(resFin,pointFin, by='SampleID')
}else{
  cge_df <- resFin
}

print("All dfs now combined")
################ Join and write results to .xlsx file ###################

sheetNames <- c("WGS-Typing-Report","AMR-and-VrulenceGene_variants")
brack <- openxlsx::createWorkbook()
## create and add a style to the column headers
headerStyle <- createStyle(fontName ="Times New Roman",fontSize =11, textDecoration ="bold") #, halign = "center")
bodyStyle <- createStyle(fontName ="Times New Roman",fontSize =11,)


if (args[1] == "spneumoniae") {
  # serotyping
  seroba <- read_excel(paste(dir, "07.seroba.xlsx", sep = "/"), col_names = TRUE)
  pili <- read_excel(paste(dir, "07.SPN-pili.xlsx", sep = "/"), col_names = TRUE)
  pbp <- read_excel(paste(dir, "07.SPN-pbp-typing.xlsx", sep = "/"), col_names = TRUE)
  # poppunk gpsc and clusters results
  gpsc <- read_excel(paste(dir, "07.SPN.assigned-gpscs.xlsx", sep = "/"), col_names = TRUE)
  clusters <- read_excel(paste(dir, "07.SPN.assigned-clusters.xlsx", sep = "/"), col_names = TRUE)
  # remove additional strings to remain with only sample ID
  colnames(gpsc) <- str_remove(colnames(gpsc), "_scaffolds.fasta|_assembly.fasta")
  colnames(clusters) <- str_remove(colnames(clusters), "_scaffolds.fasta|_assembly.fasta")

  #head(seroba)
  names(seroba)[1] <- "SampleID"
  names(pili)[1] <- "SampleID"
  names(pbp)[1] <- "SampleID"
  names(gpsc)[1] <- "SampleID"
  names(clusters)[1] <- "SampleID"

  # Merging the data sets
  cmd_df <- plyr::join_all(list(gpsc,cluster,contam_df,metric_df,seroba,cge_df,pbp), by='SampleID', type='full')
  data_lst <- list(cmd_df,ariba_df)
  
  for(i in seq_along(data_lst)){
     sh_name <- sheetNames[i]
     row_n <- nrow(data_lst[[i]]) + 1
     col_n <- ncol(data_lst[[i]])
     openxlsx::addWorksheet(brack, sheetName = sh_name)
     openxlsx::writeData(brack, sheet = sh_name, data_lst[[i]])
     openxlsx::freezePane(brack, sheet = sh_name, firstRow = T)
     #openxlsx::freezePane(brack, sheet = sh_name, firstActiveCol = "H")
     openxlsx::addStyle(brack, sheet = sh_name, headerStyle, rows = 1, cols = 1:col_n,gridExpand = TRUE)
     openxlsx::addStyle(brack, sheet = sh_name, bodyStyle, rows = 2:row_n, cols = 1:col_n,gridExpand = TRUE)
  }
  # write results to xlsx file
  #openxlsx::write.xlsx(cmd_df, paste(dir, args[3], sep = "/"), overwrite = T)
  openxlsx::saveWorkbook(brack, paste(dir,args[3], sep = "/"), overwrite = T)

} else if (args[1] == "spyogenes") {
  pbp <- read_excel(paste(dir, "07.GAS-typing.xlsx07.GAS.assigned-gpscs.xlsx", sep = "/"), col_names = TRUE)
  # poppunk gpsc and clusters results
  gpsc <- read_excel(paste(dir, "07.GAS.assigned-gpscs.xlsx", sep = "/"), col_names = TRUE)
  clusters <- read_excel(paste(dir, "07.GAS.assigned-clusters.xlsx", sep = "/"), col_names = TRUE)
  # remove additional strings to remain with only sample ID
  colnames(gpsc) <- str_remove(colnames(gpsc), "_scaffolds.fasta|_assembly.fasta")
  colnames(clusters) <- str_remove(colnames(clusters), "_scaffolds.fasta|_assembly.fasta")
  names(pbp)[1] <- "SampleID"
  names(gpsc)[1] <- "SampleID"
  names(clusters)[1] <- "SampleID"
  # Merging the data sets
  cmd_df <- plyr::join_all(list(gpsc,cluster,contam_df,metric_df,cge_df,pbp), by='SampleID', type='full')
  data_lst <- list(cmd_df,ariba_df)
  
  for(i in seq_along(data_lst)){
     sh_name <- sheetNames[i]
     row_n <- nrow(data_lst[[i]]) + 1
     col_n <- ncol(data_lst[[i]])
     openxlsx::addWorksheet(brack, sheetName = sh_name)
     openxlsx::writeData(brack, sheet = sh_name, data_lst[[i]])
     openxlsx::freezePane(brack, sheet = sh_name, firstRow = T)
     #openxlsx::freezePane(brack, sheet = sh_name, firstActiveCol = "H")
     openxlsx::addStyle(brack, sheet = sh_name, headerStyle, rows = 1, cols = 1:col_n,gridExpand = TRUE)
     openxlsx::addStyle(brack, sheet = sh_name, bodyStyle, rows = 2:row_n, cols = 1:col_n,gridExpand = TRUE)
   }
  # write results to xlsx file
  #openxlsx::write.xlsx(cmd_df, paste(dir, args[3], sep = "/"), overwrite = T)
  openxlsx::saveWorkbook(brack, paste(dir,args[3], sep = "/"), overwrite = T)

} else if (args[1] == "senterica") {
  sistrDF <- read_excel(paste(dir, "07.sistr.xlsx", sep = "/"), col_names = TRUE)
  seqseroDF <- read_excel(paste(dir, "07.seqsero.xlsx", sep = "/"), col_names = TRUE)
  names(sistrDF)[1] <- "SampleID"
  names(seqseroDF)[1] <- "SampleID" 
  # Merging the data sets
  cmd_df <- plyr::join_all(list(contam_df,metric_df,seqseroDF,sistrDF,cge_df), by='SampleID', type='full')
  cmd_df <- cmd_df %>% arrange(SampleID)
  data_lst <- list(cmd_df,ariba_df)

  for(i in seq_along(data_lst)){
     sh_name <- sheetNames[i]
     row_n <- nrow(data_lst[[i]]) + 1
     col_n <- ncol(data_lst[[i]])
     openxlsx::addWorksheet(brack, sheetName = sh_name)
     openxlsx::writeData(brack, sheet = sh_name, data_lst[[i]])
     openxlsx::freezePane(brack, sheet = sh_name, firstRow = T)
     openxlsx::addStyle(brack, sheet = sh_name, headerStyle, rows = 1, cols = 1:col_n,gridExpand = TRUE)
     openxlsx::addStyle(brack, sheet = sh_name, bodyStyle, rows = 2:row_n, cols = 1:col_n,gridExpand = TRUE)
  }
  # write results to xlsx file
  #openxlsx::write.xlsx(cmd_df, paste(dir, args[3], sep = "/"), overwrite = T)
  openxlsx::saveWorkbook(brack, paste(dir,args[3], sep = "/"), overwrite = T)

} else {
  # Merging the three data sets, metrics, mlst, and serotyping
  cmd_df <- plyr::join_all(list(contam_df,metric_df,cge_df), by='SampleID', type='full')
  data_lst <- list(cmd_df,ariba_df)

  for(i in seq_along(data_lst)){
     sh_name <- sheetNames[i]
     row_n <- nrow(data_lst[[i]]) + 1
     col_n <- ncol(data_lst[[i]])
     openxlsx::addWorksheet(brack, sheetName = sh_name)
     openxlsx::writeData(brack, sheet = sh_name, data_lst[[i]])
     openxlsx::freezePane(brack, sheet = sh_name, firstRow = T)
     openxlsx::addStyle(brack, sheet = sh_name, headerStyle, rows = 1, cols = 1:col_n,gridExpand = TRUE)
     openxlsx::addStyle(brack, sheet = sh_name, bodyStyle, rows = 2:row_n, cols = 1:col_n,gridExpand = TRUE)
}
  # write results to xlsx file
  #openxlsx::write.xlsx(cmd_df, paste(dir, args[3], sep = "/"), overwrite = T)
  openxlsx::saveWorkbook(brack, paste(dir,args[3], sep = "/"), overwrite = T)
}


