#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


#library(plyr)
#library(tidyverse)
#library(plyr)
#library(tidyr)
#library(dplyr)
#library(purrr)
#library(rJava)
#library(XLConnectJars)
#library(XLConnect)
#library(stringr)

#.libPaths("~/repos/jekesa/lib/Rlib")

library("openxlsx")

args <- commandArgs(TRUE)
print(args[1])
print(args[2])

#setwd(args)
#getwd()
path = file.path(args[1])
cat("Path is: ", path,"\n")
#print(path)
#library("openxlsx")
#write.xlsx(read.delim(args[2]), paste(path, "mlst_typing_results.xlsx", sep = "/"))
write.xlsx(read.delim(args[1], header = TRUE), args[2])

