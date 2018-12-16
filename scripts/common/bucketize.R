bucketize <- function(x, n) {
  min <- min(x)
  max <- max(x)
  
  bucket_size = (max - min) / n
  
  k <- rep(min, n+1) + (0:n) * bucket_size
  
  labels = intToBin(0:(n-1))
  
  x <- cut(x, k, labels=labels, include.lowest = TRUE)
}

