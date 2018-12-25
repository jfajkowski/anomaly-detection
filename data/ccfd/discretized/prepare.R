library(caTools)
library(binaryLogic)
library(R.utils)
source("./scripts/common/bucketize.R")

set.seed(42)

data <- read.csv(file = "./data/ccfd/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

# Drop unnecessary Time column
data <- subset(data, select = -c(Time))

n <- 4

data[1:29] <- apply(data[1:29], 2, function(x) bucketize(x,n))

#filter NA's
data <- na.omit(data)

#concatenate encoded columns
concatenated <- apply(data[1:29], 1, paste, collapse="")

#split to get list of binary values
splited <- strsplit(concatenated, split='')

#create data.frame
discretized <- cbind(do.call(rbind, splited), data[30])

split_ratio <- 0.8
sample <- sample.split(discretized, split_ratio)
train <- subset(discretized, sample == TRUE)
test  <- subset(discretized, sample == FALSE)

write.csv(train, file = "./data/ccfd/discretized/train.csv", row.names = FALSE)
write.csv(test, file = "./data/ccfd/discretized/test.csv", row.names = FALSE)
