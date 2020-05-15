
// ECON 626 FALL 2019
// L11. MLE
// A2. Estimating a CRRA parameter

clear all
set seed 12345
*cd "E:\Dropbox\econ-626-2019\lectures\L11 MLE\activities"

clear all
set seed 12345
version 13


// PROBLEM 1 

// 1a.

** Simulate the investment decisions of 1000 risk averse decision makers 
** with a CRRA coefficient of 0.75
** given a budget size of 10 

** The decision maker decides how much of her budget to invest 
** in a risky security that yields 
** a 600 percent return with probability one half
** and a loss of the investment otherwise

** Assume the amount invested includes an additive error term 
** where the error is distributed N(0,1)

** Censor the decisions:  the amount investment must be in the interval [0,10]

set obs 1000
gen rho = 0.75
gen budget = 10
gen error = rnormal()

gen investment = budget*((5^(1/rho)-1)/(5^(1/rho)+5)) + error
replace investment = 10 if investment>10

// 1b.

** Estimate the CRRA coefficient via non-linear least squares using the NL command

nl (invest = budget*((5^(1/{rho=0.25})-1)/(5^(1/{rho})+5)))

// 1c.

** Estimate the CRRA coefficient via ML by completing the program below 
** How do the ML estimates compare to the NLS estimates?

capture program drop mymodel
program mymodel

	args lnf rho sigma
	tempvar ratio res
	
	quietly gen double `ratio' = $ML_y2*((5^(1/`rho') - 1)/(5^(1/`rho') + 5))
	*quietly gen double `ratio' = /* FILL IN DEMAND FUNCTION HERE */
    quietly gen double `res' = $ML_y1 - `ratio'
	
	quietly replace `lnf' = ln((1/`sigma')*normalden((`res')/`sigma'))
	*quietly replace `lnf' = /* FILL IN LIKELIHOOD HERE */
	
end

ml model lf mymodel (rho: investment budget = ) (sigma: )
ml maximize


// PROBLEM 2 

// 2a.

** Redo the problem above with a CRRA coefficient of 0.1
** How do the estimated NLS and ML coefficients compare to the true values?

// 2b.

** Adjust the likelihood function to correct for censoring (as needed)
** Compare your censored ML parameter estimate to the true parameter value


clear
set obs 10000
gen rho = 0.16
gen budget = 10
gen error = rnormal()/10

gen investment = budget*((5^(1/rho)-1)/(5^(1/rho)+5)) + error
replace investment = 10 if investment>10

nl (invest = budget*((5^(1/{rho=0.2})-1)/(5^(1/{rho})+5)))

capture program drop mymodel
program mymodel

	args lnf rho sigma
	tempvar ratio res
	
	quietly gen double `ratio' = $ML_y2 *((5^(1/`rho') - 1)/(5^(1/`rho') + 5))
    quietly gen double `res' = $ML_y1 - `ratio'
	
	quietly replace `lnf' =ln((1/`sigma')*normalden((`res')/`sigma'))
	quietly replace `lnf'= ln(1-normal((10-`ratio')/`sigma')) if $ML_y1 == 10
	
end

ml model lf mymodel (rho: investment budget = ) (sigma: )
ml maximize

exit

// Problem 3

** Generate a treatment that increases the CRRA coefficient from 0.2 to 0.4
** for the first 5000 of 10000 observations (or for 5000 randomly chosen observations)
** Estimate the impact of treatment on the CRRA coefficient via 
** NLS, uncensored ML, and censored ML

clear
set seed 12345
set obs 10000

gen rho = 0.4
replace rho = 0.6 in 1/5000
gen treatment = 1 in 1/5000
replace treatment = 0 in 5001/10000

gen budget = 10
gen error = rnormal()

gen investment = budget*((5^(1/rho)-1)/(5^(1/rho)+5)) + error
replace investment = 10 if investment>10

nl (invest = budget*((5^(1/({rho=0.25} + treatment*{treatrho=0.1}))-1)/(5^(1/({rho}+treatment*{treatrho}))+5)))

capture program drop mymodel
program mymodel

	args lnf rho treatrho sigma
	tempvar ratio res
	
	quietly gen double `ratio' = $ML_y2 * ((5^(1/(`rho' + $ML_y3*`treatrho')) - 1)/(5^(1/(`rho' + $ML_y3*`treatrho')) + 5))
    quietly gen double `res' = $ML_y1 - `ratio'
	
	quietly replace `lnf' =ln((1/`sigma')*normalden((`res')/`sigma'))
	quietly replace `lnf'= ln(1-normal((10-`ratio')/`sigma')) if $ML_y1==10
	
end

ml model lf mymodel (rho: investment budget treatment = ) (treatrho: ) (sigma: )
ml maximize

exit



