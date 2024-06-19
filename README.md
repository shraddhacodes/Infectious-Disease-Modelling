# Infectious Disease Modelling 

## Simple-SIR R File
- **Description:** A R file for generating incidence data using compartmental modeling (deSolve) of the SIR (Susceptible-Infectious-Recovered) model.
- **File Name:** `Data Simulation SIR.R`

## Beta Estimation (SIR Model)
- **Description:** 1) R file utilizing the Beta Estimation Stan model. Bayesian inference is used to sample from the posterior distribution of the parameters via Markov Chain Monte Carlo (MCMC).
- Stan code written to estimate the transmission rate (beta) given the recovery rate (gamma) and incidence rate data.
- Derive Generation Interval Data (Renewal Modelling).
- **File Names:** `Beta Estimation R code.R` `Beta_Estimation.stan`

## Discrete Renewal Equation Modelling
- **Description:** Poisson / NB discrete modelling for renewal equation modelling techniques.
- **File Name:** `Discrete Renewal Model.R` `Discrete Renewal Model Stan.stan`

