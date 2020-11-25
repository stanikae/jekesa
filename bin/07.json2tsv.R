#!/usr/bin/env Rscript

library(tidyverse)
library(readr)
library(readxl)
library(openxlsx)
library(jsonlite)

args <- commandArgs(TRUE)
path <- args[1]
outPath <- args[2]

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



addData <- list()
for(i in seq_along(dat1)){
  #i=1
  resName <- names(dat1)[i]
  #resName <- names(dat1)[1]
  # check length
  #if(length(dat1[[i]]) == 1){
  if(str_detect(dat1[[i]][[1]][[1]],fixed("No hit found", ignore_case=TRUE))){
    len <- length(dat1[[i]])
    df <- data.frame(dat1[i])
    g1 <- "No hit found"
    g2 <- paste(g1, collapse="; ")
    addData[[resName]] <- g2
    next
  }
  
  if(length(dat1[[i]])==1){
    len <- length(dat1[[i]][[1]])
    l2df <- dat1[[i]][[1]]
    df <- data.frame(dat1[[i]][[1]])
    g1 <- paste(paste0("(Gene-Serotype-Identity-Cov)"),
                  paste(df$gene,df$serotype,
                        paste0(round(as.numeric(as.character(df$identity)),1),"%"),
                        paste0(round(as.numeric(as.character(df$coverage)),1),"%"),
                  sep="-"),
                sep = " ")
    g3 <- paste(g1, collapse="; ")
    addData[[resName]] <- g3
  }else{
    vec_typ <- vector()
    for(j in seq_along(dat1[[i]])){
      len <- length(dat1[[i]][[j]])
      l2df <- dat1[[i]][[j]]
      df <- data.frame(dat1[[i]][[j]])
      g1 <- paste(paste0("(Gene-Serotype-Identity-Cov)"),
                  paste(df$gene,df$serotype,
                        paste0(round(as.numeric(as.character(df$identity)),1),"%"),
                        paste0(round(as.numeric(as.character(df$coverage)),1),"%"),
                  sep="-"),
                sep = " ")
      vec_typ[j] <- g1
    }
    g4=paste(vec_typ, collapse="; ")
    addData[[resName]]=g4
  }
  
}

mx <- max(lengths(addData))
d1 <- data.frame(lapply(addData, `length<-`, mx))

# remove rownames
rownames(d1) <- NULL
#add sampleID column
name_df <- data.frame(sampleID=name2)
typed_data <- dplyr::bind_cols(name_df,d1)
# write to tsv
write_delim(typed_data, outPath, delim = "\t")

