* create dataset with (CORRECT NUMBER OF) obs

* create index in this dataset, 1 through (THAT NUMBER OF OBS)

* for iteration = 1/SOMETHING
  * capture drop ----
  * generate a new variable rownum = ceil(uniform()*16) - random numbers 1-16 equal prob.
  * merge m:1 rownum here to the original file.
  * keep if ---- == 3  
  * reg y t
  * local b`iteration' = _b[t]

* clear

* set obs SOMETHING

* gen betahat=.

* for iteration = 1/SOMETHING
  * quietly replace betahat = `b`iteration'' in `iteration'

* sum betahat, det

* sort betahat

* view the 2.5th percentile and 97.5th percentile of betahat

