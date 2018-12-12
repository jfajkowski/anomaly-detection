library(caTools)

source("./scripts/common/normalization.R")

set.seed(42)

data <- read.csv(file = "./data/ccfd/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

data[1:30] <- normalize_min_max(data[1:30])

split_ratio <- 0.8
sample <- sample.split(data, split_ratio)
train <- subset(data, sample == TRUE)
test  <- subset(data, sample == FALSE)

write.csv(train, file = "./data/ccfd/normalized_zero_one/train.csv", row.names = FALSE)
write.csv(test, file = "./data/ccfd/normalized_zero_one/test.csv", row.names = FALSE)
