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
  dfs = list()
  for (symbol in symbols) {
    fp = paste0(cwd, '/data/symbol/', symbol, '.csv')
    if(file.exists(fp)) {
        data = Dataframe(fp, 'csv')
        dfs[[symbol]] = data$get_df()
    }
  }
  
  ## return dataset
  return(dfs)
}
