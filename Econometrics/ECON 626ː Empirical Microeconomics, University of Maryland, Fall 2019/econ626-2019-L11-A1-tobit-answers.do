// ECON 626 FALL 2019
// L11. MLE
// A1. Tobit

clear all
set seed 12345
*cd "E:\Dropbox\econ-626-2019\lectures\L11 MLE\activities"

clear all
set seed 12345

// PROBLEM 1


// 1a. 

** Generate a sample of 100 observations where
** outcome y = 2 + w + x + e
** for standard normals w, x, and e

set obs 1000
gen w = rnormal()
gen x = rnormal()
gen e = rnormal()
gen y = 2 + w + x + e

// 1b. 

** Use the reg command to estimate a regression of y on w and x

reg y w x

// 1c.

** Use the program below to estimate the OLS coefficients via ML

capture program drop myols
program myols
	args lnf beta sigma
	quietly replace `lnf'=log((1/`sigma')*normalden(($ML_y1-`beta')/`sigma')) 
	*quietly replace `lnf'=log((1/`sigma')*normalden($ML_y1,`beta',`sigma')) 
end

ml model lf myols (beta: y = w x) /sigma
ml maximize

ml model lf myols (beta: y = w x) ()
*ml model lf myols (beta: y = w x) (sigma: w)
ml maximize

exit

// PROBLEM 2 

// 2a.

** Censor y so that it is only observed if it is positive
** Estimate a tobit regression of y on w and x that adjusts for censoring
** Compare your tobit results to OLS estimates

gen z = cond(y>0,y,0)
tobit z w x, ll(0)
reg z w x

// 2b.

** Modify your likelihood program to estimate 
** the censored regression of y on w and x via ML

capture program drop mytobit
program mytobit
	args lnf beta sigma
	quietly replace `lnf'=log((1/`sigma')*normalden(($ML_y1-`beta')/`sigma'))
	quietly replace `lnf'= log(1-normal(`beta'/`sigma')) if $ML_y1==0
end

ml model lf mytobit (beta: z = w x) /sigma
ml maximize

tobit z w x, ll(0)




