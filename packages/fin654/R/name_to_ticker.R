##
## name_to_ticker.R, convert company name to ticker.
##
## @series, series of company names
## @fps, list of file references
## @spath, python source path
##
name_to_ticker = function(series, fps, spath) {
  ## source python
  source_python(spath)

  ## load data
  df = Dataframe(fps[1])
  if length(fps > 1) {
    for (i in 1:length(fps)) {
      df = merge(df, Dataframe(fps[i]))
    }
  }

  ## convert name to ticker

  ## return company name
  return()
}
