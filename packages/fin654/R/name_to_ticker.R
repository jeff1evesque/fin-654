##
## name_to_ticker.R, convert company name to ticker.
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
  df = Dataframe(fps[1])
  if length(fps > 1) {
    for (i in 1:length(fps)) {
      df = merge(df, Dataframe(fps[i]))
    }
  }

  ## manipulate dataset
  df$remove_cols(c(
    'LastSale',
    'MarketCap',
    'ADR TSO',
    'IPOyear',
    'Summary Quote'
  ))
  df$to_lower()

  ## convert name to ticker

  ## return company name
  return()
}
