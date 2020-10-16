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

# ---------------------------- FUNCTIONS -----------------------------
grp_dfs <- function(lst, name_vec){
  grp_list <- lst[names(lst) %in% name_vec]
  if(length(grp_list) != 0){
    grp_list <- grp_list[name_vec]
    for (j in seq_along(names(grp_list))){
      grp_list[[j]]["SampleID"] <- str_remove(grp_list[[j]][["SampleID"]], "_.*") # to remove hard coded var names
    }
    grp_df <- plyr::join_all(grp_list, by='SampleID', type='full') # to remove hard coded var names
    return(grp_df)
  }
}

# ------------------ get input using arguments -----------------------
args <- commandArgs(TRUE)
#getwd()
#schemeName <- args[1]
dir <- file.path(args[1])
outfile <- args[2]

out_dir <- dir
# check if directory exists and create it if it doesn't
if (! dir.exists(out_dir)) {dir.create(out_dir)}
path <- out_dir

# ------------------ get full paths to files --------------------------
files_vec <- list.files(path = path,pattern = ".xlsx",full.names = T, recursive = F, include.dirs = F)
filename_vec <- sapply(files_vec, basename, USE.NAMES = F)
pat <- ".xlsx"
ids_vec <- str_remove(filename_vec, pat)

# --------------- read multiple excel files into list ----------------------
data_list <- lapply(files_vec, read_excel)
# name list elements
names(data_list) <- ids_vec

# --------------------- Begin processing multiple result files -------------
aribaAMR <- data.frame()
aribaVF <- data.frame()
for (j in seq_along(names(data_list))){
  id=names(data_list)[j]
  if(str_detect(id, "WGS-typing-report")){ next}
  if (str_detect(id,"06.ariba")){
    colnames(data_list[[j]]) <- str_remove(colnames(data_list[[j]]), ".match")
    
    if(str_detect(id,"06.aribaAMR-known_variants")){
      aribaAMR <- data_list[[j]] %>% mutate(aribaAMR = rep("AMRvariants", nrow(data_list[[j]])))
      data_list[[j]] <- aribaAMR %>% dplyr::select(name,aribaAMR, everything())
      } else if (str_detect(id,"06.aribaVFs-known_variants")) {
        aribaVF <- data_list[[j]] %>% mutate(aribaVFs = rep("VFvariants", nrow(data_list[[j]])))
        data_list[[j]] <- aribaVF %>% dplyr::select(name,aribaVFs, everything())
      }
  }
  # rename colnames
  if (id != "08.ska-SNP-distances"){
    if(id == "04.kraken"){
      colnames(data_list[[j]]) <- c("SampleID","kraken2_match_#1","kraken2_match_#2","kraken2_match_#3","kraken2_match_#4","kraken2_X")
      data_list[[j]] <- data_list[[j]] %>% dplyr::select(-kraken2_X)
    }
    if(id == "05.quast"){
      metrics1 <-  data_list[[j]] %>% dplyr::filter(Assembly %in% c("# contigs (>= 0 bp)", "Largest contig", "Total length","GC (%)", "N50"))
      # remove additional strings to remain with only sample ID
      colnames(metrics1) <- str_remove(colnames(metrics1), "_scaffolds|_assembly|_shovill_seksa")
      # transpose data using dplyr and tidyr
      metrics2 <- metrics1 %>%
        gather(assembly, metrics, -Assembly) %>%
        spread(names(metrics1)[1], "metrics")
      # reorder columns
      if(ncol(metrics2) == 5){
        col_order <- c("assembly","# contigs (>= 0 bp)", "N50", "Largest contig", "Total length")
        metrics2 <- metrics2 %>% select(col_order)
        colnames(metrics2) <- c("SampleID","Contig.num", "N50.value", "Longest.contig", "Total.bases.assembly")
      } else{
        col_order <- c("assembly","# contigs (>= 0 bp)", "GC (%)", "N50", "Largest contig", "Total length")
        metrics2 <- metrics2 %>% select(col_order)
        colnames(metrics2) <- c("SampleID","Contig.num", "Contigs.GC.content", "N50.value", "Longest.contig", "Total.bases.assembly")
      }
      
      data_list[[j]] <- metrics2
    }
    
    #colnames(data_list[[j]])[1] <- "SampleID"
    
    if(id == "05.mlst"){
      names(data_list[[j]])[2] <- "Scheme.MLST"
    }
    if(id == "03.coverageDepth"){
      #colnames(data_list[[j]])[1] <- "SampleID"
      if(ncol(data_list[[j]]) == 3){
        data_list[[j]] <- data_list[[j]] %>% dplyr::select(-Est.GenomeSize)
      }
    }
    if(id == "assigned-gpscs"){
      colnames(data_list[[j]]) <- str_remove(colnames(data_list[[j]]), "_scaffolds.fasta|_assembly.fasta")
    }
    if(id == "assigned-clusters"){
      colnames(data_list[[j]]) <- str_remove(colnames(data_list[[j]]), "_scaffolds.fasta|_assembly.fasta")
    }
    if(is.na(colnames(data_list[[j]])[1])){next}
    colnames(data_list[[j]])[1] <- "SampleID"
  }
}
# --------------- join ARIBA dfs ------------------------------------
ariba_names <- c("06.aribaAMR-known_variants","06.aribaVFs-known_variants")
ariba_list <- data_list[str_detect(names(data_list), "^06.ariba")]
if(length(ariba_list) != 0){
ariba_df <- grp_dfs(data_list,ariba_names)
}
# ---------------- group the other reports --------------------------
metrics_names <- c("03.countReads","03.coverageDepth","05.quast","05.mlst")
contam_names <- c("04.bactInspector","04.confindr","04.kraken")
cge_names <- c("06.resfinder","06.pointfinder")

