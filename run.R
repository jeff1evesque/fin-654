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
load_package(c(''))

## create dataframes
df.breaches = load_data(
    paste0(cwd, '/data/data-breaches.csv'),
    remove=TRUE,
    type='csv'
)
