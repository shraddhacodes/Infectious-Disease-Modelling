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
    real i0= theta[2];
    
    //define integer data 
    int  N = x_i[1];
    
    //define compartments
    real S; real I; real R;
    
    //define states
    real dS_dt; real dI_dt; real dR_dt;
    
    //define FOI
    real FOI;
    
    //initial conditions
    S = y[1]; I = y[2]; R = y[3];
    
    //calculate FOI
    FOI = beta * I / N;  
    
    //ODE
    dS_dt = -FOI * S;
    dI_dt = FOI * S - gamma * I;
    dR_dt = gamma * I;
    return {dS_dt, dI_dt, dR_dt};
  }
}

data {
  int<lower=1> n_ts;    //no of days observed
  real<lower=0> gamma;   //recovery rate
  real ts[n_ts];        //1:n days
  int cases[n_ts];     //incidence  
  int N;          
  real t0;             
}


transformed data {
  int x_i[1] = {N};
  real x_r[1] = {gamma};
}


parameters {
  real<lower=0,upper=50> beta;
  real<lower=0,upper=1000> i0;
}

transformed parameters {
  real y[n_ts, 3];
  real <lower=0> init[3];
  real inc[n_ts];
  {
    real theta[2];
    theta[1]=beta;
    theta[2]=i0;
    
    init[1]=N;
    init[2]=i0;
    init[3]=N-i0;
    
    y=integrate_ode_rk45(SIR, init, t0, ts, theta, x_r, x_i);
  }

  for (t in 1:n_ts-1) {    
    inc[t] = -(y[t+1, 1]-y[t, 1]);
  } 
  inc[n_ts]=inc[n_ts-1];
}

model {
  //priors
  beta ~ normal(10,8);
  i0~normal(100,5);
  cases~neg_binomial_2(inc, 200);

}


generated quantities {
  real pred_cases[n_ts];
  pred_cases = neg_binomial_2_rng(inc, 200);
  real R_0 = beta / gamma;
}


