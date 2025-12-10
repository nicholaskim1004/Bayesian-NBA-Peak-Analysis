
data {
  int<lower=1> L; // number of leagues
  int<lower=1> P; // number of pick bins
  int<lower=1> T; // number of tier bins
  int<lower=0> tier_counts[L,P,T]; // stores number of players in specific tier given leage and pick

  vector[L] league_diff_map; // stores the ind to a particular league
  int<lower=0,upper=1> is_hs[L]; 
}

parameters {
  vector[T] alpha;
  
  //hyper parameters
  matrix[L,T] league_effect_raw;
  matrix[P,T] pick_effect_raw;
  
  vector<lower=0>[T] sigma_l;
  vector<lower=0>[T] sigma_p;
  
  vector[T] beta_league_difficulty;
  
  vector[T] beta_hs;
}

transformed parameters {
  matrix[L,T] league_effect;
  matrix[P,T] pick_effect;
  
  for (t in 1:T){
    for (l in 1:L){
      league_effect[l,t] = league_effect_raw[l,t]*sigma_l[t];
    }
    for (p in 1:P){
      pick_effect[p,t] = pick_effect_raw[p,t]*sigma_p[t];
    }
  }
}
  

model {
  alpha ~ normal(0,2);
  
  //hyperprior
  to_vector(league_effect_raw) ~ normal(0,1);
  sigma_l ~ cauchy(0,1.5);
  
  to_vector(pick_effect_raw) ~ normal(0,1);
  sigma_p ~ cauchy(0,1.5);
  
  beta_league_difficulty ~ normal(0, 1);
  
  beta_hs ~ normal(0,1);
  
  //prior

  for (l in 1:L){
    for (p in 1:P){
      vector[T] eta;
      for (t in 1:T){
        eta[t] = alpha[t] + 
        league_effect[l,t] + 
        pick_effect[p,t] +
        beta_league_difficulty[t]*league_diff_map[l] +
        beta_hs[t]*is_hs[l];
      }
      tier_counts[l, p] ~ multinomial(softmax(eta));
    }
  }
  
}

generated quantities {
  simplex[T] prob_tier_new[L,P];
  
  for (l in 1:L){
    for (p in 1:P){
      vector[T] eta;
      for (t in 1:T){
        eta[t] = alpha[t]
               + league_effect[l,t]
               + pick_effect[p,t]
               + beta_league_difficulty[t] * league_diff_map[l]
               + beta_hs[t] * is_hs[l];
      }
      prob_tier_new[l,p] = softmax(eta);
    }
  }
}
