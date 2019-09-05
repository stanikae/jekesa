#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)
.libPaths("~/repos/jekesa/lib/Rlib")
library("openxlsx")

args <- commandArgs(TRUE)
print(args[1]) # path to input file with values delimited by "|"
print(args[2]) # path to output .xlsx file

#setwd(args)
#getwd()
path = file.path(args[1])
print("Path is:")
print(path)
# write to xlsx file
write.xlsx(read.delim(args[1], sep = "|", header = T), args[2])

