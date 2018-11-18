split_ratio <- 0.8

data <- read.csv(file = "./data/ccfd/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

data[1:30] <- scale(data[1:30])

sample <- sample.split(data, split_ratio)
train <- subset(data, sample == TRUE)
test  <- subset(data, sample == FALSE)

write.csv(train, file = "./data/ccfd/processed/train.csv", row.names = FALSE)
write.csv(test, file = "./data/ccfd/processed/test.csv", row.names = FALSE)
