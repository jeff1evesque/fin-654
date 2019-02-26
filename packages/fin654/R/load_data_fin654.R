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
      '"METHOD": "breach"',
      '}'
    )
  )
  data2$rename_col(
    paste(
      '{',
      '"Date Made Public": "date",',
      '"Company": "company",',
      '"Type of breach": "breach",',
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

  ## replacement lists: 'old' and 'new' lengths must match
  old_val = c(
    'hacked',
    'oops!',
    'unkn',
    'poor security',
    'lost device',
    'port',
    'disc',
    'phys',
    'insd',
    'stat'
  )

  new_val = c(
    'hack',
    'accidental-disclosed',
    'unknown',
    'hack',
    'lost-or-stolen',
    'lost-or-stolen',
    'accidental-disclosed',
    'accidental-disclosed',
    'insider',
    'accidental-disclosed'
  )

  if (length(old_val) == length(new_val)) {
    for (i in 1:length(new_val)) {
      data1$replace_val('breach', old_val[i], new_val[i])
      data2$replace_val('breach', old_val[i], new_val[i])
    }
  }
  
  ## return dataset
  return(rbind(data1$get_df(), data2$get_df()))
}
