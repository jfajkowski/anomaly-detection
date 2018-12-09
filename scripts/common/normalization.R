normalize_zero_one <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}