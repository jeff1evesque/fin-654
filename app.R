##
## app.R, shiny application.
##

## set project cwd: only execute in RStudio
if (nzchar(Sys.getenv('RSTUDIO_USER_IDENTITY'))) {
  cwd = dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(cwd)
} else {
  cwd = getwd()
}

## utility functions
devtools::install_local(paste0(cwd, '/packages/customUtility'))
devtools::install_local(paste0(cwd, '/packages/fin654'))
library('customUtility')

## load packages
load_package(c(
  'reticulate',
  'shiny',
  'shinydashboard',
  'fin654',
  'hash',
  'Quandl',
  'ggplot2',
  'xts'
))
py_install(c('pandas'))

## dashboard
header = dashboardHeader(title = 'Financial Analytics 654')
sidebar = dashboardSidebar(
  sidebarMenu(
    id = 'tab',
    menuItem(
      'Dashboard',
      tabName = 'dashboard',
      icon = icon('dashboard')
    ),
    menuItem(
      'Analysis',
      tabName = 'analysis',
      icon = icon('bar-chart-o'),
        menuSubItem('Time series', tabName = 'stock-time-series'),
        menuSubItem('Sub-item 2', tabName = 'subitem2')
    ),
    menuItem(
      'Source Code',
      icon = icon('send',lib='glyphicon'),
      href = 'https://github.com/jeff1evesque/fin-654'
    )
  )
)
body = dashboardBody(
  fluidRow(
    conditionalPanel(
      condition = 'input.tab == "stock-time-series"',
      box(plotOutput('plot1', height = 250))
    ),
    conditionalPanel(
      condition = 'input.tab == "dashboard"',
      box(plotOutput('plot2', height = 250))
    )
  )
)

## user interface: controls the layout and appearance of your app
ui = dashboardPage(
  header,
  sidebar,
  body,
  skin='green'
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
    paste0(cwd, '/data/symbol/'),
    paste0(cwd, '/python/dataframe.py'),
    c('PROVIDE-QUANDL-APIKEY', '2007-01-01')
  )

  ## conditionally render
  for (symbol in df.ts) {
    symbol$date = as.Date(symbol$date, '%M-%d-%Y')
    symbol.ts = reactive({
      xts(symbol$open, order.by = symbol$date)
    })

    output$plot1 = renderPlot({
      plot(symbol.ts())
    })
  }
}

## shiny application
shinyApp(ui = ui, server = server)
