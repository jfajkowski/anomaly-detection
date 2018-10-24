#3-layers autoencoder config file

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
ThirdLayerUnits <- firstLayerUnits