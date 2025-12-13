data {
  int<lower=1> L; // number of leagues
  int<lower=1> P; // number of pick bins
  int<lower=1> T; // number of tier bins
  int<lower=0> tier_counts[L,P,T];
  vector[L] league_diff_map;
}

parameters {
  vector[T] alpha;

  // hyper parameters
  matrix[L,T] league_effect_raw;            // non-centered
  array[L] matrix[P, T] pick_effect_raw;    // non-centered

  // interaction between league and pick
  array[L] matrix[T, P] delta;

  vector<lower=0>[T] sigma_l;
  vector<lower=0>[T] sigma_p;

  real<lower=0> sigma_delta;

  // new: how much league shifts pick means (per tier)
  vector[T] k;           // can be positive/negative, prior below
}

transformed parameters {
  matrix[L,T] league_effect;
  array[L] matrix[P, T] pick_effect;

  for (t in 1:T){
    for (l in 1:L){
      league_effect[l,t] = league_effect_raw[l,t] * sigma_l[t];
      for (p in 1:P){
        // non-centered -> scale by sigma_p
        pick_effect[l][p,t] = pick_effect_raw[l][p,t] * sigma_p[t];
      }
    }
  }

  // Optional: center pick_effect within each league & tier so they are deviations
  // This makes pick_effect sum to zero across p for each (l,t).
  for (l in 1:L){
    for (t in 1:T){
      real mean_p = 0;
      for (p in 1:P) mean_p += pick_effect[l][p,t];
      mean_p /= P;
      for (p in 1:P) pick_effect[l][p,t] -= mean_p;
    }
  }
}

model {
  alpha ~ normal(0, 2);

  // league non-centered hyperprior
  to_vector(league_effect_raw) ~ normal(0,1);
  sigma_l ~ normal(0,1);

  // k: effect of league on pick means (per tier)
  k ~ normal(0, 1);

  // Now tie pick_effect_raw to the league-level signal.
  // We keep pick_effect_raw non-centered but give it a mean that depends on league_effect_raw:
  for (l in 1:L){
    for (p in 1:P){
      for (t in 1:T){
        // center is the scaled raw league signal (you could use league_effect[l,t] instead)
        pick_effect_raw[l][p,t] ~ normal(k[t] * league_effect_raw[l,t], 1);
      }
    }
    // allow per-league pick raw variation across picks (this is already controlled by sigma_p later)
  }
  sigma_p ~ normal(0,0.2);

  sigma_delta ~ normal(0, 0.5);
  for (l in 1:L) to_vector(delta[l]) ~ normal(0, sigma_delta);

  // likelihood
  for (l in 1:L){
    for (p in 1:P){
      vector[T] eta;
      for (t in 1:T){
        eta[t] = alpha[t]
               + league_effect[l,t] * league_diff_map[l]
               + pick_effect[l][p,t]
               + delta[l][t,p];
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
        eta[t] = alpha[t] + league_effect[l,t] * league_diff_map[l] + pick_effect[l][p,t] + delta[l][t,p]; 
      } 
      prob_tier_new[l,p] = softmax(eta); 
    } 
  } 
}









