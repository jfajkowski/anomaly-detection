library(keras)
library(cloudml)

FLAGS <- flags(
  flag_integer("epochs", 100),
  flag_integer("second_layer_units", 10),
  flag_string("encoder_activation", "relu"),
  flag_string("decoder_activation", "sigmoid")
)

# data_dir <- "./data/ccfd/scaled"
data_dir <- gs_data_dir_local("gs://anomaly_detection_data/ccfd/scaled")
train <- read.csv(file = file.path(data_dir, "train.csv"), header = TRUE, sep = ",", row.names = NULL)

X_train <- as.matrix(train[1:30])

model <- keras_model_sequential()
model %>%
  layer_dense(units = FLAGS$second_layer_units, activation = FLAGS$encoder_activation, input_shape = 30) %>%
  layer_dense(units = 30, activation = FLAGS$decoder_activation)

model %>% compile(
  loss = "mean_squared_error",
  optimizer = optimizer_adam(lr = 1e-03),
  metrics = "mse")

model %>% fit(
  x = X_train,
  y = X_train, 
  epochs = FLAGS$epochs,
  batch_size = 4096)
