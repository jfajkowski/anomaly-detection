library(caTools)

set.seed(42)

data <- read.csv(file = "./data/ccfd/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

# Drop unnecessary Time column
data <- subset(data, select = -c(Time))

data[1:29] <- apply(data[1:29], 2, function(x) (x/norm(x,"2")) )

split_ratio <- 0.8
sample <- sample.split(data, split_ratio)
train <- subset(data, sample == TRUE)
test  <- subset(data, sample == FALSE)

write.csv(train, file = "./data/ccfd/normalized_l2/train.csv", row.names = FALSE)
write.csv(test, file = "./data/ccfd/normalized_l2/test.csv", row.names = FALSE)
