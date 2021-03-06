/*
UMD ECON-626 FALL 2019
Power, real data
Power, PART 3: using real data to simulate power with different designs
*/
set more off

/* CHANGE THIS FIRST LINE SO THAT IT IS APPROPRIATE TO WHERE YOUR FILES ARE STORED: */
cd "C:\Users\wb259971\Dropbox\econ-626-2019\lectures\L7 Power\activity"

use KenyaPSDPtestdataStd3V3.dta, clear


// 3.1.1
// use "summarize" or "sum" to see characteristics of the "engsep98" English test score variable.
//  how many observations are there total?
//  what is the standard deviation?
sum engsep98
local thissd=r(sd)
local thisN=r(N)

// 3.1.2: the "loneway" command is a one-way anova analysis.
// It reports several statistics, including the "Intra-class correlation."
// Try it with the command below, and try it with other variables if you like
//    loneway engsep98 schid
loneway engsep98 schid
local thisrho=r(rho)

// 3.1.3
// how many clusters (schid) are there? use "codebook schid" or other such commands.  "tabulate" can also help.
// thus what is the average number of observations per cluster?  (total divided by number of clusters)
codebook schid
qui tab schid
local thisNclust=r(r)
di `thisN'
di `thisNclust'
local obsPerClust=`thisN'/`thisNclust'
di `obsPerClust'

// 3.2
// note how different the standard error is when clustered vs when not,
// using either the "mean" or "reg" command on variable engsep98,
// with or without the "cluster(schid)" option
reg engsep98 
mean engsep98 
reg engsep98, cluster(schid)
mean engsep98, cluster(schid)

// 3.3
// simulate treatment effects where treatment is assigned by school.
// you might do this by repeatedly (with capture drop in between as needed):
// (setting the seed)
//  1) generating and assigning such random numbers to one observation per school (tagsch)
//  2) sorting by this random number, for these observations
//  3) assigning treatment to the first 33 of 67 schools
//  4) using egen to use this treatment variable for all observations within school
//  5) adding a treatment effect to engsep98 to create the "outcome"
//  6) running the regression of outcome on treatment
//  7) counting how many times it is significant

// (at least) two parameters to control
local effectsize=1.5
local loopmax=100

// (setting the seed)
version 11.2: set seed 98765
// initialize counter
local rejcount=0
// repeatedly:
forvalues i=1/`loopmax' {
 // report progress during the loop
 if(mod(`i',10)==0) {
  di "Loop `i'"
 }
 // quietly, so as not to fill the screen with output
 qui {
  //  1) generating and assigning such random numbers to one observation per school (tagsch)
  cap drop su
  gen su=uniform() if tagsch==1
  //  2) sorting by this random number, for these observations
  sort tagsch su
  //  3) assigning treatment to the first 33 of 67 schools
  cap drop _t
  sort tagsch 
  by tagsch: gen _t=cond(_n<=33,1,0) if tagsch==1
  //  4) using egen to use this treatment variable for all observations within school
  cap drop t
  sort schid
  by schid: egen t=max(_t)
  //  5) adding a treatment effect to engsep98 to create the "outcome"
  cap drop outcome
  gen outcome=engsep98+`effectsize'*t
 }
  //  6) running the regression of outcome on treatment
  qui reg outcome t, vce(cluster schid)
  //  7) counting how many times it is significant
  if abs(_b[t]/_se[t])>1.96 {
    local rejcount=`rejcount'+1
  }
}
di "Rej: `rejcount'"

// 3.4
// how does this compare to the associated power calculation?
// easiest thing is to try typing in the power from the rejection rate you saw, and use sampsi followed by sampclus.
// you could also use the formula on slide 29, and rearrange, to solve more precisely.
sampsi 0 1.5, sd1(5.657) power(0.52)
sampclus, obsclus(45) rho(0.247)

// using the formula on slide 29, but rearranging:
// z+z = MDE * sqrt(p(1-p)) * sqrt(N/sigma^2) / sqrt(1+(ng-1)rho))
// z_(1-k) = MDE * sqrt(p(1-p)) * sqrt(N/sigma^2) / sqrt(1+(ng-1)rho)) - z_(alpha/2)
// z_(1-k) = 1.5 * 0.5 * sqrt(3006/(5.65658^2)) / sqrt(1+(44.8358-1)0.24677)) - 1.96
// z_(1-k) = 0.75 * 9.6926 / sqrt(1+(43.8358)0.24677)) - 1.96
// z_(1-k) = 0.75 * 9.6926 / sqrt(11.81736) - 1.96
// z_(1-k) = 0.75 * 9.6926 / 3.4376387 - 1.96
// z_(1-k) = 2.11466 - 1.96
// z_(1-k) = 0.15466
// k = normal(0.15466) = 0.5615


// 3.5
// consider stratifying by a different year's mean test score at the school level.
// these variables are already created for you, so:
// re-do 3.3 above, but replacing four lines to stratify by "othertestblock"
// and treat "numtreatblock" schools within each block:

/*
 sort tagsch su
  becomes
 sort tagsch othertestblock su

 sort tagsch
  becomes
 sort tagsch othertestblock 
 
 by tagsch: gen _t=cond(_n<=33,1,0) if tagsch==1
  becomes
 by tagsch othertestblock: gen _t=cond(_n<=numtreatblock,1,0) if tagsch==1

 qui reg outcome t, vce(cluster schid)
  becomes
 qui reg outcome t i.othertestblock, vce(cluster schid)
*/
// how do your results change?


// (setting the seed)
version 11.2: set seed 98765
// initialize counter
local rejcount=0
// repeatedly:
forvalues i=1/`loopmax' {
 // report progress during the loop
 if(mod(`i',10)==0) {
  di "Loop `i'"
 }
 // quietly, so as not to fill the screen with output
 qui {
  //  1) generating and assigning such random numbers to one observation per school (tagsch)
  cap drop su
  gen su=uniform() if tagsch==1
  //  2) sorting by this random number, for these observations
  sort tagsch othertestblock su
  //  3) assigning treatment to the first 33 of 67 schools
  cap drop _t
  sort tagsch othertestblock 
  by tagsch othertestblock: gen _t=cond(_n<=numtreatblock,1,0) if tagsch==1
  //  4) using egen to use this treatment variable for all observations within school
  cap drop t
  sort schid
  by schid: egen t=max(_t)
  //  5) adding a treatment effect to engsep98 to create the "outcome"
  cap drop outcome
  gen outcome=engsep98+`effectsize'*t
 }
  //  6) running the regression of outcome on treatment
  qui reg outcome t i.othertestblock, vce(cluster schid)
  //  7) counting how many times it is significant
  if abs(_b[t]/_se[t])>1.96 {
    local rejcount=`rejcount'+1
  }
}
di "Rej: `rejcount'"
