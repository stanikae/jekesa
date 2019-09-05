#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


#Sys.setenv(http_proxy="http://nicd\\stanfordk:Kuda%401984@172.20.252.71:3128")
#Sys.setenv(https_proxy="http://nicd\\stanfordk:Kuda%401984@172.20.252.71:3128")
#Sys.setenv(ftp_proxy="http://nicd\\stanfordk:Kuda%401984@172.20.252.71:3128")
#Sys.setenv(socks_proxy="http://nicd\\stanfordk:Kuda%401984@172.20.252.71:3128")

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
.libPaths("~/repos/jekesa/lib/Rlib")

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

