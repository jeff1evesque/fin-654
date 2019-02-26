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
  context = hash()
  for (i in 1:length(fps)) {
    context[i] = Dataframe(fps[i])
  }

  ## return company name
  return()
}
