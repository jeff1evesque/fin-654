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

## create dataframes
df.breaches1 = load_data(
    paste0(cwd, '/data/visualisation-data.csv'),
    remove=TRUE,
    type='csv'
)
df.breaches2 = load_data(
  paste0(cwd, '/data/Privacy_Rights_Clearinghouse-Data-Breaches-Export.csv'),
  remove=TRUE,
  type='csv'
)
