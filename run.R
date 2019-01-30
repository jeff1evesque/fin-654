##
## run.R, entrypoint script
##

## set project cwd: only execute in RStudio
if (nzchar(Sys.getenv('RSTUDIO_USER_IDENTITY'))) {
  cwd <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(cwd)
}

## utility functions
devtools::install_local(paste0(cwd, '/packages/customUtility'))
library('customUtility')

## load packages
load_package(c('reticulate'))
py_install('pandas')

## source python
source_python(paste0('python/dataframe.py '))

## load dataset
df1 = Dataframe(paste0(cwd, '/data/data-breaches.csv'))
df2 = Dataframe(paste0(cwd, '/data/Privacy_Rights_Clearinghouse-Data-Breaches-Export.csv'))

## manipulate dataset

## return dataset
df_breaches1 = df1$get_df()
df_breaches2 = df2$get_df()
