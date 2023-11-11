#Library:
install.packages("deSolve")
library(deSolve)

# SIR model function
sir_model <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS <- -beta * S * I / N
    dI <- beta * S * I / N - gamma * I
    dR <- gamma * I
    
    return(list(c(dS, dI, dR)))
  })
}

# Negative log-likelihood for beta function
neg_log_likelihood_beta <- function(beta, observed_incidence, initial_state, time_points, gamma) {
  parameters <- c(beta = beta, gamma = gamma)
  ode_result <- ode(y = initial_state, times = time_points, func = sir_model, parms = parameters)
  
  predicted_incidence <- ode_result[, "I"]
  
  # Poisson likelihood
  log_likelihood <- sum(dpois(observed_incidence, lambda = predicted_incidence, log = TRUE))
  
  return(-log_likelihood) 
}

# Example data
time_points <- 1:10
initial_state <- c(S = 990, I = 10, R = 0)
observed_incidence <- c(5, 10, 20, 40, 60, 80, 100, 120, 150, 180)
gamma <- 0.1  # Given recovery rate

# Initial beta value
initial_beta <- 0.3

# Optimize beta using maximum likelihood estimation
optim_result_beta <- optim(par = initial_beta, fn = neg_log_likelihood_beta, 
                           observed_incidence = observed_incidence, initial_state = initial_state, 
                           time_points = time_points, gamma = gamma, method = "L-BFGS-B")

# Extract estimated beta
estimated_beta <- optim_result_beta$par

# Estimated beta
estimated_beta
