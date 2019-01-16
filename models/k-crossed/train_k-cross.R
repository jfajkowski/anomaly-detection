require(keras)
require(cloudml)
require(caret)
require(dplyr)

data_dir <- "./data/raw"

raw <- read.csv(file = file.path(data_dir, "train.csv"), header = TRUE, sep = ",", row.names = NULL)

columns <- colnames(raw)

folds <- createFolds(y_raw, k = 5)

split_up <- lapply(flds, function(ind, dat) dat[ind,], dat = raw)

df_split_up <- list()

for (i in 1:5) {
  df_split_up[[i]] <- data.frame(split_up[i])
  colnames(df_split_up[[i]]) <- columns
}


for (i in 1:5) {
  
  train <- bind_rows(df_split_up[[i]]) 
  test <- df_split_up[[i]]

}