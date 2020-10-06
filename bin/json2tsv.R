#!/usr/bin/env Rscript

library(jsonlite)
library(tidyverse)
library(openxlsx)
#library(vctrs)

args <- commandArgs(TRUE)

dat <- fromJSON(args[1])
dat1 <- dat$resfinder$results

# get sample ID
long_name <- dat$resfinder$user_input$`filename(s)`
short_name <- str_split(long_name, pattern = "/")
name1 <- sapply(short_name, tail, 1)
name2 <- str_split(name1, pattern = "_")
name2 <- sapply(name2,`[`,1)

#glimpse(dat1)
addData <- list()
for(i in seq_along(dat1)){
  resName <- names(dat1)[i]
  # check length
  errorVec <- try(length(dat1[[i]][[1]]))
  if("try-error" %in% class(errorVec)) {
    len <- length(dat1[[i]])
    l2df <- dat1[[i]]
  }else{
    len <- length(dat1[[i]][[1]])
    l2df <- dat1[[i]][[1]]
  }
  len
  df <- data.frame(matrix(unlist(l2df), nrow=length(l2df), byrow=T))
  nRow <- nrow(df)
  if(nRow == 1){
    if(is.null(df$X1)){
      g1 <- "No hit found"
    }else{
    g1 <- paste(df$X1,
                paste0("(",round(as.numeric(as.character(df$X2)),1),"%",")"),
                sep = " ")
    }
    g2 <- paste(g1, collapse="; ")
    addData[[resName]] <- g2
  }else if(nRow > 1){
    g1 <- paste(df$X1,
                paste0("(",round(as.numeric(as.character(df$X2)),1),"%",")"),
                sep = " ")
    length(g1)
    g2 <- paste(g1, collapse="; ")
    addData[[resName]] <- g2
  }
}

mx <- max(lengths(addData))
d1 <- data.frame(lapply(addData, `length<-`, mx))

# remove rownames
rownames(d1) <- NULL
#add sampleID column
name_df <- data.frame(sampleID=name2)
resfinder <- bind_cols(name_df,d1)
# write to tsv
write_delim(resfinder, args[2], delim = "\t")

