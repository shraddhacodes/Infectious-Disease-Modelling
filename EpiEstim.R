#In this script, I just ran the EpiEstim tutorial hands on to understand various components to it (https://cran.r-project.org/web/packages/EpiEstim/vignettes/demo.html)

install.packages("EpiEstim")
library(EpiEstim)
install.packages("ggplot2")
library(ggplot2)

# load data
data(Flu2009)

Flu2009$incidence

# serial interval (SI) distribution:
Flu2009$si_distr
plot(Flu2009$si_distr)
# EL/ER show the lower/upper bound of the symptoms onset date in the infector
# SL/SR show the same for the secondary case
# type has entries 0 corresponding to doubly interval-censored data

Flu2009$si_data

#plot
library(incidence)
plot(as.incidence(Flu2009$incidence$I, dates = Flu2009$incidence$dates))

#Estimating R on sliding weekly windows, with a parametric serial interval
res_parametric_si <- estimate_R(Flu2009$incidence, 
                                method="parametric_si",
                                config = make_config(list(
                                  mean_si = 2.6, 
                                  std_si = 1.5))
)         

plot(res_parametric_si, legend = FALSE)

#Some other methods include:
#Estimating R with a non parametric serial interval distribution
#Estimating R accounting for uncertainty on the serial interval distribution


                                