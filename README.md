# Infectious Disease Modelling

This GitHub repository contains the code and data for a simulation-based study comparing two infectious disease modelling techniques: Compartmental Models and Renewal Models. 

## Overview

The study aims to analyze and compare the effectiveness of these two techniques using a simple SIR case for Compartmental Models and various scenarios for Renewal Models.

## Compartmental Models

### SIR Model
- **Description**: The SIR (Susceptible-Infected-Recovered) model is a simple compartmental model used in epidemiology to simulate how a disease spreads through a population by means of Suscpetible, Infectious and Recovered compartments in population.
- **Implementation**:
  - The `R` code using `deSolve` is employed to simulate the data.
  - Subsequently, `Stan` code is utilized to back-calculate the transmission rate (\(\beta\)) and the basic reproduction number (\(R_0\)) from the simulated incidence data .

## Renewal Models

### Scenarios
1. **Single \(R_0\)**
   - **Description**: Maintains a constant \(R_0\) value over a specified time period.
   - **Implementation**: The simulated data is backtested using `Stan` to verify the results.
   
2. **Changing \(R_t\) (\(R_{t1}\) and \(R_{t2}\))**
   - **Description**: After 15 days, the \(R_t\) value changes.
   - **Implementation**: The change in \(R_t\) is modeled and the results are validated using `Stan`.
   
3. **Dependent \(R_t\) Vector**
   - **Description**: After 6 days, the \(R_t\) value changes, with the new \(R_t\) value correlated to the previous one.
   - **Implementation**: This scenario simulates a dependent change in \(R_t\) and the results are analyzed using `Stan`.
   
4. **Independent \(R_t\) Vector**
   - **Description**:  After 6 days, the \(R_t\) value changes, with the \(R_t\) values in the vector are uncorrelated.
   - **Implementation**: This scenario models independent changes in \(R_t\) and the simulation data is backtested using `Stan`.

## Repository Structure

```
Infectious-Disease-Modelling/
├── compartmental_models/
│   ├── SIR_Model/
│   │   ├── simulate_data.R
│   │   ├── back_calculate_stan.stan
│   │   └── results/
├── renewal_models/
│   ├── Single_R0/
│   │   ├── simulate_data.R
│   │   ├── back_calculate_stan.stan
│   │   └── results/
│   ├── Rt1_Rt2/
│   │   ├── simulate_data.R
│   │   ├── back_calculate_stan.stan
│   │   └── results/
│   ├── Dependent_Rt/
│   │   ├── simulate_data.R
│   │   ├── back_calculate_stan.stan
│   │   └── results/
│   └── Independent_Rt/
│       ├── simulate_data.R
│       ├── back_calculate_stan.stan
│       └── results/
└── README.md
```

## Requirements

- `R` and `RStudio`
- `deSolve` and `EpiEstim` package for R
- `Stan` for R (`rstan` package)

