#!/usr/bin/env Rscript
#args = commandArgs(trailingOnly=TRUE)

#.libPaths("~/repos/jekesa/lib/Rlib")
library("jsonlite")
library("tidyverse")
library("openxlsx")

args <- commandArgs(TRUE)

json_test <- fromJSON(args[1])
res_list <- purrr::flatten(json_test) %>% map_if(is_list, as_tibble) #%>%
  #map_if(is_tibble, list) #%>% bind_cols()

# get sample ID
long_name <- res_list$user_input$`filename(s)`
short_name <- str_split(long_name, pattern = "/")
name1 <- sapply(short_name, tail, 1)
name2 <- str_split(name1, pattern = "_")
name2 <- sapply(name2,`[`,1)
name2
res_tbl <- res_list$results
cols_res_tbl <- names(res_tbl)
cols_res_tbl
#unnest(res_tbl, cols = cols_res_tbl)
res_df <- unnest(res_tbl) #, cols = cols_res_tbl)
#res_df
logic_vec <- res_df == "No hit found"
logic_vec
nam <- names(res_df)[! logic_vec]
nam
res_df2 <- unnest(res_df) #, cols = nam)
#glimpse(res_df2)

for(i in seq_along(nam)){
 # print(res_df2[[nam[i]]])
  gene <- res_df2[[nam[i]]][[1]]
  percent <- paste0(round(res_df2[[nam[i]]][[2]],1),"%")
  res_df2[[nam[i]]][[1]] <- paste(gene,paste0("(",percent,")"),sep = " ")
}
glimpse(res_df2)
res_df3 <- slice(res_df2,1)
res_df4 <- res_df3 %>% unnest() #unnest(nam)
res_df4
#add sampleID column
name_df <- data.frame(sampleID=name2)
name_df
resfinder <- bind_cols(name_df,res_df4)
class(resfinder)
glimpse(resfinder)
#rownames(resfinder) <- NULL
# write to tsv
write_delim(resfinder, args[2], delim = "\t")

