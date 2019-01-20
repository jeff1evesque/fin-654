##
## load_data.R, loads sourcefile(s) into dataframe.
##
## Note: this script requires the following packages:
##
##     - data.table
##     - RJSONIO
##
load_data = function(source, remove=FALSE, type='csv') {
  ##
  ## load source(s) into dataframe
  ##
  ## @list.files, runs on the current directory
  ##
  if (file_test('-f', source)) {
    if (type == 'csv') {
      df = read.csv(source, header = TRUE)
    } else if (type == 'json') {
      df = fromJSON(source)
    }
  } else if (file_test('-d', source)) {
    ## generate path of all files
    files = paste(
        source,
        '/',
        list.files(path=source, pattern=paste('*.', type, sep='')),
        sep=''
    )

    if (type == 'csv') {
      df = do.call(rbind, lapply(files, fread))
    } else if (type == 'json') {
      df = do.call(rbind, lapply(files, fromJSON))
    }

    ##
    ## large matrix to dataframe
    ##
    ## @melt, reformats dataframe, by aggregating repeating columns
    ##
    df = as.data.frame(t(apply(df, 2, unlist)))
    measure = unique(colnames(df))
    df = melt(
        as.data.table(df),
        measure.vars = patterns(measure),
        value.name = measure
    )

    ## remove unnecessary column
    df = df[,-which(names(df) == 'variable')]
  }

  ## optionally remove NA rows
  if (remove) {
    df = df[complete.cases(df),]
  }

  ## return dataframe
  return(df)
}
