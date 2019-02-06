##
## app.R, shiny application.
##

## set project cwd: only execute in RStudio
if (nzchar(Sys.getenv('RSTUDIO_USER_IDENTITY'))) {
  cwd = dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(cwd)
}

## utility functions
devtools::install_local(paste0(cwd, '/packages/customUtility'))
library('customUtility')

## load packages
load_package(c('reticulate', 'shiny'))
py_install('pandas')

## source python
source_python(paste0('python/dataframe.py'))

## load dataset
data1 = Dataframe(paste0(cwd, '/data/data-breaches.csv'))
data2 = Dataframe(paste0(cwd, '/data/Privacy_Rights_Clearinghouse-Data-Breaches-Export.csv'))

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
df = rbind(data1$get_df(), data2$get_df())

## user interface: controls the layout and appearance of your app
ui = fluidPage(
  titlePanel('Tabsets'),
  sidebarLayout(
    sidebarPanel(
      # Inputs excluded for brevity
    ),

    mainPanel(
      tabsetPanel(
        tabPanel('Plot', plotOutput('plot')),
        tabPanel('Summary', verbatimTextOutput('summary')),
        tabPanel('Table', tableOutput('table'))
      )
    )
  )
)

## server: instructions to build application
server = function(input, output, session) {
  ## Server code here
}

## shiny application
shinyApp(ui = ui, server = server)
