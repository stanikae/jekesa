#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)
#.libPaths("~/repos/jekesa/lib/Rlib")

library("openxlsx")

args <- commandArgs(TRUE)
print(args[1])
print(args[2])

path = file.path(args[1])
cat("Path is: ", path,"\n")
write.xlsx(read.delim(args[1], header = TRUE), args[2], asTable = T, overwrite=T)

