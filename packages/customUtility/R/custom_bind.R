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
    df = data.frame()

    ##
    ## Note: names(d)[1], obtains the list name
    ##
    for (d in data) {
      df[[names(d)[1]]] = d
    }
    result=df
  } else {
    result=cbind()
    for (d in data) {
      result=cbind(result, matrix(d[1:max_length]))
    }
  }

  return(result)
}
