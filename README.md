# Infectious Disease Modelling 
This hithub repository has the codes and data for a simulation based study to compare two infectious disease modelling techniques namely Compartmental Models wherein a simple SIR case has been studied and Renewal Models. 

## compartmental_models
1. R file using deSolve package to simulate SIR data and get incidence data out of it -> Excel file as output
2. Stan File to do the same, but rely on bayesian appraoch and estimate beta, given gamma and R0
3. R file to take the confirm that for given initial inputs in data simulation R file, if we can back calculate and get the same beta estimate for R0 using Stan.
## renewal_models

