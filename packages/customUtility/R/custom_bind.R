##
## custom_bind.R, binds provided input list as either matrix or dataframe.
##
custom_bind = function(data, is_matrix) {
  ## local variables
  dlength = length(data)
  data = na.omit(data)
  if (missing(is_matrix)) {
    return_type = 'dataframe'
  }

  ## max length
  max_length = Inf
  for (i in 1:dlength) {
    max_length = min(max_length, data[[i]])
  }

  ## bind items
  result=cbind()
  if (return_type == 'dataframe') {
    for (i in 1:dlength) {
      result=cbind(result, data.frame(data[[i]][1:max_length]))
    }
  } else {
    for (i in 1:dlength) {
      result=cbind(result, matrix(data[[i]][1:max_length]))
    }
  }

  return(result)
}
