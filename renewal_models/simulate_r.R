setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Sumali Mam/codes/renewal model")

install.packages("rstan")
#Load the libs
library(rstan)
install.packages("readr")
library(readr)


# Call the Stan model
stan_model <- stan_model('simulate_ren.stan')

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
inc_data <- read_csv("renewal_simulated_incidence.csv")
cases<-round(inc_data[[1]])
data_list <- list(
  ts=length(cases),
  cases=cases,
  i0=cases[1],
  serial_interval=serial_interval,
  S = length(serial_interval)
)
fit <- sampling(stan_model, data = data_list, iter = 2000, chains = 4)

print(fit)
