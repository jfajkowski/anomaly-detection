


library(keras)
library(cloudml)


FLAGS <- flags(
  flag_integer("dense_units1", 128),
  flag_numeric("dropout1", 0.4),
  flag_integer("dense_units2", 128),
  flag_numeric("dropout2", 0.3),
  flag_string("data_dir", "gs://anomaly_detection_data")
)


mnist <- dataset_mnist()
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y

data_dir <- gs_data_dir_local(FLAGS$data_dir)
train <- read.csv(file=file.path(data_dir, "kddcup.data_10_percent.csv"), header = TRUE,sep=";", row.names= NULL)
train['num_outbound_cmds'] = NULL
#load test data
summary(train)
#extract features and outcome
xtest_train = train[c(1:40)]
ytest_train = train[c(41)]


# reshape
dim(x_train) <- c(nrow(x_train), 784)
dim(x_test) <- c(nrow(x_test), 784)
# rescale
x_train <- x_train / 255
x_test <- x_test / 255

y_train <- to_categorical(y_train, 10)
y_test <- to_categorical(y_test, 10)


input <- layer_input(shape = c(784))
predictions <- input %>% 
  layer_dense(units = FLAGS$dense_units1, activation = 'relu') %>%
  layer_dropout(rate = FLAGS$dropout1) %>%
  layer_dense(units = FLAGS$dense_units2, activation = 'relu') %>%
  layer_dropout(rate = FLAGS$dropout2) %>%
  layer_dense(units = 10, activation = 'softmax')

model <- keras_model(input, predictions) %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_rmsprop(lr = 0.001),
  metrics = c('accuracy')
)

history <- model %>% fit(
  x_train, y_train,
  batch_size = 128,
  epochs = 30,
  verbose = 1,
  validation_split = 0.2
)