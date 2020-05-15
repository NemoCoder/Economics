// ECON 626 FALL 2019
// L10. Attrition
// A1. Bounding 1

clear all
set seed 12345
*cd "E:\Dropbox\econ-626-2019\lectures\L10 Attrition\activities"
use ECON626L10A1data.dta


// 1. How much attrition is observed overall?  Is it correlated with treatment?  
//		In what sense?  What is the observed level of differential attrition.

sum surveyed // 17.8 percent attrition
reg surveyed treatment, r 
// Attrition if 5.3 percentage points more likely in the treatment group 
// Relationship between treatment and attrition is not statistically significant 
// (p-value 0.114)

// 2. If you ignore attrition, what is the estimated impact of treatment on 
//		income five years after the intervention?  What is the estimated impact 
// 		of treatment on the probability of self-employment?

reg income treatment, r
reg selfemp treatment, r

// 3. Characterize the Manski bounds on the the impact of treatment on income.

// 4. Compute the upper and lower Manski bounds on the impact of treatment on 
//		self-employment:

// 4a. Impute the lower bound by generating a variable equal to 0 for everyone 
//		in treatment group who was not surveyed at endline, and equal to 1 for 
//		everyone in the control group who was not surveyed at endline (and equal 
//		to the observed value of \texttt{selfemp} for everyone surveyed at 
//		endline).  Regress this variable on \texttt{treatment} to calculate the 
//		Manski lower bound.

gen manski_lower = selfemp
replace manski_lower = 1 if treatment==0 & selfemp==.
replace manski_lower = 0 if treatment==1 & selfemp==.
reg manski_lower treatment, r

// Manski lower bound:  -0.070

// 4b. Impute the upper bound by generating a variable equal to 1 for everyone 
//		in treatment group who was not surveyed at endline, and equal to 0 for 
//		everyone in the control group who was not surveyed at endline (and equal 
//		to the observed value of \texttt{selfemp} for everyone surveyed at 
//		endline).  Regress this variable on \texttt{treatment} to calculate the 
//		Manski upper bound.

gen manski_upper = selfemp
replace manski_upper = 0 if treatment==0 & selfemp==.
replace manski_upper = 1 if treatment==1 & selfemp==.
reg manski_upper treatment, r

// Manski upper bound:  0.268

// 5. Compute the upper and lower Lee bounds for the impact of treatment on 
//		income. 

gen lee_lower1 = income
xtile newvar = income if treatment==1, nq(100)
replace lee_lower1 = . if treatment==1 & newvar>=94 // trimming about 6.1 percent of 156 non-attritor observations
reg lee_lower1 treatment

gen lee_upper1 = income
gen tempsortvar = cond(treatment==1,1,2)
sort tempsortvar income id
replace lee_upper1 = . in 1/10
reg lee_upper1 treatment

// 6. Compute the upper and lower Lee bounds for the impact of treatment on 
//		self-employment.

ttest surveyed, by(treatment) // calculate differential attrition
di 182 * 0.0527351 // need to drop 9.598 people
tab selfemp treatment

** lower bound:
di (78 - 9.598)/(156 - 9.598) - 110/292

** upper bound:
di (78)/(156 - 9.598) - 110/292

// 7. Check the above using the leebounds command
leebounds selfemp treatment, select(surveyed)


