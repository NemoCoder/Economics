// UMD ECON-626
// FALL 2019
// PAMELA JAKIELA AND OWEN OZIER

// ----------------------------------------------------------------------------
// INSTALLATION OF WEAK INSTRUMENTS ANDERSON-RUBIN CONFIDENCE INTERVAL ROUTINES
// Mikusheva-Poi-Moreira 2006
capture which condivreg
if _rc!=0 {
  net install st0033_2, from(http://www.stata-journal.com/software/sj6-3)
}
// Finlay-Magnusson-Schaffer 2015
capture which weakiv
if _rc!=0 {
  net install weakiv.pkg, from(http://fmwww.bc.edu/RePEc/bocode/w/)
}
// required for weakiv
capture which avar
if _rc!=0 {
  ssc install avar
}


// cd "YOURPATH HERE"
cd "C:\Users\OwenLenovo\Dropbox\econ-626-fall16\lectures\L4 iv\activities\dinkelman\"
use "dinkelman_aer2011_matched_censusdata.dta", clear 


// ----------------------------------------------------------------------------
// DINKELMAN 2011 

keep if largearea==1
tab dccode0, gen(idcc)

global endogenoustreatment="T"
global thisinstrument="mean_grad_new"
global controls="kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0 d_prop_waterclose d_prop_flush idcc1-idcc9"
global correctse="robust cluster(placecode0)"
global outcome="d_prop_emp_f"

// part 1.
// OLS: Dinkelman 2011 Table 4 Column 4
// reg YYY XENDOG XXX, ESTIMATIONOPTIONS
reg $outcome $endogenoustreatment $controls, $correctse

// part 2.
// first stage: Dinkelman 2011 Table 3 Column 4
// reg XENDOG ZZZ XXX, ESTIMATIONOPTIONS
// local WaldBase=_b[ZZZ]
// test ... what?
// predict...
reg $endogenoustreatment $thisinstrument $controls, $correctse
local WaldBase=_b[$thisinstrument]
test $thisinstrument
predict fitted, xb

// part 3.
// reduced form and two-stage without correct 2SLS SEs
// reg YYY ZZZ XXX, ESTIMATIONOPTIONS
// local WaldHeight=_b[ZZZ]
// display `WaldHeight'/`WaldBase'
// regress...
reg $outcome $thisinstrument $controls, $correctse
local WaldHeight=_b[$thisinstrument]
display `WaldHeight'/`WaldBase'
reg $outcome fitted $controls, $correctse


// part 4.
// 2SLS: Dinkelman 2011 Table 4 Column 8
// ivregress 2sls YYY (XENDOG = ZZZ) XXX, ESTIMATIONOPTIONS
ivregress 2sls $outcome ($endogenoustreatment = $thisinstrument) $controls, $correctse

// part 5.
// ANDERSON-RUBIN CI WITHOUT CLUSTERING OR HETEROSKEDASTICITY
// condivreg YYY (XENDOG = ZZZ) XXX, 2sls ar
condivreg $outcome ($endogenoustreatment = $thisinstrument) $controls, 2sls ar

// ANDERSON-RUBIN CI WITH CLUSTERING, HETEROSKEDASTICITY
// weakiv ivregress 2sls YYY (XENDOG = ZZZ) XXX, ESTIMATIONOPTIONS gridmult(3)
weakiv ivregress 2sls $outcome ($endogenoustreatment = $thisinstrument) $controls, $correctse gridmult(3)


