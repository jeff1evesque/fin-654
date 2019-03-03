##
## final_dataset.R, finalizes dataset by reducing based on common 'tickers',
##     for a specified 'column'
##
finalize_dataset = function(df, column, tickers, spath) {
  ## source python
  for (p in spath) {
    source_python(p)
  }

  ## load data
  df.final = Dataframe(df, 'False')

  ## dataframe with tickers column
  df.final$subset_on_col(column, tickers)
  return(df.final$get_df())
}
