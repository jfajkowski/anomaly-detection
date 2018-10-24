#3-layers autoencoder config file

#input data file
#source(__inputDataFilePath__)

#test data - should be deleted
x_train <- c(1:41)
y_train <- c(1)
x_test <- c(1:41)
y_test <- c(1)

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
SecodnLayerUnits <- 15

#The first hidden layer config
thirdLayerActivation = firstLayerActivation
ThirdLayerUnits <- layerOneUnits