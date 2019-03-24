##
## app.R, shiny application.
##
## Note: if anaconda is present on the given system:
##
##       conda install -c r r=3.4.2
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
  'ismev'
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
        menuSubItem('Autocorrelation (ACF)', tabName = 'acf'),
        menuSubItem('Partial ACF', tabName = 'pacf'),
        menuSubItem('GPD', tabName = 'gpd')
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
      box(uiOutput('ts'), width = 12)
    ),
    conditionalPanel(
      condition = 'input.tab == "acf"',
      box(uiOutput('acf'), width = 12)
    ),
    conditionalPanel(
      condition = 'input.tab == "pacf"',
      box(uiOutput('pacf'), width = 12)
    ),
    conditionalPanel(
      condition = 'input.tab == "gpd"',
      box(plotOutput('gpd', width = 12))
    ),
    conditionalPanel(
      condition = 'input.tab == "dashboard"',
      box(plotOutput('ts1', height = 250))
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
    date = as.Date(x$date, '%M-%d-%Y')
    df.ts$open = as.numeric(df.ts$open)
    reactive({
      x[,c('close', 'volume')]
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

  output$gpd = renderPlotly({
    data = na.omit(df.ts)
    data.cbind = cbind(
      df.ts$blw$open,
      df.ts$gpn$open,
      df.ts$ms$open,
      df.ts$dal$open,
      df.ts$sti$open,
      df.ts$fb$open,
      df.ts$mar$open
    )
    data.r = diff(log(as.matrix(data.cbind))) * 100
    price.last = as.numeric(tail(data.r, n=1))
    position.rf = c(1/3, 1/3, 1/3)
    w = position.rf * price.last
    weights.rf = matrix(w, nrow=nrow(data.r), ncol=ncol(data.r), byrow=TRUE)
    loss.rf = -rowSums(expm1(data.r/100) * weights.rf)

    d    =  as.vector(loss.rf) # data is purely numeric
    umin =  min(d)         # threshold u min
    umax =  max(d) - 0.1   # threshold u max
    nint = 100                # grid length to generate mean excess plot
    u = seq(umin, umax, length = nint) # threshold u grid
    loss.excess = loss.rf[loss.rf > u]

    alpha.tolerance = 0.95
    u = quantile(loss.rf, alpha.tolerance , names=FALSE)
    fit = gpd.fit(loss.rf, threshold=u) # Fit GPD to the excesses
    xi.hat = fit$par.ests[["xi"]] # fitted xi
    beta.hat = fit$par.ests[["beta"]] # fitted beta

    n.relative.excess = length(loss.excess) / length(loss.rf) # = N_u/n
    VaR.gpd = u + (beta.hat/xi.hat)*(((1-alpha.tolerance) / n.relative.excess)^(-1*xi.hat)-1)
    ES.gpd = (VaR.gpd + beta.hat-xi.hat*u) / (1-xi.hat)

    print(paste0('n.relative.excess: ', n.relative.excess))
    print(paste0('fit$par.ests: ', fit$par.ests))

    loss.rf = -rowSums(expm1(data.r/100) * weights.rf)
    loss.rf.df = data.frame(
      Loss = loss.rf,
      Distribution = rep("Historical",
                         each = length(loss.rf))
    )

    VaRgpd.text = paste("GPD: Value at Risk =", round(VaR.gpd, 2))
    ESgpd.text = paste("Expected Shortfall =", round(ES.gpd, 2))
    title.text = paste(VaRgpd.text, ESgpd.text, sep = " ")
    loss.plot = ggplot(loss.rf.df, aes(x = Loss, fill = Distribution)) +
      geom_density(alpha = 0.2)
#    loss.plot = loss.plot +
#      geom_vline(aes(xintercept = VaR.gpd), colour = "blue", linetype = "dashed", size = 0.8)
#    loss.plot = loss.plot + geom_vline(aes(xintercept = ES.gpd), colour = "blue", size = 0.8) 
    #+ annotate("text", x = 300, y = 0.0075, label = VaRgpd.text, colour = "blue") + annotate("text", x = 300, y = 0.005, label = ESgpd.text, colour = "blue")
    loss.plot = loss.plot + xlim(0,500) +
      ggtitle(title.text)
    ggplotly(loss.plot)
  })
}

## shiny application
shinyApp(ui = ui, server = server)
