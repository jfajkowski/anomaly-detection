require(keras)
require(cloudml)

args <- commandArgs(trailingOnly = TRUE)

model_dir <- args[1]
#model_dir <- "./models/ccfd/normalized_l2/3_layers"

FLAGS <- flags(
  file = paste(model_dir, "/flags.yml", sep = ""),
  flag_integer("batch_size", 4096),
  flag_integer("epochs", 10),
  flag_integer("second_layer_units", 20),
  flag_string("encoder_activation", "relu"),
  flag_string("decoder_activation", "sigmoid"),
  flag_string("data_dir", "./data/ccfd/raw"),
  flag_string("metric", "mse")
)

train <- read.csv(file = file.path(FLAGS$data_dir, "train.csv"), header = TRUE, sep = ",", row.names = NULL)

X_train <- as.matrix(subset(train, select = -c(Class)))

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

save_model_hdf5(model, file.path(model_dir, "model.hdf5"))
