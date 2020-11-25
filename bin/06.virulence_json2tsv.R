#!/usr/bin/env Rscript
library(tidyverse)
library(readr)
library(readxl)
library(openxlsx)
library(jsonlite)

args <- commandArgs(TRUE)
path <- args[1]
outPath <- args[2]
#mlst <- "ecoli"
mlst <- args[3]

dat <- fromJSON(path)
names(dat)
type_name <- c("resfinder","serotypefinder","virulencefinder")

if (names(dat) %in% type_name){
  t_name <- names(dat)
  dat1 <- dat[[t_name]]$results
  dat1_len <- length(dat1)
  dat1_names <- names(dat1)
  # get sample ID
  long_name <- dat[[t_name]]$user_input$`filename(s)`
  short_name <- str_split(long_name, pattern = "/")
  name1 <- sapply(short_name, tail, 1)
  name2 <- str_split(name1, pattern = "_")
  name2 <- sapply(name2,`[`,1)
}
#dat$serotypefinder$results
# select the matching database for the specific mlst scheme
if (mlst == "ecoli" || mlst =="ecoli_2"){
  dat2 <- dat1[["Escherichia coli"]]
  dat2_nams <- names(dat2)
}else if(mlst == "efaecalis" || mlst == "efaecium"){
  dat2 <- dat1[["Enterococcus"]]
  dat2_nams <- names(dat2)
}else if(mlst == "saureus"){
  dat2 <- dat1[["Staphylococcus aureus"]]
  dat2_nams <- names(dat2)
}else if(mlst == "lmonocytogenes"){
  dat2 <- dat1[["Listeria"]]
  dat2_nams <- names(dat2)
}else{
  break
}

addData <- list()
for (n in seq_along(dat2_nams)){
    nam <- dat2_nams[n]  
    
    for (k in seq_along(dat2[[nam]])){
      
      if(str_detect(dat2[[nam]][[k]][[1]],fixed("No hit found", ignore_case=TRUE))){
        len <- length(dat2[[nam]][[k]])
        df <- data.frame(dat2[[nam]][[k]])
        g1 <- "No hit found"
        g2 <- paste(g1, collapse="; ")
        addData[[nam]] <- g2
        next
      }
      
      
      if(length(dat2[[nam]][[k]])>=1){
        df <- data.frame(dat2[[nam]][[k]][c(1,2,10,11)])
        geneName <- str_trim(df$virulence_gene,"both")
        prot_fun <- str_trim(df$protein_function,"both")
        g1 <- paste(paste0("(Function-Identity-Cov)"),
                    paste(prot_fun,
                          paste0(round(as.numeric(as.character(df$identity)),1),"%"),
                          paste0(round(as.numeric(as.character(df$coverage)),1),"%"),
                          sep="-"),
                    sep = " ")
        g3 <- paste(g1, collapse="; ")
        addData[[geneName]] <- g3
      }
      
    }
}


mx <- max(lengths(addData))
d1 <- data.frame(lapply(addData, `length<-`, mx))
d1 <- dplyr::select(d1, -virulence_ecoli)
# remove rownames
rownames(d1) <- NULL
#add sampleID column
name_df <- data.frame(sampleID=name2)
typed_data <- dplyr::bind_cols(name_df,d1)
# write to tsv
write_delim(typed_data, outPath, delim = "\t")

