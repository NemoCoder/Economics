/*
UMD ECON-626 FALL 2019
Power, PART 1: power simulation
*/

clear all
set obs 1600
gen treatment=cond(_n>=800,1,0)
gen pval=.
gen tstat=.
gen se=.
gen betahat=.
forvalues iteration=1/1000 {
 if (mod(`iteration',50)==0) {
  di "`iteration'"
 }
 cap drop epsilon
 qui gen epsilon=invnorm(uniform())
 cap drop y
 qui gen y=0.15*treatment+epsilon
 qui reg y treatment
 matrix theseresults=r(table)
 qui replace betahat=theseresults[1,1] in `iteration' 
 qui replace se=theseresults[2,1] in `iteration' 
 qui replace tstat=theseresults[3,1] in `iteration' 
 qui replace pval=theseresults[4,1] in `iteration' 
 
}
sum betahat
hist betahat
sum
di sqrt(1600)
di sqrt(0.5*(1-0.5))
di 1/20
di 0.15/0.05
di normal((0.15/0.05)-1.96)
di normal(3-1.96)
power twomeans 0 0.15, n(1600)
sampsi 0 0.15, power(0.85) sd(1)
