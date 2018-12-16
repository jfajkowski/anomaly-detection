library(caTools)
library(binaryLogic)
library(R.utils)
source("./scripts/common/bucketize.R")

set.seed(42)

data <- read.csv(file = "./data/ccfd/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

n <- 4

data[1:30] <- apply(data[1:30], 2, function(x) bucketize(x,n))

#filter NA's
data <- na.omit(data)

#concatenate encoded columns
concatenated <- apply(data[1:30], 1, paste, collapse="")

#split to get list of binary values
splited <- strsplit(concatenated, split='')

#create data.frame
discretized <- cbind(do.call(rbind, splited), data[31])

split_ratio <- 0.8
sample <- sample.split(discretized, split_ratio)
train <- subset(discretized, sample == TRUE)
test  <- subset(discretized, sample == FALSE)

write.csv(train, file = "./data/ccfd/discretized/train.csv", row.names = FALSE)
write.csv(test, file = "./data/ccfd/discretized/test.csv", row.names = FALSE)
