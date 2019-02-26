##
## name_to_ticker.R, convert company name to ticker.
##
## @s, series to match and replace
## @fps, list of file references.
##
name_to_ticker = function(s, fps) {
  ## load data
  context = hash()
  for (i in 1:length(fps)) {
    context[i] = Dataframe(fps[i])
  }

  ## return company name
  return()
}
