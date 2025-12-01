
data {
  int<lower=1> C; //number of colleges
  int<lower=1> P; //number of pick bins
  int<lower=1> T; //number of player tiers
  
  int<lower=0> college_count[C,P]; //Count for pick given College
  int<lower=0> tier_count[C,P,T]; //Count for player tier given College and Pick Bin
}

parameters {
  simplex[P] pick_probs[C];     
  simplex[T] tier_probs[C, P]; 
}

model {
  for (c in 1:C) {
    college_count[c] ~ multinomial(pick_probs[c]);
  }
  for (c in 1:C) {
    for (p in 1:P) {
      tier_count[c,p] ~ multinomial(tier_probs[c,p]);
    }
  }
}

