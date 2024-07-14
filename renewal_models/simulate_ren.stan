data {
  int<lower=0> i0;               // Initial number of infectious individuals
  int<lower=1> ts;                // Time of the simulation
  int<lower=0> cases[ts];           // Incidence data
  int<lower=1> S;                  // Length of serial interval distribution
  real<lower=0> serial_interval[S];// Serial interval distribution
}


parameters {
  real<lower=0> R0;                // Initial reproduction number
}

transformed parameters {
  real inc[ts];
  inc[1]=i0;
  real lambda;
  
  for (t in 2:ts) {
    lambda = 0;
    for (s in 1:min(t,S)) {
      if (t-s>0){
        lambda += serial_interval[s] * inc[t-s];
      }
    }
    inc[t]=R0*lambda;
  }
  
}

model{
  R0~normal(10,1);
  cases~poisson(inc);
}

generated quantities {
  real pred_cases[ts];
  pred_cases = poisson_rng(inc);
}

