################################ CONFIGURATION #####################################
#install packages

library(keras)
library(cloudml)
library('tensorflow')

source("http://www.sthda.com/upload/rquery_cormat.r")


#general
batchSize <- 256
learningRate <-  1e-06
maxEpochs <- 100
lossFunction <- "mean_squared_error"


#The first hidden layer config - input layer

#The second hidden layer config
secondLayerActivation = "tanh"

#The third hidden layer config
thirdLayerActivation = secondLayerActivation

#The fourth hidden layer config
fourthLayerActivation = secondLayerActivation


FLAGS <- flags(
  flag_integer("second_units", 26),
  flag_integer("third_units", 12),
  flag_integer("fourth_units", 26),

  flag_integer("batch_size", 256),
  flag_numeric("learning_rate", 1e-06),
  flag_integer("max_epoch", 10),
  
  flag_string("data_dir", "gs://anomaly_detection_data")
  
)

####################################################################################



################################## DATA PREPATARION ################################

data_dir <- gs_data_dir_local(FLAGS$data_dir)

#setwd("..")
#load train data
#train <- read.csv(file="./data/train_data.csv", header = TRUE,sep=",", row.names= NULL)

####### watch out! the separator type was changed! ########
train <- read.csv(file=file.path(data_dir, "kddcup.data_10_percent.csv"), header = TRUE,sep=";", row.names= NULL)
train['num_outbound_cmds'] = NULL

#load test data
#test <- read.csv(file="./data/test_data.csv", header = TRUE,sep=",", row.names= NULL)
#test['num_outbound_cmds'] = NULL

#extract features and outcome
x_train = train[c(1:40)]
y_train = train[c(41)]
#x_test = test[c(1:40)]
#y_test = test[c(41)]

#principal component analysys (without categorical features)
symbolic_feats <- c('protocol_type', 'service', 'flag', 'land', 'logged_in', 'is_host_login', 'is_guest_login')
pca_train <- x_train[ , !(names(x_train) %in% symbolic_feats)]
pca_train.pca <- prcomp(pca_train,center = TRUE,scale = TRUE)
summary(pca_train.pca)

#normalizing function for training and testing dataset (notice that for both dataset characteristics of x_train are used)
normalize <- function(x) {
  ones = rep(1, nrow(x_train))
  x_mean = ones %*% t(colMeans(x_train))
  x_std = ones %*% t(apply(x_train, 2, sd))
  (x - x_mean) / x_std
}

#one-hot encoding
library(ade4)
library(data.table)
#encode the symbolic features
symbolic_feats = c('protocol_type', 'service', 'flag', 'land', 'logged_in', 'is_host_login', 'is_guest_login')
x_train_rows = nrow(x_train)
#combining traing and test dataset so that they have same column names after one-hot encoding
x_combined = rbind(x_train, x_test)
x_encoded <- data.frame(row.names=1:nrow(x_combined))
for (f in symbolic_feats){
  x_dummy = acm.disjonctif(x_combined[f])
  x_combined[f] = NULL
  x_train[f] = NULL
  
  #store categorical features
  x_encoded = cbind(x_encoded, x_dummy)
}
#normalize the combined dataset without categorical features
normalized <- normalize(x_combined)
#combine normalized and encoded categorical features
x_combined = cbind(normalized, x_encoded)
#split train and test dataset
x_train = x_combined[1:x_train_rows,]
x_test = x_combined[(x_train_rows+1):nrow(x_combined),]

###################################################################################



################################## PREPARE MODEL ##################################
#transform data to matrixes

x_train_matrix <- x_train %>% as.matrix()

x_test_matrix <- x_test %>% as.matrix()

model <- keras_model_sequential()
model %>%
  layer_dense(units = FLAGS$second_units, activation = secondLayerActivation, input_shape = ncol(x_train_matrix)) %>%
  layer_dense(units = FLAGS$third_units, activation = thirdLayerActivation) %>%
  layer_dense(units = FLAGS$fourth_units, activation = fourthLayerActivation) %>%
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
