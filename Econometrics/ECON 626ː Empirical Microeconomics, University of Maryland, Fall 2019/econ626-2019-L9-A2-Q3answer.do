
// ECON 626 FALL 2019
// L9. Multiple Hypothesis Testing
// A2. Implementing Anderson's Benjamini-Hochberg q-values

clear all
set seed 12345
set scheme s1mono
*cd "E:\Dropbox\econ-626-2019\lectures\L9 Multiple Testing\activities"
cd "C:\Users\pj\Dropbox\econ-626-2019\lectures\L9 Multiple Testing\activities"


// Redo Q2 with genuine treatment effects

// 2a. Generate a data set with 1000 observations and 100 outcome variables:
//		forvalues i = 1/100 {gen y`i' = rnormal()}

set obs 1000
gen id = _n

forvalues i = 1/100 {
	qui gen y`i' = rnormal()
}

gen treatment = (_n<=500)
forvalues i = 1/100 {
	qui replace y`i' = y`i' + 0.18*treatment
}


// 2b. calculate p-values from 100 regressions of yi = t

gen pval = .
forvalues i = 1/100 {
	qui reg y`i' t
	mat V = r(table)
	qui replace pval = V[4,1] in `i'
}

gen p_reject = pval<=0.05 if pval!=.

// 2c. Calculate Bonferroni-adjusted p-values

gen bval = min(1,pval*100) if pval!=.

// 2d. Calculate Benjamini-Hochberg q-values

count if pval!=. // number of hypotheses being tested
local k = r(N)
sort pval 
qui gen rank = _n if pval!=.
qui gen temp_q = pval * (`k'/rank)
qui gen qval = temp_q // will be replaced as needed
local j = `k' - 1
qui sum temp_q in `k'
local thisqval = r(mean)
forvalues i = 1/`j' {
	local temprank = `k' - `i'
	qui sum temp_q in `temprank'
	local tempqval = r(mean)
	if `tempqval' > `thisqval' {
		qui replace qval = `thisqval' in `temprank'
	}
	if `tempqval' < `thisqval' {
		local thisqval = `tempqval'
	}
}

// 2e. Calculate Romano-Wolf adjusted p-values

rwolf y1-y100, indepvar(treatment)

sort id
gen rwval = ""
forvalues i = 1/100 {
	replace rwval = "`e(rw_y`i')'" in `i'
}
destring rwval, replace force

// 2f. Plot the four sets of adjusted p-values

sort rank
twoway ///
	(scatter pval rank, mcolor(vermillion) msymbol(oh) mlwidth(thin)) ///
	(scatter bval rank, mcolor(orangebrown) msymbol(oh) mlwidth(thin)) ///
	(scatter qval rank, mcolor(sea) msymbol(oh) mlwidth(thin)) ///
	(scatter rwval rank, mcolor(turquoise) msymbol(oh) mlwidth(thin)), ///
	legend(cols(1) label(1 "Unadjusted p-values") ///
	label(2 "Bonferroni correction") ///
	label(3 "Benjamini-Hochberg")  ///
	label(4 "Romano-Wolf") size(small) ring(0) pos(11)) ///
	xtitle(" " "Rank of unadjusted p-value", size(small)) ///
	ytitle("Adjusted p-value" " ", size(small))
