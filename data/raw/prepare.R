library(caTools)

set.seed(42)

data <- read.csv(file = "./data/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

# Drop unnecessary Time column
data <- subset(data, select = -c(Time))

split_ratio <- 0.8
sample <- sample.split(data, split_ratio)
train <- subset(data, sample == TRUE)
test  <- subset(data, sample == FALSE)

write.csv(train, file = "./data/raw/train.csv", row.names = FALSE)
write.csv(test, file = "./data/raw/test.csv", row.names = FALSE)
