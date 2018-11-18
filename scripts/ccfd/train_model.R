train <- read.csv(file = "./data/ccfd/processed/train.csv", header = TRUE, sep = ",", row.names = NULL)

X_train <- as.matrix(train[1:30])
y_train <- as.matrix(train[31])

model <- keras_model_sequential()
model %>%
  layer_dense(units = 10, activation = 'relu', input_shape = ncol(X_train)) %>%
  layer_dense(units = ncol(X_train), activation = 'sigmoid')
summary(model)

model %>% compile(
  loss = "mean_squared_error",
  optimizer = optimizer_adam(lr = 1e-03),
  metrics = "mse")

model %>% fit(
  x = X_train,
  y = X_train, 
  epochs = 30, 
  batch_size = 4096,
  validation_split = 0.1)

save_model_hdf5(model, filepath = format(Sys.time(), "./models/ccfd/%Y%m%dT%H%M%S.hdf5"))
