#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)


#.libPaths("~/repos/jekesa/lib/Rlib")

library(plyr)
library(tidyverse)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)
#library(rJava)
#library(XLConnectJars)
#library(XLConnect)
library(openxlsx)
library(readxl)

######################
# get input using arguments
args <- commandArgs(TRUE)

#getwd()
dir <- file.path(args[1])
print(dir)
#print(args[8])
# read in WGS-typing final report, and the two poppunk xlsx files
wgs <- read_excel(paste(dir,args[2], sep = "/"), col_names = TRUE)
gpsc <- read_excel(paste(dir, args[3], sep = "/"), col_names = TRUE)
#clusters <- read_excel(paste(dir, args[4], sep = "/"), col_names = TRUE)

names(gpsc)[1] <- "SampleID"
brack <- openxlsx::createWorkbook()
sh_name <- "WGS-Typing-Report"
## create and add a style to the column headers
headerStyle <- createStyle(textDecoration ="bold") #, halign = "center")
openxlsx::addWorksheet(brack, sheetName = sh_name)

if (length(args) == 4) {

	print(args[1]) # path denovo assembly reports directory
	print(args[2]) # WGS-typing report file
	print(args[3]) # bactInspector species investigation file
	print(args[4]) # Output file ### bactInspector closest species
#	print(args[5]) # Output file
	
	cmd_df <- plyr::join_all(list(gpsc,wgs), by='SampleID', type='full')
	#nrow(cmd_df)
	head(cmd_df);tail(cmd_df);nrow(cmd_df)
	openxlsx::writeData(brack, sheet = sh_name, cmd_df)
	openxlsx::freezePane(brack, sheet = sh_name, firstRow = T)
	openxlsx::freezePane(brack, sheet = sh_name, firstActiveCol = "H")
	openxlsx::addStyle(brack, sheet = sh_name, headerStyle, rows = 1, cols = 1:ncol(cmd_df),gridExpand = TRUE)
	# write results to xlsx file
	#openxlsx::write.xlsx(cmd_df, paste(dir, args[4], sep = "/"), overwrite = T)
	openxlsx::saveWorkbook(brack, paste(dir,args[4], sep = "/"), overwrite = T)

}
