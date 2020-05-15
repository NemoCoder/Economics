// ECON 626:  EMPIRICAL MICROECONOMICS (FALL 2019)
// L2. REGRESSION BASICS
// IN-CLASS ACTIVITY 2. PROBIT VS. OLS
// WRITTEN BY PAM JAKIELA & OWEN OZIER

// preliminaries
clear all
*cd "E:\Dropbox\econ-626-2019\lectures\L2 Regression\activities"
version 14.2 // replace with earlier version as needed
set seed 12345
set scheme s1mono

//	1a.

set obs 10000

gen x1 = rnormal()
gen x2 = rnormal()
gen eps = rnormal()
gen xbeta = 2*x1 + 3*x2
gen prob = normal(xbeta)
gen outcome = (xbeta>eps)

twoway (scatter prob xbeta, msymbol(o) mcolor(midblue) msize(small)), ///
 legend(off)

// 	1b. 

reg outcome x1 x2
predict yhat

twoway (scatter prob xbeta, msymbol(o) mcolor(midblue) msize(small)) ///
 (scatter yhat xbeta, msymbol(o) mcolor(dkorange) msize(small)), ///
 legend(label(1 "Probit probability") label(2 "OLS predicted value"))
 

 
//	1d.

reg outcome x1 x2 if prob>0.05 & prob<0.95
predict zhat

twoway (scatter prob xbeta if prob>0.05 & prob<0.95, msymbol(o) mcolor(midblue) msize(small)) ///
 (scatter zhat xbeta if prob>0.05 & prob<0.95, msymbol(o) mcolor(dkorange) msize(small)), ///
 legend(label(1 "Probit probability") label(2 "OLS predicted value"))


// 2a.

clear
set obs 100000
gen x1 = rnormal()
gen x2 = rnormal()
gen xbeta = 2*x1 + 3*x2

gen zeta1 = rnormal() - 4
gen zeta2 = rnormal() + 4
gen mu = rnormal()
gen eta = cond(mu<0,zeta1,zeta2)

gen outcome = (xbeta>eta)

hist eta

cumul eta, gen(cdfvar)
sort cdfvar
line cdfvar eta

//	2b. 

lpoly outcome xbeta

//	2c.

probit outcome x1 x2
predict probit_yhat

reg outcome x1 x2
predict ols_yhat

twoway (scatter probit_yhat xbeta, msymbol(o) mcolor(midblue) msize(vsmall)) ///
 (scatter ols_yhat xbeta, msymbol(o) mcolor(midgreen) msize(vsmall)) ///
 (lpoly outcome xbeta, color(cranberry)), ///
 legend(cols(1) label(1 "Probit probability") label(2 "OLS predicted value") label(3 "Empirical probability"))
 
exit
 
/*
 
sort xbeta
gen tempid = _n
gen group = ceil(tempid/1000)
bys group:  egen emp_prob = mean(outcome)

twoway (scatter probit_yhat xbeta, msymbol(o) mcolor(blue) msize(vsmall)) ///
 (scatter ols_yhat xbeta, msymbol(o) mcolor(purple) msize(vsmall)) ///
 (scatter lpoly outcome xbeta, msymbol(o) mcolor(red) msize(vsmall)), ///
 legend(cols(1) label(1 "Probit probability") label(2 "OLS predicted value") label(3 "Empirical probability"))
 
*/
