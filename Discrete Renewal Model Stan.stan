//Discrete Renewal Equation Model (Stan)

data {
  int<lower=1> pop_size;          // Population size
  real<lower=0> I_init;           // Initial number of infectious individuals
  real<lower=0> R0;               // Basic reproduction number
  int<lower=1> GI_span;           // Maximum value for GI
  real<lower=0> GI_mean;          // Mean for GI
  real<lower=0> GI_var;           // Variance for GI
  int<lower=0, upper=1> GI_type;  // Type of distribution for the GI: 0 for 'pois', 1 for 'nbinom'
  int<lower=1> horizon;           // Time horizon of the simulation
}


parameters {
  real<lower=0> I[horizon + 1];  // Infectious individuals over time
}

model {
  // Priors
  
  // Likelihood
  I[1] ~ normal(I_init, 1);  // Initial condition

  for (t in 2:(1 + horizon)) {
    real z = 0;
    for (j in 1:min(GI_span, t - 1)) {
      real GI_j;
      if (GI_type == 0) {
        // 'pois' distribution
        GI_j = poisson_lpmf(j | GI_mean);
      } else {
        // 'nbinom' distribution
        GI_j = neg_binomial_2_lpmf(j | GI_mean^2 / (GI_var - GI_mean), GI_mean);
      }
      z = z + exp(GI_j) * I[t - j];
    }
    I[t] ~ normal(R0 * z, 1);  // Likelihood of infectious individuals at time t
  }
}

