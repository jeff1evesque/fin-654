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
devtools::install_local(paste0(cwd, '/packages/fin654'))
library('customUtility')

## load packages
load_package(c('reticulate', 'shiny', 'fin654', 'hash'))
py_install('pandas')

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
  df = load_data_fin654(
    paste0(cwd, '/data/data-breaches.csv'),
    paste0(cwd, '/data/Privacy_Rights_Clearinghouse-Data-Breaches-Export.csv'),
    paste0('python/dataframe.py')
  )

  df = name_to_ticker(
    df$company,
    c(
      paste0(cwd, '/data/amex.csv'),
      paste0(cwd, '/data/nasdaq.csv'),
      paste0(cwd, '/data/nyse.csv')
    ),
    paste0('python/name_to_ticker.py')
  )
}

## shiny application
shinyApp(ui = ui, server = server)
