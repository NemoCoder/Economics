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
local iters = 20
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
cap drop A* B* C* D* T Y sum*

** generate covariates
forvalues i = 1/9 {
	gen A`i' = rnormal()
	gen B`i' = rnormal()
	gen C`i' = rnormal()
}

forvalues i = 1/99 {
	gen D`i' = rnormal()
}

egen sumA=rowtotal(A*)
egen sumB=rowtotal(B*)
egen sumC=rowtotal(C*)

** generate a binary treatment
gen T = runiform()
replace T = T + sumA + sumB + rnormal()
replace T = exp(T)/(1+exp(T))
replace T = T<=runiform()

** generate a continuous Y
gen Y = `scalefactor'*sumB + sumC + rnormal()

** regress Y on T and all controls to capture true beta
** (this only works well because p is small relative to N)
reg Y T A* B* C* D*
mat V = r(table)
*local tempbeta = V[1,1]
replace truebeta = V[1,1] in `j'
	
** use lasso to choose covariates that predict Y
lasso2 Y A* B* C* D*
global mylambda = e(lebic)
*di $mylambda
lasso2 Y A* B* C* D*, lambda($mylambda)
gl myvarsY = "`e(selected)'"
*di "$myvarsY"

** run post single lasso estimation, including covariates that predict Y
reg Y T $myvarsY
mat V = r(table)
replace singlebeta = V[1,1] in `j'

** use lasso to choose covariates that predict T
lasso2 T A* B* C* D*
global mylambda = e(lebic)
*di $mylambda
lasso2 T A* B* C* D*, lambda($mylambda)
gl myvarsT = "`e(selected)'"
*di "$myvarsT"

** run post double lasso estimation, including covariates that predict Y and/or T
reg Y T $myvarsY $myvarsT 
mat V = r(table)
replace doublebeta = V[1,1] in `j'

}

** summarize results
sum singlebeta doublebeta truebeta

** Notice that PDL does not appear to perform better than PSL in this case (may depend on seed, etc.)
** Set the iters to 1 - how many variables are selected as predictors of T?
** Re-estimate using AIC instead of EBIC - how do PSL and PDL compare?



