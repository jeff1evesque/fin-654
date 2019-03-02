##
## name_to_ticker.R, convert list of company name to list of tickers.
##
## @series, series of company names
## @fps, list of file references
## @spath, python source path
##
name_to_ticker = function(series, fps, spath) {
  ## source python
  for (p in spath) {
    source_python(p)
  }

  ## load data
  data = do.call(rbind,lapply(fps, read.csv))
  df = Dataframe(data)

  ## manipulate dataset
  df.ref$remove_cols(c(
    'LastSale',
    'MarketCap',
    'ADR TSO',
    'IPOyear',
    'Summary Quote'
  ))
  df.ref$to_lower()

  ## convert name to ticker
  adjusted = name_to_ticker(series, df.ref$get_df(), 'name', 'symbol')

  ## return company name
  return(adjusted)
}
