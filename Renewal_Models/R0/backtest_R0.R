setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Infectious Disease Modelling/codes/renewal model/R0")

install.packages("rstan")
#Load the libs
library(rstan)
install.packages("readr")
library(readr)


# Call the Stan model
stan_output <- stan_model('stan_renewal_R0.stan')

#Discretize SI fun
discretize_gamma <- function(x, mu, sd) {
  

    shape <- (mu / sd)^2
    scale <-  sd^2/ mu
  
    dis_x <- vector(length=x) 
    for(i in 1:x) {
        dis_x[i] = pgamma(i, shape = shape, scale = scale) - pgamma(i - 1, shape = shape, scale = scale)
  }
  return(dis_x / sum(dis_x))
}

serial_interval=discretize_gamma(x=30, mu=5, sd=2)
plot(serial_interval)
print(serial_interval)

#Data List
inc_data <- read_csv("simulate_renewal_data_R0.csv")
cases<-round(inc_data[[1]])
data_list <- list(
  ts=length(cases),
  cases=cases,
  i0=cases[1],
  serial_interval=serial_interval,
  S = length(serial_interval)
)
fit <- sampling(stan_output, data = data_list, iter = 2000, chains = 4)

print(fit)

#Extract the samples
samples <- extract(fit)
#Extract predicted cases from sample
pred_cases_samples <- samples$pred_cases

#Plot the Predictive Cases
pred_med <- apply(pred_cases_samples, 2, median)
pred_lower <- apply(pred_cases_samples, 2, function(x) quantile(x, 0.025))
pred_upper <- apply(pred_cases_samples, 2, function(x) quantile(x, 0.975))
pred_df <- data.frame(
  time = 1:length(pred_med),
  pred_med = pred_med,
  pred_lower = pred_lower,
  pred_upper = pred_upper,
  observed = data_list$cases
)

library(ggplot2)

ggplot(pred_df, aes(x = time)) +
  geom_line(aes(y = observed), color = "#00A5CF", size = 1) +
  geom_line(aes(y = pred_med),colour="#574AE2") +
  geom_ribbon(aes(ymin = pred_lower, ymax = pred_upper), alpha = 0.2) +
  labs(title = "Posterior Predictive Check for Predicted Cases",
       x = "Time",
       y = "Number of Cases") +
  theme_minimal() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.subtitle = element_text(hjust = 0.5))



