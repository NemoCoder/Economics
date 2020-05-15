// ECON 626 FALL 2019
// L10. Attrition
// A2. Bounding 2

clear all
set seed 12345

// 1. Generate a data set with 10,000 observations, half of which are treated. 
//		Generate an outcome ystar that is equal to 0 for half the treatment and 
//		half the control observations.  For the other half of the observations, 
//		set ystar equal to rnormal(1,1) + treatment*2.  Generate y = ystar for 
//		non-missing observations.  Let half of the 0 observations in the control 
//		group be missing. 

// parameters: observations, true treatment effect (on some)
clear all
local treatmenteffect=2
local armsize=5000
local halfarmsize=floor(0.5*`armsize')
local qtrarmsize=floor(0.25*`armsize')
local obsno=2*`armsize'
set obs `obsno'

// variation in treatment
gen t=cond(_n<=`armsize',1,0)

// only some observations will have nonzero outcomes
gen randomsort1=uniform()
sort t randomsort1
by t: gen nonzero=cond(_n<=`halfarmsize',1,0)

// variation in nonzero outcomes
gen epsilon=cond(nonzero==1,rnormal(1,1),0)

// treatment effect for those with nonzero outcomes
gen ystar=cond(nonzero==1,`treatmenteffect'*t + epsilon,0)

// missing: half of the comparison zero observations, and just one of each of the rest
gen randomsort2=uniform()
sort t nonzero randomsort2
by t nonzero: gen nonmissing=cond(t==1 | nonzero==1,cond(_n==1,0,1),cond(_n<=`qtrarmsize',1,0))

// tabulate to confirm this pattern
bys nonzero: tab nonmissing t

// generate y only for nonmissing observations.
gen y=cond(nonmissing==1,ystar,.)


// 2. Regress ystar on t.  This is the true effect.  What is it?  

reg ystar t
reg ystar t if nonzero==1

// 3. Regress y on t.  This is a biased estimate of the effect.  What is it?  

reg y t
di (0.5*3+0.5*0)-(0.5*1+0.25*0)/0.75

// 4. Use the Lee Bounds command.  How wide is the confidence interval?

leebounds y t, cie

// 5. Tighten the Lee bounds using the "nonzero" variable.  The result should 
// 		have a very narrow confidence interval - why?  Why is the point estimate 
//		what it is, in relation to the parameters above?

leebounds y t, tight(nonzero) cie
di (0.5*2+0.25*0)/0.750


