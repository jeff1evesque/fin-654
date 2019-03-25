##
## gpd.R, compute general pareto distribution.
##
## @data, provided dataframe used to compute gpd components.
##
## Note: this function requires the 'hash' package.
##
gpd = function(data) {
  data.r = diff(log(as.matrix(data))) * 100
  price.last = as.numeric(tail(data.r, n=1))
  position.rf = c(1/3, 1/3, 1/3)
  w = position.rf * price.last
  weights.rf = matrix(w, nrow=nrow(data.r), ncol=ncol(data.r), byrow=TRUE)
  loss.rf = -rowSums(expm1(data.r/100) * weights.rf)
    
  d    =  as.vector(loss.rf)          # data is purely numeric
  umin =  min(d)                      # threshold u min
  umax =  max(d) - 0.1                # threshold u max
  nint = 100                          # grid length to generate mean excess plot
  u = seq(umin, umax, length = nint)  # threshold u grid
  loss.excess = loss.rf[loss.rf > u]
    
  alpha.tolerance = 0.95
  u = quantile(loss.rf, alpha.tolerance , names=FALSE)
  fit = fit.GPD(loss.rf, threshold=u) # Fit GPD to the excesses
  xi.hat = fit$par.ests[['xi']]       # fitted xi
  beta.hat = fit$par.ests[['beta']]   # fitted beta
    
  n.relative.excess = length(loss.excess) / length(loss.rf) # = N_u/n
  VaR.gpd = u + (beta.hat/xi.hat) * (((1-alpha.tolerance) / n.relative.excess)^(-1*xi.hat)-1)
  ES.gpd = (VaR.gpd + beta.hat - xi.hat*u) / (1-xi.hat)
    
  loss.rf = -rowSums(expm1(data.r/100) * weights.rf)
  loss.rf.df = data.frame(
    Loss = loss.rf,
    Distribution = rep(
      'Historical',
      each = length(loss.rf)
    )
  )

  ## bundle results into hash
  return(
    hash(
      'VaR.gpd' = VaR.gpd,
      'ES.gpd' = ES.gpd,
      'loss.rf.df' = loss.rf.df
    )
  )
}
