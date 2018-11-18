normalize_zero_one <- function(x, min_x, max_x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
