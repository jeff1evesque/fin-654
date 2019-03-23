##
## acf.R, produce autocorrelation plot.
##
## Note: this file has the following dependency:
##
##    - ggplot
##    - stats
##
ggacf = function(series, cint) {
  if (missing(cint)) {
    cint = 0.95
  }

  significance_level = qnorm((1 + cint)/2)/sqrt(sum(!is.na(series)))  
  a=acf(series, plot=F)
  a.2=with(a, data.frame(lag, acf))
  g= ggplot(a.2[-1,], aes(x=lag,y=acf)) + 
    geom_bar(stat = 'identity', position = 'identity') +
    xlab('Lag') +
    ylab('ACF') +
    geom_hline(
      yintercept=c(significance_level,-significance_level),
      lty=3
    )
  
  # fix scale for integer lags
  if (all(a.2$lag%%1 == 0)) {
    g= g + scale_x_discrete(limits = seq(1, max(a.2$lag)))
  }
  return(g)
}