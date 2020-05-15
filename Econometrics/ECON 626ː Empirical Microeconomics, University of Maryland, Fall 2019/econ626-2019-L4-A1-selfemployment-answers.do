// UMD ECON-626
// FALL 2019
// PAMELA JAKIELA AND OWEN OZIER

// Activity: IV in an RCT, Treatment on the Treated

// Data based on Brudevold-Newman, Honorati, Jakiela, and Ozier (2017)
// Evaluation of an active labor market program for young women in Nairobi
// Three randomly-assigned arms:  control, cash grants, and gem 
// GEM is the IRC's Girls Empowered by Microfranchise training + cash + mentoring program

// load data
use gemdata.dta


// 1. Consider two variables measured at baseline and endline:  voced and selfemp
// 		voced is a dummy for having received vocational training
//		selfemp is a dummy for self-employment

// 1a. In the control group, how correlated is b_voced with e_voced?  What about
//		b_selfemp and e_selfemp?

corr b_voced e_voced
corr b_selfemp e_selfemp

// 1b. Regress e_voced on the treatment dummies (gem and grant) controlling for 
//		strata dummies.  How do results (and, specifically, t-statistics) compare 
//		when you run specifications with and without the baseline values of 
//		the outcome variable?

reg e_voced gem grant i.stratid, r

// 1c. Repeat this exercise for e_selfemp.  How do results differ?

reg e_selfemp gem grant i.stratid, r

// 1d. Now estimate the treatment effect on the change in vocational training or 
//			self-employment.

gen change_voced = e_voced - b_voced
gen change_selfemp = e_selfemp - b_selfemp

reg change_voced gem grant i.stratid, r
reg change_selfemp gem grant i.stratid, r

// 2a. Calculate the expected IV (Wald) estimate of the impact of training
//     (through the GEM program) on self-employment: use data from the control
//      group and the GEM treatment arm to estimate the reduced-form and the
//      first stage in separate regressions, noting the resulting ratio.

reg e_selfemp gem if grant==0, r
local ivnumerator = _b[gem]
reg training gem if grant==0, r
local ivdenominator = _b[gem]
di `ivnumerator'/`ivdenominator'

// 2b. How does this compare to the actual IV estimate of the impact of training 
//		on self-employment (when you use ivregress 2sls)?

ivregress 2sls e_selfemp (training = gem) if grant==0, r

// 2c. One could also estimate the impact of launching a business (through the 
//		program) on self-employment (using the bizlaunch variable).  What 
//		happens when you do this?  Should you do this?  Why or why not?

** Since assignment to the GEM program might impact those who start training and drop out, 
** 	this will generate a biased estimate of the treatment effect of launching a business

// 3. Compare the ITT and TOT estimates of the impact of cash grants on self-employment.

tab gotcash if grant==1 // 97 percent of those assigned to the grant arm received the grant
reg e_selfemp grant if gem==0, r
ivregress 2sls e_selfemp (gotcash = grant) if gem==0, r
