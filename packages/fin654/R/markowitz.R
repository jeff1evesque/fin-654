##
## markowitz.R, compute markowitz model.
##

compute_markowitz = function(data, position.rf) {
  ##
  ## @data, provided dataframe used to compute markowitz components.
  ##
  ## Note: this function requires the 'hash' package.
  ##

  ## dates 4 is working version
##  print(paste0('dates 1: ', data$date))
##  print(paste0('dates 2: ', as.Date(data$date[-1])))
##  print(paste0('dates 3: ', as.Date(data$date)))
##  print(paste0('dates 4: ', as.Date(data$date[-1], format='%m-%d-%Y')))

  ##
  ## compute log difference percent using as.matrix to force numeric type
  ##
  ## Note: the first column (i.e. dates) is removed.
  ##
  data.r = diff(log(as.matrix(data[-1]))) * 100

  ## split into date and rates
##  dates = lapply(data[1], as.Date, format='%m-%d-%Y')
  

  #### jeff
##  print(paste0('dates: ', dates))
##  dates = as.Date(data[1], '%m/%d/%Y')
  size = na.omit(abs(data.r))                                  ## size is indicator of volatility
  direction = ifelse(data.r > 0, 1, ifelse(data.r < 0, -1, 0)) ## another indicator of volatility
  values = cbind(data.r, size, direction)

  ## xts object with row names equal to the dates
##  returns = na.omit(as.xts(values, dates))
  returns = na.omit(xts(values, order.by=as.Date(data$date[-1], format='%m-%d-%Y')))

  R = returns[,1:3] / 100
  quantile_R = quantile(R[,1], 0.95)
  names.R = colnames(R)
  mean.R = apply(R,2,mean)
  cov.R = cov(R)
  sd.R = sqrt(diag(cov.R))                           ## these are in daily percentages
  Amat = cbind(rep(1,3),mean.R)                      ## set the equality constraints matrix
  mu.P = seq(min(mean.R), max(mean.R), length = 300) ## set of 300 possible target portfolio returns
  sigma.P = mu.P                                     ## storage for std dev's of portfolio returns
  weights = matrix(0, nrow=300, ncol = ncol(R))      ## storage for portfolio weights
  colnames(weights) = names.R
  
  ## last prices
  price.last = as.numeric(tail(data[, -1], n=1))

  ## compute the position weights
  w = position.rf * price.last

  ##
  ## FIX: 'w' NEEDS TO BE A MULTIPLE OF NUMBER OF ROWS
  ##

  ## fan these the length and breadth of the risk factor series
  weights.rf = matrix(w, nrow=nrow(data.r), ncol=ncol(data.r), byrow=TRUE)
  loss.rf = -rowSums(expm1(data.r/100) * weights.rf)
  loss.rf.df = data.frame(
    Loss = loss.rf,
    Distribution = rep(
      'Historical',
      each = length(loss.rf)
    )
  )

  for (i in 1:length(mu.P)) {
    bvec = c(1,mu.P[i])                              ## constraint vector
    result = solve.QP(
      Dmat=2*cov.R,
      dvec=rep(0,3),
      Amat=Amat,
      bvec=bvec,
      meq=2
    )
    sigma.P[i] = sqrt(result$value)
    weights[i,] = result$solution
  }

  sigma.mu.df = data.frame(sigma.P = sigma.P, mu.P = mu.P )
  mu.free = .00011                                  ## input value of daily risk-free interest rate
  sharpe = (mu.P-mu.free)/sigma.P                   ## sharpe's ratios

  print(paste0('sharpe: ', sharpe))

  ind = (sharpe == max(sharpe))                     ## maximum Sharpe's ratio
  ind2 = (sigma.P == min(sigma.P))                  ## minimum variance portfolio
  ind3 = (mu.P > mu.P[ind2])                        ## efficient frontier
  col.P = ifelse(mu.P > mu.P[ind2], 'blue', 'grey')
  sigma.mu.df$col.P = col.P

  ## bundle results into hash
  return(
    hash(
      'sigma.mu.df' = sigma.mu.df,
      'sigma.P' = sigma.P,
      'loss.rf.df' = loss.rf.df,
      'mu.P' = mu.P,
      'col.P' = col.P,
      'mu.free' = mu.free,
      'sd.R' = sd.R,
      'mean.R' = mean.R,
      'names.R' = names.R,
      'ind' = ind,
      'ind2' = ind2
    )
  )
}

plot_markowitz = function(data) {
  ##
  ## @data, must contain same attributes as the return from 'compute_markowitz'.
  ##
  sigma.mu.df = data$sigma.mu.df
  sigma.P = data$sigma.P
  loss.rf.df = data$loss.rf.df
  mu.P = data$mu.P
  col.P = data$col.P
  mu.free = data$mu.free
  sd.R = data$sd.R
  mean.R = data$mean.R
  names.R = data$names.R
  ind = data$ind
  ind2 = data$ind2

  ## generate plot
  p = ggplot(sigma.mu.df, aes(x = sigma.P, y = mu.P, group = 1)) +
    geom_line(aes(colour=col.P, group = col.P)) +
    scale_colour_identity()
  p = p + geom_point(aes(x = 0, y = mu.free), colour = 'red')
  options(digits=4)
  p = p + geom_abline(intercept = mu.free, slope = (mu.P[ind]-mu.free)/sigma.P[ind], colour = 'red')
  p = p + geom_point(aes(x = sigma.P[ind], y = mu.P[ind], pch='*')) 
  p = p + geom_point(aes(x = sigma.P[ind2], y = mu.P[ind2], pch='-')) ## show min var portfolio
  p = p + annotate('text', x = sd.R[1], y = mean.R[1], label = names.R[1]) +
    annotate('text', x = sd.R[2], y = mean.R[2], label = names.R[2]) +
    annotate('text', x = sd.R[3], y = mean.R[3], label = names.R[3])
  return(p)
}
