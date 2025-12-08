data {
  int<lower=1> C; // colleges
  int<lower=1> P; // pick bins
  int<lower=1> T; // tiers
  int<lower=1> R; // regions
  int region_of_college[C];        // region index for each college
  int college_count[C, P];         // counts of players by pick within a college
  int tier_count[C, P, T];         // counts of tiers for (college,pick)
}
parameters {
  // baseline logits for each pick -> tier
  matrix[P, T] mu_pt;

  // region-level effects for tiers
  matrix[R, T] region_eff;
  vector<lower=0>[T] sigma_region;

  // college-level effects
  matrix[C, T] college_eff;
  vector<lower=0>[T] sigma_college;
}
model {
  // priors
  to_vector(mu_pt) ~ normal(0, 2.5);
  for (t in 1:T) sigma_region[t] ~ normal(0,1);
  for (t in 1:T) sigma_college[t] ~ normal(0,1);

  for (r in 1:R)
    for (t in 1:T)
      region_eff[r, t] ~ normal(0, sigma_region[t]);

  for (c in 1:C)
    for (t in 1:T)
      college_eff[c, t] ~ normal(region_eff[region_of_college[c], t], sigma_college[t]);

  // likelihood: for each (c,p) the tier probs are softmax(mu_pt[p] + college_eff[c] + maybe pick-specific)
  for (c in 1:C) {
    for (p in 1:P) {
      vector[T] eta = mu_pt[p]' + college_eff[c]'; // add extra terms as needed
      tier_count[c, p] ~ multinomial(softmax(eta));
    }
  }
}
