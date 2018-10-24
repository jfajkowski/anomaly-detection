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
momentum <- 0.1
maxEpochs <- 100
lossFunction <- "huber"
if(lossFunction == "huber" | lossFunction == "pseudo-huber"){
  huberCutOff <- 3
}
L2Regularization <- 1e-3



#The first hidden layer config
firstLayerUnits <- 30

#The first hidden layer config
SecodnLayerUnits <- 15

#The first hidden layer config
ThirdLayerUnits <- layerOneUnits