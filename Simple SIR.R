#SIR Modelling (basic)

#library:
install.packages("deSolve")
library(deSolve)
install.packages("reshape2")
library(reshape2)
install.packages("ggplot2")
library(ggplot2)

#inputs
N<-1000 #population
state_values<-c(S=N-1, #susceptible
                I=1,  #infected
                R=0)  #recovered

parameters <- c(beta<- 1/2, #infection rate days ^-1
                gamma<-1/4) #recovery rate days ^-1

#Timeframe
times<-seq(0,100,by=1)

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



#Outputs

#Calculation of differtial equations

output<-as.data.frame(ode(y=state_values,
                          times=times,
                          func=sir_model,
                          parms=parameters))

output


output_full<-melt(as.data.frame(output),id='time')
#The purpose of the melt function is to transform a wide-format data frame into a long-format data frame. 


output_full$proportion<-output_full$value/sum(state_values)
#sum(state_values)=1000
output_full

#Plot

ggplot(data = output, aes(x = time, y = I)) +
  geom_line() +
  xlab("Time in days") +
  ylab("Number of infected") +
  labs(title = "SIR Model")

ggplot(output_full,aes(x=time,y=proportion, color=variable, gropu=variable))+
  geom_line()+
  xlab('Time in days')+
  ylab("Prevalence")+
  labs(color='Compartment',title='SIR Model')

#Effective Reproduction Number
output$reff<-parameters[1]/parameters[2]*output$S/(output$S+output$I+output$R)
output$reff
output$R0 <- parameters[1]/parameters[2]
output$R0
ggplot()+
  geom_line(data=output,aes(x=time,y=reff))+
  geom_line(data=output,aes(x=time,y=R0),color='red')+
  geom_line(data=output,aes(x=time,y=reff),color='green')+
  xlab("Time in days")+
  ylab("Reff")+
  labs(title=paste("Reproductio number levels with: Beta = ",parameters[1],"and Gamma= ",parameters[2]))
  
                
                




