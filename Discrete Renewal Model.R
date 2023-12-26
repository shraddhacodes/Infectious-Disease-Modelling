#Discrete Renewal Equation Modelling

gi.distrib <- function(type, mean, var, span, x) {
  res <- NULL
  if (type == 'pois') res <- dpois(x = x, lambda = mean)
  if (type == 'nbinom') {
    if (var < mean) stop("For negBinom GI, we must have var>mean")
    res <- dnbinom(x = x, mu = mean, size = mean^2 / (var - mean))
  }
  return(res)
}

# pop_size : Population size.
# I.init : Initial number of infectious individuals.
# R0 : Basic reproduction number.
# GI_span : Maximum value for GI
# GI_mean : Mean for GI
# GI_var : Variance for GI
# GI_type : Type of distribution for the GI. 'pois' or 'nbinom'
# horizon : Time horizon of the simulation.

simulate <- function(pop_size, I.init, R0, GI_span, GI_mean, GI_var, GI_type, horizon) {
  if (length(I.init) == 1) {
    I <- vector()
    S <- vector()
    I[1] <- I.init
    S[1] <- pop_size - I.init
  }
  if (length(I.init) > 1) {
    stop(paste("Parameter I.init must be a scalar, not a vector. Input value is:", I.init))
  }
  for (t in 2:(1 + horizon)) {
    z <- 0
    for (j in 1:min(GI_span, t - 1)) {
      GI_j <- gi.distrib(type = GI_type, mean = GI_mean, var = GI_var, span = GI_span, x = j)
      z <- z + GI_j * I[t - j]
    }
    I[t] <- R0  * z
    S[t] <- pop_size - sum(I[1:t])
  }
  return(list(S = S, I = I))
}
