require(keras)
require(cloudml)
require(caret)
require(dplyr)
require(OptimalCutpoints)
require(pROC)
require(PRROC)
require(ggplot2)
require(yaml)
require(e1071)

source("./scripts/common/normalization.R")

data_dir <- "./data/ccfd/scaled"
model_dir <- "./models/ccfd/scaled/3_layers"

FLAGS <- flags(
  file = paste(model_dir, "/flags.yml", sep = ""),
  flag_integer("batch_size", 4096),
  flag_integer("epochs", 10),
  flag_integer("second_layer_units", 20),
  flag_string("encoder_activation", "relu"),
  flag_string("decoder_activation", "sigmoid"),
  flag_string("data_dir", "./data/ccfd/scaled"),
  flag_string("metric", "mse")
)

raw <- read.csv(file = file.path(data_dir, "train.csv"), header = TRUE, sep = ",", row.names = NULL)
y_raw <- as.matrix(subset(raw, select = c(Class)))

columns <- colnames(raw)

folds <- createFolds(y_raw, k = 5)

split_up <- lapply(folds, function(ind, dat) dat[ind,], dat = raw)

results = list()

df_result <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(df_result) <- c("AUC_ROC", "AUC_PR", "Sensitivity", "Accuracy", "Specificity")

for (i in 1:5) {
  
  colnames(split_up[[i]]) <- columns
  
  train <- bind_rows(split_up[-i]) 
  X_train <- as.matrix(subset(train, select = -c(Class)))
  
  test <- split_up[[i]]
  X_test <- as.matrix(subset(test, select = -c(Class)))
  y_test <- as.matrix(subset(test, select = c(Class)))
  
  ### Train model ###
  
  model <- keras_model_sequential()
  model %>%
    layer_dense(units = FLAGS$second_layer_units, activation = FLAGS$encoder_activation, input_shape = ncol(X_train)) %>%
    layer_dense(units = ncol(X_train), activation = FLAGS$decoder_activation)
  
  model %>% compile(
    loss = FLAGS$metric,
    optimizer = optimizer_adam(lr = 1e-03),
    metrics = FLAGS$metric)
  
  model %>% fit(
    x = X_train,
    y = X_train,
    epochs = FLAGS$epochs,
    batch_size = FLAGS$batch_size)
  
  
  ### Evaluate model ###
  
  X_predict <- model %>% predict(X_test)
  if(FLAGS$metric == "mae"){
    y_predict <- as.matrix(normalize_min_max(apply(abs(X_test - X_predict), 1, function(x) sum(x) / length(x))))
  }
  if(FLAGS$metric == "mse"){
    y_predict <- as.matrix(normalize_min_max(apply(((X_test - X_predict)**2), 1, function(x) sum(x) / length(x))))
  }
  
  colnames(y_predict) <- c("Error")
  
  # Calculate PR curve and area under it
  prroc_curve <- pr.curve(scores.class0 = y_predict, weights.class0 = y_test, curve = TRUE)
  cat("Area under PR curve:", prroc_curve$auc.integral, "\n")
  
  # Calculate ROC and area under it
  roc_curve <- roc(as.vector(y_test), as.vector(y_predict))
  cat("Area under ROC curve:", auc(roc_curve), "\n")
  
  # Find optimal cutoff point
  cutoff <- coords(roc_curve, "best", "threshold")
  cat("Optimal cutoff point:", cutoff["threshold"], "\n")
  cfmx <- confusionMatrix(table(y_predict > cutoff["threshold"], y_test == 1))
  
  AUC_ROC <- auc(roc_curve)
  AUC_PR <- prroc_curve$auc.integral
  Sensitivity <- cfmx[["byClass"]][["Sensitivity"]]
  Accuracy <- cfmx[["byClass"]][["Balanced Accuracy"]]
  Specificity <- cfmx[["byClass"]][["Specificity"]]
  
  results_row <- data_frame(AUC_ROC, AUC_PR, Sensitivity, Accuracy, Specificity)
  df_result <- rbind(df_result, results_row)
}



