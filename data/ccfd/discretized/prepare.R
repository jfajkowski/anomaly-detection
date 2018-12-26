library(caTools)
library(binaryLogic)
library(R.utils)
source("./scripts/common/bucketize.R")

set.seed(42)

data <- read.csv(file = "./data/ccfd/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

split_ratio <- 0.8
sample <- sample.split(data, split_ratio)
train_data <- subset(data, sample == TRUE)
test_data  <- subset(data, sample == FALSE)

n <- 256

train_data[1:30] <- apply(train_data[1:30], 2, function(x) bucketize(x,n))
test_data[1:30] <- apply(test_data[1:30], 2, function(x) bucketize(x,n))


#filter NA's
train_data <- na.omit(train_data)
test_data <- na.omit(test_data)

#concatenate encoded columns
train_concatenated <- apply(train_data[1:30], 1, paste, collapse="")
test_concatenated <- apply(test_data[1:30], 1, paste, collapse="")

#split to get list of binary values
train_splited <- strsplit(train_concatenated, split='')
test_splited <- strsplit(test_concatenated, split='')

#create data.frame
train_discretized <- cbind(do.call(rbind, train_splited), train_data[31])
test_discretized <- cbind(do.call(rbind, test_splited), test_data[31])


write.csv(train_discretized, file = "./data/ccfd/discretized/train.csv", row.names = FALSE)
write.csv(test_discretized, file = "./data/ccfd/discretized/test.csv", row.names = FALSE)
