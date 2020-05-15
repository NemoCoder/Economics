// ECON 626 FALL 2019
// L9. Multiple Hypothesis Testing
// A1. Implementing Anderson's Benjamini-Hochberg q-values

clear all
set seed 12345
cd "E:\Dropbox\econ-626-2019\lectures\L9 Multiple Testing\activities"


// 1. Generate a list of k=20 p-values, including several below 0.05 that are 
//		quite close together and many that would normally be rejected (absent 
//		adjustment).  How many hypotheses would be rejected?

set obs 20
gen pval = runiform()/10
sort pval
gen p_reject = pval<=0.05

// 1a. Calculate Bonferroni-adjusted p-values - how many would be rejected now?

count // number of hypotheses being tested
local k = r(N)
gen bval = min(pval*`k',1)
gen b_reject = bval<=0.05


// 1b. Calculate Benjamini-Hochberg q-values as follows:
//		- sort p-values and calculate ranks (smallest to largest)
//		- calculate preliminary adjusted q-values by multiplying p by rank/k
//		- Whenever the q-value for hypothesis j is above that of hypothesis j+1 (etc.) 
//      		adjust accordingly

count // number of hypotheses being tested
local k = r(N)
sort pval 
gen rank = _n
gen temp_q = pval * (`k'/rank)
gen qval = temp_q // will be replaced as needed
local j = `k' - 1
sum temp_q in `k'
local thisqval = r(mean)
forvalues i = 1/`j' {
	local temprank = `k' - `i'
	sum temp_q in `temprank'
	local tempqval = r(mean)
	if `tempqval' > `thisqval' {
		replace qval = `thisqval' in `temprank'
	}
	if `tempqval' < `thisqval' {
		local thisqval = `tempqval'
	}
}

gen q_reject = qval<=0.05

// 1c. How many hypotheses are rejected under each of the three approaches
//		(no adjustments, Bonferroni, and Benjamini-Hochberg)?

// 1d. Compare the q-values you calculated to those you obtain using 
// 		Michael Anderson's do file (anderson_qvalues.do) - are they similar?