names_lst <- list(contam_names,metrics_names,cge_names)

cmd_lst <- list()
for (i in seq_along(names_lst)){
  g_df <- grp_dfs(data_list,names_lst[[i]])
  cmd_lst[[i]] <- g_df
  cmd_lst <- purrr::compact(cmd_lst)
}
# --------------- Merging the data sets --------------------------------                                                                                                                                      
cmd_df <- plyr::join_all(cmd_lst, by='SampleID', type='full')

# ------------- add species specific data -------------------------------
specific_list <- data_list[str_detect(names(data_list), "^07")]
if (length(specific_list) >= 1){
  specific_df <- plyr::join_all(specific_list, by='SampleID', type='full')
  cmd_df <- dplyr::full_join(cmd_df,specific_df, by='SampleID')
}

# --------------- add ska pairwise-SNP-differences --------------------------------------------------
ska_list <- data_list[str_detect(names(data_list), "^08.ska")]
if(length(ska_list) == 1){
  ska_df <- plyr::join_all(ska_list, by='SampleID', type='full')
  data_lst <- list(cmd_df,ariba_df,ska_df)
}else{
  data_lst <- list(cmd_df,ariba_df)
}

# --------------- join and write results to .xlsx file ----------------------------------------------
sheetNames <- c("WGS-Typing-Report","AMR-and-VrulenceGene_variants","Pairwise-SNP-differences")
brack <- openxlsx::createWorkbook()
## create and add a style to the column headers
headerStyle <- createStyle(fontName ="Times New Roman",fontSize =11, textDecoration ="bold") #, halign = "center")
bodyStyle <- createStyle(fontName ="Times New Roman",fontSize =11)


for(i in seq_along(data_lst)){
  sh_name <- sheetNames[i]
  abun_data <- data_lst[[i]]
  if(length(abun_data) == 0){
      next
  }else{
    row_n <- nrow(abun_data) + 1
    col_n <- ncol(abun_data)
    openxlsx::addWorksheet(brack, sheetName = sh_name)
    openxlsx::writeDataTable(brack, sheet = sh_name, abun_data)
    openxlsx::freezePane(brack, sheet = sh_name, firstRow = T)
    openxlsx::addStyle(brack, sheet = sh_name, headerStyle, rows = 1, cols = 1:col_n,gridExpand = TRUE)
    openxlsx::addStyle(brack, sheet = sh_name, bodyStyle, rows = 2:row_n, cols = 1:col_n,gridExpand = TRUE)
  }
}
#openxlsx::saveWorkbook(brack, paste(dir,outfile, sep = "/"), overwrite = T)
# write to file
openxlsx::saveWorkbook(brack, paste(dir,outfile, sep = "/"), overwrite = T)
