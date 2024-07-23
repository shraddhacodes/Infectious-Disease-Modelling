setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Infectious Disease Modelling/codes/renewal model/Rt dep vector")
install.packages("rstan")
#Load the libs
library(rstan)
install.packages("readr")
library(readr)


# Call the Stan model
stan_output <- stan_model('stan_renewal_dep_Rt.stan')

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
inc_data <- read_csv("simulate_renewal_data_dep_Rt.csv")
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
#Extract R from the sample
R_samples <- samples$R
#Extract predicted cases from sample
pred_cases_samples <- samples$pred_cases

#Plot the Rt
R_med <- apply(R_samples, 2, median)
R_lower <- apply(R_samples, 2, function(x) quantile(x, 0.025))
R_upper <- apply(R_samples, 2, function(x) quantile(x, 0.975))
R_df <- data.frame(
  time = 1:length(R_med),
  R_med = R_med,
  R_lower = R_lower,
  R_upper = R_upper
)

library(ggplot2)
ggplot(R_df, aes(x = time)) +
  geom_line(aes(y = R_med), color = "#00A5CF") +
  geom_ribbon(aes(ymin = R_lower, ymax = R_upper), alpha = 0.2,colour=NA,fill="#00A5CF") +
  labs(title = "Dependent Rt ",
       x = "Time",
       y = "Rt") +
  theme_minimal()

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



