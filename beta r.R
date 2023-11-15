setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Sumali Mam/codes")

install.packages("rstan")
library(rstan)

remove.packages("rstan")
if (file.exists(".RData")) file.remove(".RData")
install.packages("StanHeaders", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
example(stan_model, package = "rstan", run.dontrun = TRUE)

# Compile the Stan model
stan_model <- stan_model('Beta Estimation (Stan).stan')

# Data list
data_list <- list(T = length(incidence),
                  N = 1000,  # Adjust as needed
                  t_infected = 5,  # Adjust as needed
                  incidence = incidence,
                  gamma = 0.1  # Adjust as needed
)

# Run MCMC
fit <- sampling(stan_model, data = data_list, chains = 4, iter = 1000)

# Print summary of the MCMC results
print(fit)

# Plot the MCMC chains
plot(fit)
