library(caTools)

set.seed(42)

data <- read.csv(file = "./data/ccfd/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

data[1:30] <- scale(data[1:30])

split_ratio <- 0.8
sample <- sample.split(data, split_ratio)
train <- subset(data, sample == TRUE)
test  <- subset(data, sample == FALSE)

write.csv(train, file = "./data/ccfd/scaled/train.csv", row.names = FALSE)
write.csv(test, file = "./data/ccfd/scaled/test.csv", row.names = FALSE)
