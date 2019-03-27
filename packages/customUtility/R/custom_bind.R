##
## custom_bind.R, binds provided input list as matrix.
##
custom_bind = function(data, dtype) {
  if (missing(dtype)) {
    dtype = 'matrix'
  }

  max_length = Inf
  for (d in data) {
    max_length = min(max_length, length(d))
  }

  if (typeof(dtype) == 'dataframe') {
    #### CONVERT LARGE LIST TO DATAFRAME WITH CBIND

  } else {
    result=cbind()
    for (d in data) {
      result=cbind(result, matrix(d[1:max_length]))
    }
  }

  return(result)
}
