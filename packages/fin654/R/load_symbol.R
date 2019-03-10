##
## load_symbol.R, loads specified symbols into timeseries.
##
## Note: this script requires the following packages:
##
##     - hash
##
load_symbol = function(symbols, spath) {
  ##
  ## load source(s) into dataframe
  ##

  ## source python
  source_python(spath)

  ## load dataset
  data = list()
  for (symbol in symbols) {
    data[[symbol]] = Dataframe(paste0(cwd, '/data/symbol/', symbol, '.csv'), 'csv')
  }
  
  ## return dataset
  return(data$get_df())
}
