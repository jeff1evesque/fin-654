##
## rnn_forecast.R, generate lstm model plot.
##

plot_lstm = function(model, index) {
  ##
  ## @index, 1 indicates train, 2 indicates test.
  ##
  if (index == 1) {
    title = 'Train'
  } else {
    title = 'Test'
  }

  dates = model$get_index()
  actual = model$get_actual()[[index]]
  predicted = model$predict_test()[[index]]
  
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
    ggtitle(paste0(title, 'ing Data')) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))

  return(g)
}
