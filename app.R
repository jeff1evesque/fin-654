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
load_package(c('reticulate', 'shiny', 'fin654', 'hash', 'Quandl'))
py_install(c('pandas'))

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
  df = load_security(
    paste0(cwd, '/data/security/data-breaches.csv'),
    paste0(cwd, '/data/security/Privacy_Rights_Clearinghouse-Data-Breaches-Export.csv'),
    paste0(cwd, '/python/dataframe.py')
  )

  tickers = name_to_ticker(
    df$company,
    c(
      paste0(cwd, '/data/stock-exchange/amex.csv'),
      paste0(cwd, '/data/stock-exchange/nasdaq.csv'),
      paste0(cwd, '/data/stock-exchange/nyse.csv')
    ),
    c(paste0(cwd, '/python/dataframe.py'), paste0(cwd, '/python/name_to_ticker.py'))
  )

  df = finalize_dataset(
    df,
    'company',
    tickers,
    c(paste0(cwd, '/python/dataframe.py'))
  )

  df.ts = load_symbol(
    unique(df$symbol),
    paste0(cwd, '/python/dataframe.py'),
    c('PROVIDE-QUANDL-APIKEY', '2007-01-01')
  )
}

## shiny application
shinyApp(ui = ui, server = server)
