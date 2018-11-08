#3-layers autoencoder config file

#general
batchSize <- 256
learningRate <-  1e-06
maxEpochs <- 100
lossFunction <- "mean_squared_error"


#The first hidden layer config
firstLayerActivation = "tanh"
firstLayerUnits <- 41

#The second hidden layer config
secondLayerActivation = firstLayerActivation
SecondLayerUnits <- 26

#The third hidden layer config
thirdLayerActivation = firstLayerActivation
ThirdLayerUnits <- 12

#The fourth hidden layer config
fourthLayerActivation = firstLayerActivation
ThirdLayerUnits <- 26

#The fith layer config
fifthLayerActivation = firstLayerActivation
ThirdLayerUnits <- firstLayerUnits

FLAGS_FIVE <-flags(
  flag_integer("first_units", 41),
  flag_integer("second_units", 26),
  flag_integer("third_units", 12),
  flag_integer("fourth_units", 26),
  flag_integer("fifth_units", 41),
  
  flag_integer("batch_size", 256),
  flag_numeric("learning_rate", 1e-06),
  flag_integer("max_epoch", 100)
  
)

#transform data to matrixes

x_train_matrix <- x_train %>% as.matrix()

x_test_matrix <- x_test %>% as.matrix()

model <- keras_model_sequential()
model %>%
  layer_dense(units = FLAGS_FIVE$first_units, activation = firstLayerActivation, input_shape = ncol(x_train_matrix)) %>%
  layer_dense(units = FLAGS_FIVE$second_units, activation = secondLayerActivation) %>%
  layer_dense(units = FLAGS_FIVE$third_units, activation = thirdLayerActivation) %>%
  layer_dense(units = FLAGS_FIVE$fourth_units, activation = fourthLayerActivation) %>%
  layer_dense(units = FLAGS_FIVE$first_units, activation = fifthLayerActivation) %>%
  layer_dense(units = ncol(x_train_matrix))

summary(model)

model %>% compile(
  loss = lossFunction,
  optimizer = optimizer_adam(lr = learningRate),
  metrics = 'accuracy'
)

checkpoint <- callback_model_checkpoint(
  filepath = "5layers.hdf5", 
  save_best_only = TRUE, 
  period = 1,
  verbose = 1
)

#fidding model with only normal requests.
model %>% fit(
  x = x_train_matrix,
  y = x_train_matrix, 
  epochs = maxEpochs, 
  batch_size = batchSize,
  validation_split = 0.1
)
#   validation_data = list(x_test, y_test)
#  callbacks = list(checkpoint, early_stopping)
