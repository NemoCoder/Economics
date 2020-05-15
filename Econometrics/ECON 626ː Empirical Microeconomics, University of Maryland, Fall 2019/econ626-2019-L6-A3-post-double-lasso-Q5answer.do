// ECON 626:  EMPIRICAL MICROECONOMICS (FALL 2019)
// L6. SELECTION ON OBSERVABLES
// IN-CLASS ACTIVITY 3. POST DOUBLE LASSO
// WRITTEN BY PAM JAKIELA & OWEN OZIER

// SETUP

** install lassopack if not already installed
*ssc install lassopack
*ssc install pdslasso

** preliminaries
clear
set seed 12345
set scheme s1mono

** locals
local scalefactor = 0.1
local iters = 50
local obs = 200

** create empty data set
set obs `obs'

** generate variables
gen singlebeta = . // to store results of post single lasso estimation
gen doublebeta = . // to store results of post double lasso estimation
gen truebeta = . // to store results of full model estimation

** simulate data and estimate treatment effects

forvalues j = 1/`iters' {

di "Iteration `j'"
cap drop A* B* C* D Y sum*

** generate covariates
forvalues i = 1/9 {
	gen A`i' = rnormal()
	gen B`i' = rnormal()
	gen C`i' = rnormal()
}

egen sumA=rowtotal(A*)
egen sumB=rowtotal(B*)
egen sumC=rowtotal(C*)

** generate a binary treatment
gen D = runiform()
*replace T = T + sumA + sumB + rnormal()
replace D = exp(D)/(1+exp(D))
replace D = D<=runiform()

** generate a continuous Y
gen Y = `scalefactor'*sumB + sumC + rnormal()
replace Y = Y + D

** regress Y on T and all controls to capture true beta
** (this only works well because p is small relative to N)
reg Y D A* B* C*
mat V = r(table)
*local tempbeta = V[1,1]
replace truebeta = V[1,1] in `j'
	
** use lasso to choose covariates that predict Y
lasso2 Y A* B* C*
global mylambda = e(lebic)
*di $mylambda
lasso2 Y A* B* C*, lambda($mylambda)
gl myvarsY = "`e(selected)'"
*di "$myvarsY"

** run post single lasso estimation, including covariates that predict Y
reg Y D $myvarsY
mat V = r(table)
replace singlebeta = V[1,1] in `j'

** use lasso to choose covariates that predict T
lasso2 D A* B* C*
global mylambda = e(lebic)
*di $mylambda
lasso2 D A* B* C*, lambda($mylambda)
gl myvarsD = "`e(selected)'"
*di "$myvarsD"

** run post double lasso estimation, including covariates that predict Y and/or T
reg Y D $myvarsY $myvarsD 
mat V = r(table)
replace doublebeta = V[1,1] in `j'

}

** summarize results
sum singlebeta doublebeta truebeta



