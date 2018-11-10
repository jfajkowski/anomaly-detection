#3-layers autoencoder config file

#general
batchSize <- 256
learningRate <-  1e-06
maxEpochs <- 100
lossFunction <- "mean_squared_error"


#The first hidden layer config - input layer
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


FLAGS_FIVE <-flags(
  flag_integer("second_units", 26),
  flag_integer("third_units", 12),
  flag_integer("fourth_units", 26),

  flag_integer("batch_size", 256),
  flag_numeric("learning_rate", 1e-06),
  flag_integer("max_epoch", 100),
  
  flag_string("data_dir", "data")
  
)