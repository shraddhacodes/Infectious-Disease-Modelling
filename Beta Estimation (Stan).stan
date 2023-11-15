data {
  int<lower=1> T;  // Number of time points
  int<lower=1> N;  // Total population size
  int<lower=1, upper=T> t_infected;  // Time point when the first infection occurs
  int<lower=0, upper=100> incidence[T];   // Observed incidence data
  real<lower=0> gamma;  // Recovery rate
}

parameters {
  real<lower=0> beta;  // Transmission rate
  vector<lower=0>[T] S;  // Susceptible individuals over time
  vector<lower=0>[T] I;  // Infectious individuals over time
  vector<lower=0>[T] R;  // Recovered individuals over time
}

model {
  // Priors
  beta ~ normal(0.5, 0.2);  // Prior on transmission rate

  // Initial conditions
  S[1] ~ normal(N - incidence[1], 10);  // Prior on initial susceptible population
  I[1] ~ normal(incidence[1], 10);  // Prior on initial infectious population
  R[1] ~ normal(0, 10);  // Prior on initial recovered population

  // SIR model equations
  for (t in 2:T) {
    S[t] ~ normal(S[t-1] - beta * S[t-1] * I[t-1] / N, 10);
    I[t] ~ normal(I[t-1] + beta * S[t-1] * I[t-1] / N - gamma * I[t-1], 10);
    R[t] ~ normal(R[t-1] + gamma * I[t-1], 10);
  }
// Likelihood function (Poisson distribution for incidence data)
for (t in t_infected:T) {
  target += poisson_lpmf(incidence[t - t_infected + 1] | I[t]);
}

}
generated quantities {
  // Generate simulated incidence data for validation or prediction
  vector[T] incidence_sim;
  for (t in t_infected:T) {
    incidence_sim[t] = poisson_rng(I[t]);
  }
}
