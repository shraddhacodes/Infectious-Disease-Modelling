setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Sumali Mam/codes")

install.packages("rstan")
library(rstan)

#remove.packages("rstan")
#if (file.exists(".RData")) file.remove(".RData")
#install.packages("StanHeaders", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
#install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
#example(stan_model, package = "rstan", run.dontrun = TRUE)

# Compile the Stan model
stan_model <- stan_model('Beta Estimation 2 (Stan).stan')

# Set the number of chains and iterations
chains <- 4
iterations <- 2000

# Prepare data list
data_list <- list(
  n_ts = 10,          # Number of time steps
  n_data = 10,        # Number of data points
  gamma = 0.1,        # Recovery rate
  y = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),  # Observed data
  ts = seq(0, 9, 1),   # Time points
  n_pop = 1000,       # Total population size
  n_recov = 50,       # Number of recovered individuals
  I0 = 5              # Initial infectious population
)

# Run MCMC
stan_output <- sampling(stan_model, data = data_list, chains = chains, iter = iterations)

# Print summary statistics and diagnostics
print(stan_output)

# Extract and plot posterior distributions
posterior <- extract(stan_output)
pairs(posterior)

# Extract and summarize specific parameters
summary(posterior$beta)
summary(posterior$R_0)
