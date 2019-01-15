library(caTools)

set.seed(42)

data <- read.csv(file = "./data/ccfd/raw/creditcard.csv", header = TRUE, sep = ",", row.names = NULL)

# Drop unnecessary Time column
data <- subset(data, select = -c(Time))

data[1:29] <- apply(data[1:29], 2, function(x) (x/norm(x,"2")) )

# Split to normals and anomalies
normals <- data[which(data$Class == 0),]
anomalies <- data[which(data$Class == 1),]

# Use sampling with replacement to change anomalies to all samples ratio
for (ratio in c(0.001, 0.005, 0.01, 0.05, 0.1)) {
  sampled_normals <- anomalies[sample(nrow(normals), (1 - ratio) * nrow(data), replace = TRUE),]
  sampled_anomalies <-anomalies[sample(nrow(anomalies), ratio * nrow(data), replace = TRUE),]
  sampled_data <- rbind(sampled_normals, sampled_anomalies)
  
  split_ratio <- 0.8
  sampled <- sample.split(sampled_data, split_ratio)
  train <- subset(sampled_data, sampled == TRUE)
  test  <- subset(sampled_data, sampled == FALSE)
  
  directory <- file.path("./data/ccfd/variable_ratio", toString(ratio))
  dir.create(directory)
  write.csv(train, file = file.path(directory, "train.csv"), row.names = FALSE)
  write.csv(test, file = file.path(directory, "test.csv"), row.names = FALSE)
}