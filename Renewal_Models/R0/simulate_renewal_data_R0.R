#This file simulates data using renewal model for a single R0

setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Infectious Disease Modelling/codes/renewal model/R0")
#load libs
install.packages("EpiEstim")
library(EpiEstim)


#initialise R0 and i0
R0 <- 12 
i0 <- 100  

#discretize gamma function
discretize_gamma <- function(x, mu, sd) {
  
  shape <- (mu / sd)^2
  scale <-  sd^2/ mu
  
  dis_x <- vector(length=x) 
  for(i in 1:x) {
    dis_x[i] = pgamma(i, shape = shape, scale = scale) - pgamma(i - 1, shape = shape, scale = scale)
  }
  return(dis_x / sum(dis_x))  
}

#Call the function: SI distn
mu=5
sd=2
x=30
serial_interval=discretize_gamma(x=x, mu=mu, sd=sd)


#Simulation function
simulate <- function(R0, i0, serial_interval, ts) {
  incidence <- numeric(ts)
  incidence[1] <- i0
  S <- length(serial_interval)
  
  for (t in 2:ts) {
    lambda <- 0
    for (s in 1:min(t, S)) {
      if (t-s > 0) {
        lambda = lambda+(serial_interval[s] * incidence[t-s])
      }
    }
    incidence[t] <- rpois(1, R0 * lambda)
  }
  return(incidence)
}

ts <-25
incidence <- simulate(R0, i0, serial_interval, ts)

config <- make_config(list(mean_si = mu, std_si = sd))
print(config)
res <- estimate_R(incidence, method = "parametric_si", config = config)
res$I
plot(res, legend = FALSE)
write.csv(incidence, file = "simulate_renewal_data_R0.csv", row.names = FALSE)
