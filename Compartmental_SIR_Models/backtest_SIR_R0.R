setwd("C:/Users/hp/OneDrive/Desktop/Shraddha laptop backup/Infectious Disease Modelling/codes/simulated sir model")

install.packages("rstan")
library(rstan)
install.packages("readr")
library(readr)

# Compile the Stan model
stan_model <- stan_model('Beta Estimation 2 (Stan).stan')
#Inputs
inc_data <- read_csv("new_data.csv")
cases<-round(inc_data[[2]])
cases<-cases[-1]
N<-50000000
n_ts<-length(cases)
t<-seq(0,25)
t0=0
gamma = 1/7
t<-t[-1]
i0<-100


data_list <- list(n_ts=n_ts,
                  gamma=gamma,
                  ts=t,
                  cases=cases,
                  N = N,
                  i0=i0,
                  t0=t0
                  )


# Set the number of chains and iterations
chains <- 4
niter <- 2000

# Run MCMC
stan_output <- sampling(stan_model, data = data_list, chains = chains, iter = niter)

# Print summary statistics and diagnostics
print(stan_output)


# Extract and plot posterior distributions
posterior <- extract(stan_output)
# Adjust plot margins
par(mar = c(2, 2, 2, 2))

dev.off()
# Extract and summarize specific parameters
summary(posterior$beta)
summary(posterior$R_0)

#Plots
library(ggplot2)
beta <- extract(stan_output,'beta')[[1]]
qplot(beta)

##########################################3
#Checking stan outputs
beta_pred<-rstan::extract(stan_output)$beta
R0_pred<-rstan::extract(stan_output)$R0

library(bayesplot)
mcmc_areas(stan_output,pars = "beta",prob = 0.95)    #95% credible interval 
mcmc_areas(stan_output,pars = "R0",prob = 0.95)      
    

#diagnostic plots
traceplot(stan_output, pars = c( "beta","R0"))
stan_dens(stan_output, pars =  c("beta","R0"), separate_chains = TRUE)

#Plot fitting results
pred_cases_SIR<-rstan::extract(stan_output)$pred_cases
#ggplot
t_start <- 0
t_stop <- 25
times <- seq(t_start, t_stop)[-1]

data<-data.frame(week=times,
                 pred_median=apply(pred_cases_SIR, 2, median),
                 pred_low=apply(pred_cases_SIR,2, function(x) quantile(x,probs=0.025)),
                 pred_upp=apply(pred_cases_SIR,2,function(x) quantile(x,probs=0.975)),
                 obs_cases=cases)
ggplot(data, aes(x=week, y = pred_median)) +
  geom_line(size = 0.5,color= "#00A5CF") +   
  geom_ribbon(aes(ymin=pred_low, ymax=pred_upp), alpha=0.2, colour = NA,fill="#00A5CF")+
  geom_point( aes(week, obs_cases),color="#574AE2",size=1)+
  ylab("incidence") +
  xlab(" time")+
  ggtitle("Model fitting based on SIR")


