##
## final_dataset.R, finalizes dataset by reducing based on common company,
##     name (i.e. ref$name) for a specified 'column'
##
finalize_dataset = function(df, column, ref, spath) {
  ## source python
  for (p in spath) {
    source_python(p)
  }

  ## load data
  df.final = Dataframe(df, 'False')

  ## dataframe with tickers column
  df.final$subset_on_col(column, ref$name)
  df.final$set_column(column, ref, 'symbol')
  return(df.final$get_df())
}
