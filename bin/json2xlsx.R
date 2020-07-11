library(jsonlite)
library(tidyverse)
library(openxlsx)
indir <- "C:/Users/stanfordk/Documents/Data-Delivery/Test-Json"
json_test <- fromJSON(paste(indir,"data_resfinder.json", sep = "/"),
                      flatten = T)
glimpse(json_test)
res_list <- purrr::flatten(json_test) %>% map_if(is_list, as_tibble) #%>%
  #map_if(is_tibble, list) #%>% bind_cols()

# get sample ID
long_name <- res_list$user_input$`filename(s)`
short_name <- str_split(long_name, pattern = "/")
name1 <- sapply(short_name, tail, 1)
name2 <- str_split(name1, pattern = "_")
name2 <- sapply(name2,`[`,1)
#name vector
#names(name2) <- "sampleID"

glimpse(res_list$results)

res_tbl <- res_list$results
#res_df <- res_tbl[[1]]
glimpse(res_tbl)
cols_res_tbl <- names(res_tbl)
res_df <- unnest(res_tbl, cols = cols_res_tbl)
glimpse(res_df)
#res_df2$Aminoglycoside
#res_tbl$Fosfomycin$fosfomycin[1]

class(res_df)
logic_vec <- res_df == "No hit found"
nam <- names(res_df)[! logic_vec]
res_df2 <- res_df %>% unnest(cols = nam)
for(i in seq_along(nam)){
  gene <- res_df2[[i]][[1]]
  percent <- paste0(round(res_df2[[i]][[2]],1),"%")
  res_df2[[i]][[1]] <- paste(gene,paste0("(",percent,")"),sep = " ")
}
res_df2
res_df3 <- slice(res_df2,1)
res_df3 <- res_df3 %>% unnest(nam)
#class(res_df3)
#add sampleID column
name_df <- data.frame(sampleID=name2)
resfinder <- bind_cols(name_df,res_df3)
rownames(resfinder) <- NULL
# write to excel
write.xlsx(resfinder, paste(indir,"06.resfinder.xlsx", sep = "/"), overwrite=T)
