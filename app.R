##
## app.R, shiny application.
##
## Note: if anaconda is present on the given system:
##
##       conda install -c r r=3.5.1
##       conda install rstudio
##       conda install -y pandas=0.22.0 --name r-reticulate
##
## Note: some linux machines require additional configuration:
##
##       yum install -y libgcc
##       yum remove gcc
##
## Note: if receiving 'git2r' and 'libssl' errors:
##
##       conda install r-git2r
##
## additional functionality
if (nzchar(Sys.getenv('RSTUDIO_USER_IDENTITY'))) {
  if (!require('rstudioapi')) install.packages('rstudioapi')
  library('rstudioapi')
}

## set project cwd: only execute in RStudio
if (nzchar(Sys.getenv('RSTUDIO_USER_IDENTITY'))) {
  cwd = dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(cwd)
} else {
  cwd = getwd()
}

## utility functions
if (!require('devtools')) install.packages('devtools', repos='http://cloud.r-project.org')
library('devtools')
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
  'stats',
  'QRM',
  'plotly',
  'reshape2',
  'quadprog'
))

##
## keras compatibility requirement:
##
## https://github.com/jeff1evesque/fin-654/issues/14#issuecomment-479725039
##
py_install(c(
  'pandas',
  'keras=2.1.2',
  'scikit-learn',
  'statsmodels'
))

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
      'Exploratory',
      tabName = 'exploratory',
      icon = icon('bar-chart-o'),
        menuSubItem('Time series', tabName = 'stock-time-series'),
        menuSubItem('Autocorrelation (ACF)', tabName = 'acf'),
        menuSubItem('Partial ACF', tabName = 'pacf')
    ),
    menuItem(
      'Analysis',
      tabName = 'analysis',
      icon = icon('bar-chart-o'),
        menuSubItem('General Pareto Distribution', tabName = 'gpd'),
        menuSubItem('Markowitz Model', tabName = 'markowitz'),
        menuSubItem('Arima Forecast', tabName = 'arima_forecast'),
        menuSubItem('RNN Forecast', tabName = 'rnn_forecast')
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
    tags$style(HTML('
      .panel-title {
        padding:0 0 1rem 1.25rem;
        text-decoration:underline;
        text-decoration-color: #d1d1d1;
        margin-top:-1rem;
      }
    ')),
    conditionalPanel(
      condition = 'input.tab == "dashboard"',
      titlePanel('Portfolio Analysis', windowTitle='Portfolio Analysis'),
      box(plotOutput('ts1', height = 250))
    ),
    conditionalPanel(
      condition = 'input.tab == "stock-time-series"',
      titlePanel(
        div(class='panel-title', 'Individual Time Series'),
        windowTitle='Individual Time Series'
      ),
      box(uiOutput('ts'), width = 12)
    ),
    conditionalPanel(
      condition = 'input.tab == "acf"',
      titlePanel('Individual Autocorrelation', windowTitle='Individual Autocorrelation'),
      box(uiOutput('acf'), width = 12)
    ),
    conditionalPanel(
      condition = 'input.tab == "pacf"',
      titlePanel('Individual Partial-Autocorrelation', windowTitle='Individual Partial-Autocorrelation'),
      box(uiOutput('pacf'), width = 12)
    ),
    conditionalPanel(
      condition = 'input.tab == "gpd"',
      titlePanel('Overall General Pareto Distribution', windowTitle='Overall General Pareto Distribution'),
      box(plotlyOutput('gpdOverallOpen'), width = 12),
      box(plotlyOutput('gpdOverallClose'), width = 12),
      box(plotlyOutput('gpdOverallVolume'), width = 12)
    ),
    conditionalPanel(
      condition = 'input.tab == "markowitz"',
      titlePanel('Overall Markowitz Model', windowTitle='Overall Markowitz Model'),
      box(plotlyOutput('markowitz'), width = 12)
    ),
    conditionalPanel(
      condition = 'input.tab == "rnn_forecast"',
      titlePanel('Overall RNN Forecast', windowTitle='Overall RNN Forecast'),
      box(plotlyOutput('rnn_forecast_train'), width = 12),
      box(htmlOutput('rnn_forecast_test_loss'), width = 3),
      box(plotlyOutput('rnn_forecast_test'), width=12)
    ),
    conditionalPanel(
      condition = 'input.tab == "arima_forecast"',
      titlePanel('Overall Arima Forecast', windowTitle='Overall Arima Forecast'),
      box(plotlyOutput('arima_forecast_train'), width = 12),
      box(htmlOutput('arima_forecast_test_loss'), width = 3),
      box(plotlyOutput('arima_forecast_test'), width = 12)
    )
  )
)

##
## user interface: controls the layout and appearance of your app
##
ui = dashboardPage(
  header,
  sidebar,
  body,
  skin='green'
)

##
## server: instructions to build application
##
server = function(input, output, session) {
  ##
  ## @weights are defined as a value of the positions for each risk factor.
  ##     This is used for gpd, and markowitz related computattions.
  ##
  weights = c(1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 1/7)

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

  ##
  ## timeseries assignment requires lapply as a workaround to
  ## ensure unique assignment. Otherwise, last assignment used.
  ##
  ## - https://github.com/rstudio/shiny/issues/532#issuecomment-48008956
  ##
  symbol.ts = lapply(df.ts, function(x, y) {
    x$date = as.Date(x$date, '%M-%d-%Y')
    reactive({
      x[,c('date', 'open')]
    })
  })

  symbol.ts.full = lapply(df.ts, function(x, y) {
    reactive({
      x[,c('close', 'volume')]
    })
  })

  ##
  ## convert list of dataframe to single dataframe
  ##
  data.df = reactive({
    ## flatten nested lists
    df.long = do.call(rbind, df.ts)
    df.long$symbol = gsub('\\..*', '', rownames(df.long))

    ## remove rows with unique date
    df.long = df.long[duplicated(df.long$date), ]

    ## reshape on 'open'
    df.m = melt(df.long, id=c('date', 'symbol'), 'open')
    df.cast = dcast(df.m, date ~ symbol)

    return(df.cast)
  })

  ##
  ## implement rnn prediction
  ##
  forecast.rnn = reactive({
    ## initial dataframe
    source_python(paste0(cwd, '/python/lstm.py'))
    df.rnn = data.df()

    ## column sum of all stocks
    col_size = seq(2, ncol(df.rnn))
    df.rnn[['total']] = rowSums(df.rnn[, col_size], na.rm=TRUE)
    df.rnn = df.rnn[, -col_size]

    ##
    ## create lstm model
    ##
    ## @normalize_key, must match the above 'df.rnn' key.
    ##
    lstm = Lstm(df.rnn, normalize_key='total')
    lstm$train_model()

    ## assess accuracy
    lstm$predict_test()
    return(lstm)
  })

  ##
  ## implement arima prediction
  ##
  forecast.arima = reactive({
    ## initial dataframe
    source_python(paste0(cwd, '/python/arima.py'))
    df.arima = data.df()
    
    ## column sum of all stocks
    col_size = seq(2, ncol(df.arima))
    df.arima[['total']] = rowSums(df.arima[, col_size], na.rm=TRUE)
    df.arima = df.arima[, -col_size]

    ##
    ## create arima model
    ##
    ## @normalize_key, must match the above 'df.rnn' key.
    ##
    arima = Arima(df.arima, normalize_key='total')

    ##
    ## @[[1]], represents train
    ## @[[2]], represents test
    ##
    iterations = length(arima$get_data('total')[[2]])

    ## train arima model
    arima$train_model(iterations)
    return(arima)
  })

  ##
  ## gpd: general pareto distribution
  ##
  data.gpdOverallOpen = reactive({
    local({
      data = na.omit(df.ts)
      data.cbind = custom_bind(c(
        data[['blw']]['open'],
        data[['gpn']]['open'],
        data[['ms']]['open'],
        data[['dal']]['open'],
        data[['sti']]['open'],
        data[['fb']]['open'],
        data[['mar']]['open']
      ))
    })
  })

  data.gpdOverallClose = reactive({
    local({
      data = na.omit(df.ts)
      data.cbind = custom_bind(c(
        data[['blw']]['close'],
        data[['gpn']]['close'],
        data[['ms']]['close'],
        data[['dal']]['close'],
        data[['sti']]['close'],
        data[['fb']]['close'],
        data[['mar']]['close']
      ))
      return(compute_gpd(data.cbind, weights))
    })
  })

  data.gpdOverallVolume = reactive({
    local({
      data = na.omit(df.ts)
      data.cbind = custom_bind(c(
        data[['blw']]['volume'],
        data[['gpn']]['volume'],
        data[['ms']]['volume'],
        data[['dal']]['volume'],
        data[['sti']]['volume'],
        data[['fb']]['volume'],
        data[['mar']]['volume']
      ))
      return(compute_gpd(data.cbind, weights))
    })
  })

  ##
  ## plot timeseries: lapply and 'local({})' workaround ensures
  ##     unique assignment. Otherwise, last plot used.
  ##
  ## - https://github.com/rstudio/shiny/issues/532#issuecomment-48008956
  ##
  ts_plot = lapply(1:length(symbol.ts), function(i) {
    symbol_name = names(symbol.ts)[i]
    plotname = paste0('ts', i)
    local({
      renderPlot({
        ggplot(
          data = symbol.ts[[i]](),
          mapping = aes(x = date, y = open)
        ) +
        geom_line() +
        ggtitle(symbol_name) +
        theme(plot.title = element_text(hjust = 0.5))
      })
    })
  })
  output$ts = renderUI(ts_plot)

  ##
  ## plot autocorrelation
  ##
  acf_plot = lapply(1:length(symbol.ts.full), function(i) {
    symbol_name = names(symbol.ts.full)[i]
    local({
      renderPlot({
        acf.full = acf(symbol.ts.full[[i]]())
        plot(acf.full)
        title(sub = symbol_name)
      })
    })
  })
  output$acf = renderUI(acf_plot)

  ##
  ## plot partial autocorrelation
  ##
  pacf_plot = lapply(1:length(symbol.ts.full), function(i) {
    symbol_name = names(symbol.ts.full)[i]
    local({
      renderPlot({
        pacf.full = pacf(symbol.ts.full[[i]]())
        plot(pacf.full)
        title(sub = symbol_name)
      })
    })
  })
  output$pacf = renderUI(pacf_plot)

  ##
  ## gpd: general pareto distribution showing value at risk and
  ##      expected shortfall.
  ##
  output$gpdOverallOpen = renderPlotly({
    r.gpd = data.gpdOverallOpen()
    ggplotly(plot_gpd(r.gpd, 'GPD Open:'))
  })

  output$gpdOverallClose = renderPlotly({
    r.gpd = data.gpdOverallClose()
    ggplotly(plot_gpd(r.gpd, 'GPD Close:'))
  })

  output$gpdOverallVolume = renderPlotly({
    r.gpd = data.gpdOverallVolume()
    ggplotly(plot_gpd(r.gpd, 'GPD Volume:'))
  })

  ##
  ## markowitz model: placed on efficient frontier
  ##
  output$markowitz = renderPlotly({
    r.markowitz = compute_markowitz(data.df(), weights, length(df.ts))
    ggplotly(plot_markowitz(r.markowitz, length(df.ts)))
  })

  ##
  ## arima: regression timeseries predictions
  ##
  output$arima_forecast_test_loss = renderUI({
    model = forecast.arima()
    val_loss = model$get_mse()
    HTML(paste0('Test MSE: ', val_loss))
  })

  output$arima_forecast_train = renderPlotly({
    model = forecast.arima()
    ggplotly(plot_arima(model, 1))
  })

  output$arima_forecast_test = renderPlotly({
    model = forecast.arima()
    ggplotly(plot_arima(model, 2))
  })

  ##
  ## rnn: use lstm for timeseries predictions
  ##
  output$rnn_forecast_test_loss = renderUI({
    model = forecast.rnn()
    val_loss = model$get_mse()[[2]]
    HTML(paste0('Test MSE: ', val_loss))
  })

  output$rnn_forecast_train = renderPlotly({
    model = forecast.rnn()
    actual = model$get_data('total', key_to_list='True')[[1]]
    predicted = model$get_predict_test()[[1]]
    ggplotly(plot_lstm(model, actual, predicted, 1))
  })

  output$rnn_forecast_test = renderPlotly({
    model = forecast.rnn()
    actual = model$get_data('total', key_to_list='True')[[2]]
    predicted = model$get_predict_test()[[2]]
    ggplotly(plot_lstm(model, actual, predicted, 2))
  })
}

## shiny application
shinyApp(ui = ui, server = server)
