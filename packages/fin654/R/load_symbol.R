##
## load_symbol.R, loads specified symbols into timeseries.
##
## Note: this script requires the following packages:
##
##     - hash
##     - quandl
##
load_symbol = function(symbols, basedir, spath, quandl) {
  ##
  ## load source(s) into dataframe
  ##

  ## source python
  source_python(spath)

  ## load dataset
  dfs = list()
  for (symbol in symbols) {
    fp = paste0(basedir, symbol, '.csv')
    if (file.exists(fp)) {
        data = Dataframe(fp, 'csv')
        data$reformat_date('date', '%Y-%m-%d')
        data$date = data[order(data$date),]
        data$reformat_date('date', '%m-%d-%Y')
        dfs[[symbol]] = data$get_df()
    }
    else {
      Quandl.api_key(quandl[0])
      data = Quandl.datatable(
        'WIKI/PRICES',
        ticker=symbol,
        start_date = quandl[1]
      )

      data$reformat_date('date', '%Y-%m-%d')
      data$date = data[order(data$date),]
      data$reformat_date('date', '%m-%d-%Y')

      dfs[[symbol]] = data
    }
  }
  
  ## return dataset
  return(dfs)
}
