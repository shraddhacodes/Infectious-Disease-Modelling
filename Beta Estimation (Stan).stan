functions {
  real[] SIR(real t, //time
  real[] y, //system state
  real[] theta, //parameters
  real[] x_r, //real data
  int[] x_i) //integer data 
  {
    //define real data 
    real gamma = x_r[1];
    
    // define parameters
    real beta = theta[1];
    
    //define integer data 
    int n_recov = x_i[1]; 
    int S0 = x_i[2]; 
    int n_days = x_i[3];
    
    //define compartments
    real S; real I; real R;
    
    //define states
    real dS_dt; real dI_dt; real dR_dt;
    
    //define FOI
    real FOI;
    
    //initial conditions
    S = y[1]; I = y[2]; R = y[3];
    
    //calculate FOI
    FOI = beta * I / S0;  
    
    //ODE
    dS_dt = -FOI * S;
    dI_dt = FOI * S - gamma * I;
    dR_dt = gamma * I;
    return {dS_dt, dI_dt, dR_dt};
  }
}

data {
  int<lower=1> n_ts;       // no of days observed
  int<lower=1> n_data;    //no of data points to fit to
  real<lower=0> gamma;   // recovery rate
  int y[n_data];        // data, reported incidence each day
  real ts[n_ts];       // 1:n_days
  int<lower=1> n_pop;           // Total population size
  int<lower=1> n_recov;         // Number of recovered individuals
  int<lower=1> I0;             // Initial infectious population
}

transformed data {
  int S0 = n_pop - n_recov-I0;
  real x_r[1] = {gamma};
  int x_i[3] = {n_recov, S0,n_data};
}

parameters {
  real<lower=0> beta;
}

transformed parameters {
  real y_hat[n_ts, 3];
  real theta[1] = {beta};
  real init[3] = {n_pop - n_recov - I0, I0, n_recov};  
  real lambda[n_ts];
  real generation_interval_distribution[n_ts];
  real lambda_fit[n_data];
  real initial_time = 0 ;
  y_hat = integrate_ode_rk45(SIR, init, initial_time, ts, theta, x_r, x_i);
  for (t in 1:n_ts) {
    lambda[t] = beta * y_hat[t, 2] / S0;
    generation_interval_distribution[t] = gamma * exp(-gamma * t);
  } 
  
  for (t in 1:n_ts) lambda_fit[t] = lambda[t] + 0.0001;
  
}
  
model {
  target += poisson_lpmf(y | lambda_fit);
  beta ~ normal(2.2, 1);
}

generated quantities {
  real R_0 = beta / gamma;
}


