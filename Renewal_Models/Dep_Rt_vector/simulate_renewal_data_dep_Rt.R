setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Infectious Disease Modelling/codes/renewal model/Rt dep vector")
#load libs
install.packages("EpiEstim")
library(EpiEstim)

#initialise Rt and i0
Rt <- c(1,3,6,4,2,0.8)
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
  max_Rt<- length(Rt)
  
  
  for (t in 2:ts) {
    Rt_index <- min(ceiling(t/6),max_Rt)
    current_Rt<-Rt[Rt_index]
    lambda <- 0
    for (s in 1:min(t, S)) {
      if (t-s > 0) {
        lambda = lambda+(serial_interval[s] * incidence[t-s])
      }
    }
    incidence[t] <- rpois(1, current_Rt * lambda)
  }
  return(incidence)
}

ts <-100
incidence <- simulate(Rt, i0, serial_interval, ts)

config <- make_config(list(mean_si = mu, std_si = sd))
print(config)
res <- estimate_R(incidence, method = "parametric_si", config = config)
res$I
plot(res, legend = FALSE)
write.csv(incidence, file = "simulate_renewal_data_dep_Rt.csv", row.names = FALSE)
