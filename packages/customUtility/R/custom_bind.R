##
## custom_bind.R, binds provided input list as matrix.
##
custom_bind = function(data) {
  max_length = Inf
  for (d in data) {
    max_length = min(max_length, length(d))
  }

  result=cbind()
  for (d in data) {
    result=cbind(result, matrix(d[1:max_length]))
  }

  return(result)
}
