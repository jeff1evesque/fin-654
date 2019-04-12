##
## rnn_forecast.R, generate lstm model plot.
##

plot_lstm = function(model, act, pred, index) {
  ## local variables
  dates = model$get_index()

  ##
  ## @index, 1 indicates train, 2 indicates test.
  ##
  if (index == 1) {
    title = 'Train'

    ## dataframes for multi-timeseries plot
    df = data.frame(
      date=head(c(dates), length(act)),
      actual=act
    )

    ## generate plots
    g = ggplot(df, aes(x=date)) +
      geom_line(aes(y=actual, group=1), color='#FC4E07') +
      ggtitle(paste0(title, 'ing Data')) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  } else {
    title = 'Test'

    ## dataframes for multi-timeseries plot
    df = data.frame(
      date=tail(c(dates), length(pred)),
      actual=tail(c(act), length(pred)),
      predicted=pred
    )

    ## generate plots
    g = ggplot(df, aes(x=date)) +
      geom_line(aes(y=actual, group=1), color='#FC4E07') +
      geom_line(aes(y=predicted, group=1), color='#00AFBB') +
      ggtitle(paste0(title, 'ing Data')) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  }
  
  return(g)
}
