// ECON 626:  EMPIRICAL MICROECONOMICS (FALL 2019)
// L6. SELECTION ON OBSERVABLES
// IN-CLASS ACTIVITY 1. COEFFICIENT STABILITY
// WRITTEN BY PAM JAKIELA & OWEN OZIER

// SETUP

** install psacalc if not already installed
*ssc install psacalc

// 1. GENERATE DATA
// 		create a dataset with 100,000 observations.
// 		generate n1, n2, n3 as iid N(0,1).
// 		generate W so that it is normally distributed with mean zero and VARIANCE 10 [sd=sqrt(10)], based on n1.
// 		generate C so that it is normally distributed with mean zero and VARIANCE 0.1 [sd=sqrt(0.1)], based on n2.
// 		generate X so that it is 0.02*W + 0.02*C + n3.
// 		generate Y so that it is simply W + C (no direct effect of X on Y)

clear all
version 11.2
version 11.2: set seed 7654
set obs 100000
generate n1=invnorm(uniform())
generate n2=invnorm(uniform())
generate n3=invnorm(uniform())
gen W=sqrt(10)*n1
gen C=sqrt(0.1)*invnorm(uniform())
gen X=n3+0.02*W+0.02*C
gen Y=0*X + W + C

// 2. REGRESSIONS
// 		2a. regress Y on X to see the uncontrolled coefficient and R^2
// 		2b. regress Y on X and C to see the controlled coefficient and R^2 for the low variance control
// 		2c. regress Y on X and W to see the controlled coefficient and R^2 for the HIGH variance control
// 		2d. how do your answers compare to Oster (2016) Table 1?

reg Y X
reg Y X C
reg Y X W

// 3. USING PSACALC
// 		Now that psacalc is installed, after regressing Y on X and W, 
// 		to see what ratio of unobserved selection to observed selection would
// 		be necessary to explain away the entire (spurious) effect of X,
// 		if the maximum R^2 were 1, type
//   		psacalc delta X, rmax(1)
// 		Then type the same command immediately after regressing Y on X and C.
// 		what values do you get?  do they make sense?

reg Y X W
psacalc delta X, rmax(1)

reg Y X C
psacalc delta X, rmax(1)


