##
## arima_forecast.R, generate arima model plot.
##

plot_arima = function(model, index) {
  ## local variables
  dates = model$get_index()
  scores = model$get_data()

  print(paste0('scores: ', scores))
#  predicted = scores
#  actual = scores

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
