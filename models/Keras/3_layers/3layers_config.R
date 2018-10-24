#3-layers autoencoder config file

#general
batchSize <- 256
learningRate <-  1e-06
maxEpochs <- 100
lossFunction <- "mean_squared_error"


#The first hidden layer config
firstLayerActivation = "tanh"
firstLayerUnits <- 30

#The first hidden layer config
secondLayerActivation = firstLayerActivation
SecondLayerUnits <- 15

#The first hidden layer config
thirdLayerActivation = firstLayerActivation
ThirdLayerUnits <- firstLayerUnits