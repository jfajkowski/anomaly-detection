library(ggplot2)

source("./scripts/common/normalization.R")
source("./scripts/common/metrics.R")

test <- read.csv(file = "./data/ccfd/processed/test.csv", header = TRUE, sep = ",", row.names = NULL)
model <- load_model_hdf5("./models/ccfd/20181117T1407.hdf5")

X_test <- as.matrix(test[1:30])
y_test <- as.matrix(test[31])

X_predict <- model %>% predict(X_test)

y_predict <- normalize_zero_one(apply(abs(X_test - X_predict), 1, function(x) sum(x) / length(x)))

roc_df <- roc(y_test, y_predict)

ggplot(roc_df, aes(fpr, tpr)) + 
  geom_line(color=rgb(0, 0, 1, alpha = 0.3)) +
  coord_fixed() +
  labs(title = sprintf("ROC")) + xlab("FPR") + ylab("TPR")

