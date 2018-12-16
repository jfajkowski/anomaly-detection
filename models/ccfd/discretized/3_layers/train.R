library(keras)
library(cloudml)

FLAGS <- flags(
  flag_integer("epochs", 10),
  flag_integer("second_layer_units", 20),
  flag_string("encoder_activation", "relu"),
  flag_string("decoder_activation", "sigmoid")
)

data_dir <- "./data/ccfd/discretized"
train <- read.csv(file = file.path(data_dir, "train.csv"), header = TRUE, sep = ",", row.names = NULL)

X_train <- as.matrix(train[1:60])

model <- keras_model_sequential()
model %>%
  layer_dense(units = FLAGS$second_layer_units, activation = FLAGS$encoder_activation, input_shape = 60) %>%
  layer_dense(units = 60, activation = FLAGS$decoder_activation)

model %>% compile(
  loss = "mean_squared_error",
  optimizer = optimizer_adam(lr = 1e-03),
  metrics = "mse")

model %>% fit(
  x = X_train,
  y = X_train, 
  epochs = FLAGS$epochs,
  batch_size = 4096)

save_model_hdf5(model, "./models/ccfd/discretized/20181117T1407.hdf5")