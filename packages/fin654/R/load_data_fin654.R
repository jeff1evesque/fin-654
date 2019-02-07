##
## load_data.R, loads sourcefile(s) into dataframe.
##
## Note: this script requires the following packages:
##
##     - data.table
##     - RJSONIO
##
load_data_fin654 = function(fp1, fp2, spath) {
  ##
  ## load source(s) into dataframe
  ##
  ## @list.files, runs on the current directory
  ##
  ## source python
  source_python(spath)
  
  ## load dataset
  data1 = Dataframe(fp1)
  data2 = Dataframe(fp2)
  
  ## manipulate dataset
  data1$remove_cols(c(
    'alternative name',
    'YEAR',
    'interesting story',
    'Unnamed: 10',
    'DATA SENSITIVITY',
    '1st source link',
    '2nd source link',
    'DISPLAYED RECORDS',
    'source name',
    'SECTOR'
  ))
  
  data2$remove_cols(c(
    'City',
    'State',
    'Type of organization',
    'Description of incident',
    'Information Source',
    'Source URL',
    'Latitude',
    'Longitude',
    'Year of Breach'
  ))
  
  data1$split_remove('story', '.')
  data1$rename_col(
    paste(
      '{',
      '"Entity": "company",',
      '"records lost": "records",',
      '"story": "date",',
      '"METHOD": "type"',
      '}'
    )
  )
  data2$rename_col(
    paste(
      '{',
      '"Date Made Public": "date",',
      '"Company": "company",',
      '"Type of breach": "type",',
      '"Total Records": "records"',
      '}'
    )
  )
  
  data1$reformat_date('date')
  data2$reformat_date('date')
  data1$drop_na()
  data2$drop_na()
  data1$to_lower()
  data2$to_lower()
  data1$to_integer('records')
  data2$to_integer('records')
  
  ## return dataset
  return(rbind(data1$get_df(), data2$get_df()))
}
