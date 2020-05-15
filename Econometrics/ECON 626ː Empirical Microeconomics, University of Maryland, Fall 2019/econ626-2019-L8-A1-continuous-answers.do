* Econ-626
* This is not the most efficient way of doing a bootstrap
* (repeatedly accessing a file from disk), but it is transparent for demonstration purposes.

* original regression
cd "YOURPATHHERE"
use "example-continuous-resid.dta" , clear
reg y x

* create dataset with 13 obs
clear all
local obsno 13
set obs `obsno'
local BOOTSTRAPREPLICATIONS=1000

* create index in this dataset, 1 through 13
gen myindex=_n

* for iteration = 1/BOOTSTRAPREPLICATIONS
forvalues iteration=1/`BOOTSTRAPREPLICATIONS' {

  if mod(`iteration',100)==0 {
    di "Iteration `iteration'"
  }
  
  * capture drop ----
  cap drop rownum
  
  * generate a new variable rownum = ceil(uniform()*13) - random numbers 1-13 equal prob.
  qui gen rownum = ceil(uniform()*`obsno')
  
  cap drop y x mmm
  * merge m:1 rownum
  qui merge m:1 rownum using "example-continuous-resid.dta" , keep(match master) gen(mmm)
  * keep if ---- == 3
  *keep if mmm==3
  
  
  * reg y x
  quietly reg y x
  
  * local b`iteration' = _b[x]
  local b`iteration' = _b[x]
  
}

* clear
clear

* set obs BOOTSTRAPREPLICATIONS
set obs `BOOTSTRAPREPLICATIONS'

* gen betahat=.
gen betahat=.

* for iteration = 1/BOOTSTRAPREPLICATIONS
forvalues iteration=1/`BOOTSTRAPREPLICATIONS' {
  * quietly replace betahat = `b`iteration'' in `iteration'
  quietly replace betahat = `b`iteration'' in `iteration'
}
* sum betahat, det
* sort betahat
* view the 2.5th percentile and 97.5th percentile of betahat
local lo025=floor(0.025*`BOOTSTRAPREPLICATIONS')-1
local hi025=ceil(0.025*`BOOTSTRAPREPLICATIONS')+1
local lo975=floor(0.975*`BOOTSTRAPREPLICATIONS')-1
local hi975=ceil(0.975*`BOOTSTRAPREPLICATIONS')+1
sort betahat
list in `lo025'/`hi025'
list in `lo975'/`hi975'

* The original 95 pct confidence interval was from roughly -0.016 to 1.187
* The (nonparametric) bootstrap 95 pct confidence interval should be from roughly -0.04 to 0.99
