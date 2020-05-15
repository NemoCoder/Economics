// ECON 626:  EMPIRICAL MICROECONOMICS (FALL 2019)
// L2. REGRESSION BASICS
// IN-CLASS ACTIVITY 1. ATTENUATION BIAS
// WRITTEN BY PAM JAKIELA & OWEN OZIER

// preliminaries
clear all
cd "E:\Dropbox\econ-626-2019\lectures\L2 Regression\activities"
version 14.2 // replace with earlier version as needed
set seed 12345

// 	1. Overview:
//
//		Consider a regression of the form y* = beta x* + epsilon 
//		where x*~U(0,2) and epsilon~N(0,1).  You do not observe x*;
//		instead you observe x = x* + nu where nu~N(0,0.5).  Assume 
// 		x*, epsilon, and nu are independent.
// 

//	1a.	Let beta = 1.  Write a do file that simulates this data-generating 
//		process in a sample of ten thousand observations.

set obs 10000
gen xstar = 2*runiform()
gen eps = rnormal()
gen ystar = xstar + eps
gen x = xstar + (1/sqrt(2))*rnormal()

//	1b. You are interested in recovering the true coefficient, beta. 
//		Since you know the data-generating process, you know that beta = 1. 
//		How does the true coefficient compare to the coefficient you get
//		from a regression of y* on the observed x?

reg ystar x

/* OUTPUT: confidence interval for x does not include 1.

. reg ystar x

      Source |       SS           df       MS      Number of obs   =    10,000
-------------+----------------------------------   F(1, 9998)      =   1197.75
       Model |  1417.77862         1  1417.77862   Prob > F        =    0.0000
    Residual |  11834.6376     9,998   1.1837005   R-squared       =    0.1070
-------------+----------------------------------   Adj R-squared   =    0.1069
       Total |  13252.4162     9,999  1.32537416   Root MSE        =     1.088

------------------------------------------------------------------------------
       ystar |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
           x |   .4097467   .0118395    34.61   0.000      .386539    .4329544
       _cons |   .5889379   .0162641    36.21   0.000      .557057    .6208188
------------------------------------------------------------------------------
*/

//	1c.	When the independent variable of interest is measured with (mean-zero) 
//		error, the OLS coefficient is biased toward zero. Let beta-hat be the OLS 
//		coefficient resulting from a regression of y* on x. Show that your 
//		answer to (1b) is consistent with the formula: 
//
//			plim beta-hat = beta*(1 - (s/(1+s)))
//
//		where s = sigma^2_nu / sigma^2_x* (the signal-to-noise ratio). See
//		Cameron and Trivedi, pp. 903-904 for discussion.

//		ANSWER:  We know that sigma^2_nu = 0.5 and sigma^2_x* = 1/3 (recall 
//		the variance of a uniform:  (1/12)*(b-a)^2 = (1/12)*2*2 in this case).
//		This implies that the limit of beta-hat is 0.4.

// 1d.	Now imagine that you observe x* but y* is measured with error - 
//		speciffically, assume that you only observe y = y* + eta where
//		eta~N(0,0.5).  How does the estiamted beta-hat compare to the true
//		beta?  How does the estimated standard error of beta-hat compare to 
//		the standard error from a regression of y* on x*?  Why is this the case?

gen y = ystar + (1/sqrt(2))*rnormal()
reg y xstar
reg ystar xstar



// 	2. Overview:
//
//		In statistics, power is the probability of rejecting a false null 
//		hypothesis. Consider the DGP y* = beta x* + epsilon where 
//		x*~U(-sqrt(3),sqrt(3)) and epsilon~N(0,sigma^2_epsilon).  Write a 
//		program to generate an empirical estimate of the statistical power 
//		of a regression of y* on x* in a sample of 100 observations.  
//		Specifically, write a loop that generates one thousand data sets 
//		of 100 observations each using the DGP described above; for each data
//		set, record the p-value associated with a test of the hypothesis that
//		beta-hat = 0.  For a test size of 0.05, the fraction of observations 
//		with p<0.05 provides an empirical estimate of the power of the test.

//	2a.	Once you've written your loop, use it to identify a value of 
//		sigma^2_epsilon that will lead to a power of 0.8 in your N=100
//		sample.

//	2b. Now modify your loop to compare the results of the ideal regression
//		(described above) to a regression of y* on x = x* + nu where nu~N(0,1).
//		How much does attenuation bias reduces statistical power

//	2c. Now modify your loop to compare the results of the ideal regression 
//		to a regression of y = y* + eta on x* for eta~N(0,1).  How much does 
//		measurement error in the depedent variable reduce statistical pwoer

clear
set obs 100
gen pval = .
gen p_xnoise = .
gen p_ynoise = .

forvalues i = 1/100 {
	di "Loop `i'"
	quietly gen xstar = 2*sqrt(3)*runiform() - sqrt(3) in 1/100
	quietly gen eps = 3.6*rnormal() in 1/100
	quietly gen ystar = xstar + eps in 1/100
	quietly gen x = xstar + rnormal() in 1/100
	quietly gen y = ystar + rnormal() in 1/100
	** 2a
	quietly reg ystar xstar
	matrix V = r(table)
	local temp_pval = V[4,1]
	quietly replace pval = `temp_pval' in `i'
	matrix drop V
	** 2b
	quietly reg ystar x
	matrix V = r(table)
	local temp_pval = V[4,1]
	quietly replace p_xnoise = `temp_pval' in `i'
	matrix drop V
	** 2c
	quietly reg y xstar
	matrix V = r(table)
	local temp_pval = V[4,1]
	quietly replace p_ynoise = `temp_pval' in `i'
	matrix drop V
	drop xstar ystar x y eps
}

gen reject = (pval<=0.05)
gen rej_xnoise = (p_xnoise<=0.05)
gen rej_ynoise = (p_ynoise<=0.05)
tab reject
tab rej_x
tab rej_y





