library(keras)
library(OptimalCutpoints)
library(caret)
library(pROC)
library(ggplot2)

source("./scripts/common/normalization.R")

test <- read.csv(file = "./data/ccfd/scaled/test.csv", header = TRUE, sep = ",", row.names = NULL)
model <- load_model_hdf5("./models/ccfd/3_layers/model.hdf5")

X_test <- as.matrix(subset(test, select = -c(Class)))
y_test <- as.matrix(subset(test, select = c(Class)))

X_predict <- model %>% predict(X_test)
y_predict <- as.matrix(normalize_min_max(apply(abs(X_test - X_predict), 1, function(x) sum(x) / length(x))))
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

# Visualize data and density
df <- data.frame(y_test, y_predict)
df <- df[order(df$Error),]
df["Anomaly"] <- df$Class == 1
df["Id"] <- 1:nrow(df)
ggplot(df, aes(x=Id, y=Error, col=Anomaly)) + 
  geom_point(alpha = 0.5) +
  geom_rug()
ggplot(df, aes(x=Error, fill=Anomaly)) +
  geom_density(alpha = 0.5)
