setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Sumali Mam/codes")

install.packages("rstan")
library(rstan)

# Compile the Stan model
stan_model <- stan_model('Beta Estimation 2 (Stan).stan')



# Set the number of chains and iterations
chains <- 4
iterations <- 2000

# Prepare data list
data_list <- list(
  n_ts = 10,          # Number of time steps
  n_data = 10,        # Number of data points
  gamma = 0.5,        # Recovery rate
  y = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),  # Observed data
  ts = seq(1, 10, 1),   # Time points
  n_pop = 1000,       # Total population size
  n_recov = 5,       # Number of recovered individuals
  I0 = 1              # Initial infectious population
)

# Run MCMC
stan_output <- sampling(stan_model, data = data_list, chains = chains, iter = iterations)

# Print summary statistics and diagnostics
print(stan_output)

# Extract and plot posterior distributions
posterior <- extract(stan_output)
# Adjust plot margins
par(mar = c(2, 2, 2, 2))
# Create pairs plot
pairs(posterior)

# Extract and summarize specific parameters
summary(posterior$beta)
summary(posterior$R_0)

#Plots
library(ggplot2)
beta <- extract(stan_output,'beta')[[1]]
qplot(beta)

# Extract the generation interval distribution samples
samples <- extract(stan_output, "generation_interval_distribution")$generation_interval_distribution
samples

# Plot the distribution
plot(density(samples), main = 'Intrinsic Generation Interval Distribution', 
     xlab = 'Time between infection and transmission', ylab = 'Density', col = 'blue')
