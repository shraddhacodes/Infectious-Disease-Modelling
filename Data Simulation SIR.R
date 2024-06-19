#SIR Modelling (basic)

#library:
install.packages("deSolve")
library(deSolve)
install.packages("reshape2")
library(reshape2)
install.packages("ggplot2")
library(ggplot2)

#inputs

initP<-50000000# population size


initI<-100 # Infectious
initR<-0 # Immune
initS<-initP-initI-initR # Susceptible (non-immune)
R0=12
state <- c(S = initS, I = initI,R = initR)
parameters <- c(beta<-R0*1/7 , 
                gamma<-1/7)
beta

#Timeframe
t_start <- 0
t_stop <- 25
times <- seq(t_start, t_stop)

#Model
sir_model<-function(time, state, parameters){
  with(as.list(c(state,parameters)),{
    N<-S+I+R
    lambda=beta*(I/N)
    dS=-lambda*S
    dI=lambda*S-gamma*I
    dR=gamma*I
    return(list(c(dS,dI,dR)))
    })
}



#outs

#Calculation of differential equations

out<-ode(y=state,times=times,func=sir_model,parms=parameters)

# total population
pop<-out[,"S"]+out[,"I"]+out[,"R"]
time<-out[,"time"]
# weekly incidence
inc <- 0*time
inc[2:length(time)]<- -(out[2:length(time),"S"]-out[1:(length(time)-1),"S"])


# generate simulated data
incdat1<-rnbinom(rep(1,length(times)), size= 200, mu=inc) #generate data from negative binomial process

# COMPARING THE MODEL out WITH DATA
par(mfrow=c(1,1))
yl <- c(0,max(incdat1,inc))
plot(time,inc,type='l',lwd=3,main = "Incidence",xlab = "Time in years",ylab="New reported cases per day",ylim=yl,col='grey')
points(time,incdat1,pch=19,col='black')

x <- matrix(0,nrow=length(time),ncol=2)

x[,1]<-time
x[,2]<-incdat1
# create data file
write.csv(x, file = "new_data.csv", row.names = FALSE)
