#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)

#.libPaths("~/repos/jekesa/lib/Rlib")

library("openxlsx")

args <- commandArgs(TRUE)

print(args[1]) # input .csv file
print(args[2]) # output .xlsx file

#setwd(args)
#getwd()
path = file.path(args[1])
print("Path is:")
print(path)
#library("openxlsx")
#write.xlsx(read.csv(args[2]), paste(path, "abricate_results.xlsx", sep = "/"))
write.xlsx(read.csv(args[1]), args[2], overwrite = T)

