##
## plot.R, generalized ggplot constructions
##
## @data, needs to be a single column dataframe:
##
##        sums
##     a  122
##     b   23
##     c  321
##
## Note: this function requires 'ggplot' package.
##
plot_bar_graph = function(df, y_label, x_label, title) {
  if (missing(title)) {
    title = paste0(y_label, ' vs. ', x_label)
  }

  return(
    ggplot(
      data = df,
      aes(x=rownames(df), y=value, fill=factor(rownames(df)))) + 
      geom_bar(position = 'dodge', stat = 'identity') +
      ylab(y_label) +
      xlab(x_label) +
      theme(
        legend.position='bottom',
        plot.title = element_text(size=15, face='bold')
      ) + 
      ggtitle(title) +
      labs(fill=rownames(df)) +
      guides(fill=guide_legend(title=x_label)
    )
  )
}
