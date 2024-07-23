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


#Calculation of differential equations

out<-ode(y=state,times=times,func=sir_model,parms=parameters)

# total population
pop<-out[,"S"]+out[,"I"]+out[,"R"]
time<-out[,"time"]
# weekly incidence
inc <- 0*time
inc[2:length(time)]<- -(out[2:length(time),"S"]-out[1:(length(time)-1),"S"])
inc

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
write.csv(x, file = "simulate_SIR_data.csv", row.names = FALSE)




#OLD CODES (Part 2)
out_full<-melt(as.data.frame(out),id='time')
#The purpose of the melt function is to transform a wide-format data frame into a long-format data frame. 


out_full$proportion<-out_full$value/sum(state)
#sum(state_values)=1000
out_full

#Plot


ggplot(out_full,aes(x=time,y=proportion, color=variable, gropu=variable))+
  geom_line()+
  xlab('Time in days')+
  ylab("Prevalence")+
  labs(color='Compartment',title='SIR Model')

#Effective Reproduction Number
out$reff<-parameters[1]/parameters[2]*out$S/(out$S+out$I+out$R)
out$reff
out$R0 <- parameters[1]/parameters[2]
out$R0
ggplot()+
  geom_line(data=out,aes(x=time,y=reff))+
  geom_line(data=out,aes(x=time,y=R0),color='red')+
  geom_line(data=out,aes(x=time,y=reff),color='green')+
  xlab("Time in days")+
  ylab("Reff")+
  labs(title=paste("Reproduction number levels with: Beta = ",parameters[1],"and Gamma= ",parameters[2]))



#To get incidence data from the infected dataset (To extract the daily incidence data from the out of the number of infected people, you can calculate the difference between the number of infected individuals on consecutive days. This will give you the number of newly infected people on each day. )

# Calculate daily incidence
#out$daily_incidence <- -c(0, diff(out$S))
#out

