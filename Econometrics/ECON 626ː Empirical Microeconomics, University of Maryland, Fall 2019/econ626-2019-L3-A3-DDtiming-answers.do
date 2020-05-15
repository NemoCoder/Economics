// ECON 626:  EMPIRICAL MICROECONOMICS (FALL 2019)
// L3. DIFFERENCE-IN-DIFFERENCES
// IN-CLASS ACTIVITY 3. VARIATION IN TREATMENT TIMING
// WRITTEN BY PAM JAKIELA & OWEN OZIER

** preliminaries

clear all
set seed 1234
set scheme s1mono
set more off

** locals, etc 

local nA = 0.25
local nB = 0.25
local nC = 1 - `nA' - `nB'

local DbarA = 0.6
local DbarB = 0.2

local A0 = 20
local B0 = 12
local C0 = 4

local slope = 0.8

local effectA = 10
local effectB = 5

local obsnum = 100
local periods = 100

local errorscale = 0.01

set obs `obsnum'

** generate one observation per individual/unit (N)

gen id = _n
gen group = "A" if id<=`nA'*`obsnum'
replace group = "B" if group=="" & id<=(`nA' + `nB')*`obsnum'
replace group = "C" if id>(`nA' + `nB')*`obsnum'

** expand to create NT observations

expand `periods'
bys id:  gen time = _n

** treatment variable

gen dA = (group=="A" & time>(1-`DbarA')*`periods')
sum dA if group=="A"
assert r(mean)==`DbarA'

gen dB = (group=="B" & time>(1-`DbarB')*`periods')
sum dB if group=="B"
assert r(mean)==`DbarB'

gen D = dA + dB

** outcome variable
gen y 		= `A0' + `slope'*time + `effectA'*dA 	+ `errorscale'*rnormal() if group=="A"
replace y 	= `B0' + `slope'*time + `effectB'*dB 	+ `errorscale'*rnormal()	if group=="B"
replace y 	= `C0' + `slope'*time 					+ `errorscale'*rnormal()  if group=="C"

reg y i.time i.id D

exit 

** calculate fixed effects adjusted VarD for entire sample
bys time:  egen t_mean_ALL = mean(D)
bys id:  egen n_mean_ALL = mean(D)
egen grand_mean_ALL = mean(D)
gen Dnorm_ALL = D - t_mean_ALL - n_mean_ALL - grand_mean_ALL

sum Dnorm_ALL, d
gen VarD_ALL = r(Var)
local Dnorm_ALL = r(Var)

** generate dummies for each of the 2X2 DD samples
gen sampAC = group=="A" | group=="C"
gen sampBC = group=="B" | group=="C"
gen sampAB = (group=="A" | group=="B") & time<=80
gen sampBA = (group=="A" | group=="B") & time>40

foreach sample in AC BC AB BA {

	bys time:  egen t_mean_`sample' = mean(D) if samp`sample'==1
	bys id:  egen n_mean_`sample' = mean(D) if samp`sample'==1
	egen grand_mean_`sample' = mean(D) if samp`sample'==1
	gen Dnorm_`sample' = D - t_mean_`sample' - n_mean_`sample' - grand_mean_`sample' if samp`sample'==1

	sum Dnorm_`sample', d
	gen VarD_`sample' = r(Var)
	local Dnorm_`sample' = r(Var)

}

** generate sample-size weights
local weightAC = (`nA' + `nC')^2
local weightBC = (`nA' + `nC')^2
local weightAB = ((`nA' + `nB')*(1-`DbarB'))^2
local weightBA = ((`nA' + `nB')*(`DbarA'))^2

** generate final DD weights
local sAC = (`weightAC'*`Dnorm_AC')/`Dnorm_ALL'
di "sAC = `sAC'"
local sBC = (`weightBC'*`Dnorm_BC')/`Dnorm_ALL'
di "sBC = `sBC'"
local sAB = (`weightAB'*`Dnorm_AB')/`Dnorm_ALL'
di "sAB = `sAB'"
local sBA = (`weightBA'*`Dnorm_BA')/`Dnorm_ALL'
di "sBA = `sBA'"
