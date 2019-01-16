tpr <- function(y_true, y_pred, threshold) {
  sum(y_pred >= threshold & y_true == 1) / sum(y_true == 1)
}

fpr <- function(y_true, y_pred, threshold) {
  sum(y_pred >= threshold & y_true == 0) / sum(y_true == 0)
}

roc <- function(y_true, y_pred, n = 100) {
  roc <- data.frame(threshold = seq(0,1,length.out=n), tpr=NA, fpr=NA)
  roc$tpr <- sapply(roc$threshold, function(th) tpr(y_true, y_pred, th))
  roc$fpr <- sapply(roc$threshold, function(th) fpr(y_true, y_pred, th))
  return(roc)
}