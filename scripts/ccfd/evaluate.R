library(keras)
library(OptimalCutpoints)
library(caret)
library(pROC)
library(ggplot2)
library(yaml)
library(e1071)

#install.packages('OptimalCutpoints')
#install.packages('caret')
#install.packages('pROC')
#install.packages('e1071')

source("./scripts/common/normalization.R")

args <- commandArgs(trailingOnly = TRUE)

model_dir <- args[1]
#model_dir <- "./models/ccfd/normalized_l2/3_layers"

FLAGS <- read_yaml(paste(model_dir, "/flags.yml", sep = ""))

test <- read.csv(file = file.path(FLAGS$data_dir, "test.csv"), header = TRUE, sep = ",", row.names = NULL)
model <- load_model_hdf5(file.path(model_dir, paste("model.hdf5", sep = "")))

X_test <- as.matrix(subset(test, select = -c(Class)))
y_test <- as.matrix(subset(test, select = c(Class)))

X_predict <- model %>% predict(X_test)
if(FLAGS$metric == "mae"){
  y_predict <- as.matrix(normalize_min_max(apply(abs(X_test - X_predict), 1, function(x) sum(x) / length(x))))
}
if(FLAGS$metric == "mse"){
  y_predict <- as.matrix(normalize_min_max(apply(((X_test - X_predict)**2), 1, function(x) sum(x) / length(x))))
}

colnames(y_predict) <- c("Error")

# Calculate ROC and AUC
roc_curve <- roc(as.vector(y_test), as.vector(y_predict))
auc(roc_curve)

# Find optimal cutoff point
cutoff <- coords(roc_curve, "best", "threshold")
cat("Optimal cutoff point:", cutoff["threshold"], "\n")
confusionMatrix(table(y_predict > cutoff["threshold"], y_test == 1))

# Plot ROC data
roc_df = data.frame(tpr=roc_curve$sensitivities, fpr=1-roc_curve$specificities)
ggplot(roc_df, aes(fpr, tpr)) +
  geom_line(color=rgb(0, 0, 1, alpha = 0.3)) +
  coord_fixed() +
  labs(title = sprintf("ROC")) + xlab("FPR") + ylab("TPR") +
  geom_point(aes(x=1-cutoff["specificity"], y=cutoff["sensitivity"]), color = "red")
ggsave(file.path(model_dir, paste("roc.png", sep = "")))

# Visualize data and density
df <- data.frame(y_test, y_predict)
df <- df[order(df$Error),]
df["Anomaly"] <- df$Class == 1
df["Id"] <- 1:nrow(df)
ggplot(df, aes(x=Id, y=Error, col=Anomaly)) +
  geom_point(alpha = 0.5) +
  geom_rug()
ggsave(file.path(model_dir, paste("data.png", sep = "")))
ggplot(df, aes(x=Error, fill=Anomaly)) +
  geom_density(alpha = 0.5)
ggsave(file.path(model_dir, paste("density.png", sep = "")))