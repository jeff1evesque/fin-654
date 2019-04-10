##
## arima_forecast.R, generate arima model plot.
##

plot_arima = function(model) {
  dates = model$get_index()
  actual = model$get_differences()[[1]]
  predicted = model$get_differences()[[1]]

  ## dataframes for multi-timeseries plot
  df = data.frame(
    date=head(c(dates), length(predicted)),
    predicted=predicted,
    actual=t(actual)
  )
  
  ## generate plots
  g = ggplot(df, aes(x=date)) +
    geom_line(aes(y=predicted, group=1), color='#00AFBB') +
    geom_line(aes(y=actual, group=1), color='#FC4E07') +
    ggtitle('Arima forecast') +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))

  return(g)
}
