##
## arima_forecast.R, generate arima model plot.
##

plot_arima = function(model, index) {
  dates = model$get_index()

  ##
  ## @index, 1 indicates train, 2 indicates test.
  ##
  if (index == 1) {
    title = 'Train'
    actual = model$get_data(key='total', key_to_list='True')[[1]]

    ## dataframes for multi-timeseries plot
    df = data.frame(
      date=head(c(dates), length(actual)),
      actual=actual
    )

    ## initialize ggplot
    g = ggplot(df, aes(x=date)) +
      geom_line(aes(y=actual, group=1), color='#FC4E07') +
      ggtitle(paste0(title, 'ing Data')) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  } else {
    title = 'Test'
    actual = model$get_differences()[[1]]
    predicted = model$get_differences()[[2]]

    ## dataframes for multi-timeseries plot
    df = data.frame(
      date=tail(c(dates), length(predicted)),
      predicted=predicted,
      actual=actual
    )
    
    ## initialize ggplot
    g = ggplot(df, aes(x=date)) +
      geom_line(aes(y=predicted, group=1), color='#00AFBB') +
      geom_line(aes(y=actual, group=1), color='#FC4E07') +
      ggtitle(paste0(title, 'ing Data')) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  }

  return(g)
}
