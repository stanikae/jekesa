library(plyr)
library(tidyverse)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)
library(openxlsx)
library(readxl)

args <- commandArgs(TRUE)
path <- file.path(args[1])
sampleID <- args[2]
#path <- "/Users/stanfordk/Documents/Data-Delivery/Test-salmonella-pipeline/res4"
list.files(path)
# get species specific resistance if available
pheno_vec <- list.files(path, pattern = "pheno_table")
if (length(pheno_vec) > 1){
  file_input <- pheno_vec[str_length(pheno_vec) > 15]
  df <- read_delim(paste(path, file_input, sep = "/"), delim = "\t", skip = 16)
}else{
  file_input <- pheno_vec[1]
  df <- read_delim(paste(path, file_input, sep = "/"), delim = "\t", skip = 16)
}

#df <- read_delim(paste(path,"pheno_table.txt", sep = "/"), delim = "\t", skip = 16)
res_df <- read_delim(paste(path,"results_tab.txt", sep = "/"), delim = "\t")
names(res_df)
res_df <- res_df %>% select(c("Resistance gene","Identity","Phenotype","Accession no."))
#
ncol(df)
names(df)

# separate last column
df <- df %>% separate(`Genetic background`, into = c("GeneName","Background"), sep = " ")
names(df)[1] <- "Antimicrobial"

# combine data
names(res_df)[1] <- "GeneName"
cmd_df <- full_join(df,res_df, by="GeneName")

# combine columns into one
#df2 <- df %>% select(-c(Match,Background)) %>% 
#              tidyr::unite(c(2,3,4), remove=T, col="data") 
df2 <- cmd_df %>% select(-c(Match,Background)) %>% 
                tidyr::unite(c(Phenotype,GeneName,Identity), remove=T, col="data")

#test_list <- str_split(df2$data,"_")
#length(test_list)
#for (i in length(test_list)){
#  print(test_list[i][[1]])
#}


log_vec <- str_detect(df2$data,"NA_")
df2$data[log_vec] <- "No resistance found"

#names(df2) <- c("Antimicrobial","data")
#str_split(df2$data, pattern = "_")
# long to wide
cmd_df2 <- df2 %>% select(c(Antimicrobial,data))
#cmd_df3 <- pivot_wider(cmd_df2,id_cols = Antimicrobial, names_from = Antimicrobial, values_from = data)
cmd_df3 <- spread(cmd_df2,key = Antimicrobial, value = data)
# add sampleID column
cmd_df3 <- cmd_df3 %>% mutate(sampleID=sampleID) %>% select(sampleID, everything())
#test_str <- "aac(6')-Iaa"
#str_match(test_str, "aac\\(6\\'\\)\\-Iaa")

for (i in seq_along(cmd_df3)){
  cmd_df3[,i]
  if(str_detect(cmd_df3[,i],"_")){
     split_list <- str_split(cmd_df3[,i], pattern = "_")
     cmd_df3[,i] <- paste(split_list[1][[1]][1],paste0("{",split_list[1][[1]][2],": ",split_list[1][[1]][3],"%","}"))
  }
}

# write data to csv
write_csv(cmd_df3,paste(path,paste(sampleID,"res4","csv", sep="."), sep = "/"), append=F)
