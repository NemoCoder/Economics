// ECON 626:  EMPIRICAL MICROECONOMICS (FALL 2019)
// L3. DIFFERENCE-IN-DIFFERENCES
// IN-CLASS ACTIVITY 2. SERIAL CORRELATION
// WRITTEN BY PAM JAKIELA & OWEN OZIER


clear all 
set seed 1234
cd "ENTER FILE PATH HERE"

** load data
import excel "wdidata.xlsx", firstrow

rename CountryName country
rename CountryCode isocode
forvalues i = 1990/2015 {
 rename YR`i' gdp`i'
 destring gdp`i', replace force
}

sort country
gen cid = _n

** impute values 
egen count = rownonmiss(gdp*)
drop if count!=26
drop count

** convert to long format
reshape long gdp, i(isocode) j(year)

gen lngdp = ln(gdp)
sort isocode year
gen ctag = (year==1990)

// SIMULATE REJECTION PROBABILITIES
gen pval = .

forvalues i = 1/100	{
di "Iteration `i'"

** choose 74 countries at random
quietly gen random = runiform() if ctag==1
quietly replace random = 100 if ctag==0
sort random
quietly gen temp = 1 in 1/74
quietly replace temp = 0 in 75/148
quietly bys country:  egen tcountry = max(temp)
drop random temp

** choose 1 year between 1995 and 2010 at random
quietly gen temp1 = 1995+floor(runiform()*16) in 1
quietly egen temp2 = max(temp)
quietly gen tyear = year>temp2
drop temp*

** calculate country-year averages pre and post treatment
bys cid tyear:  egen meangdp = mean(lngdp)
egen regtag = tag(cid tyear)

** generate treatment dummy
quietly gen treatment = tcountry*tyear
*quietly reg lngdp treatment i.cid i.year, r
quietly reg meangdp treatment i.cid i.year if regtag==1, r

matrix v = r(table)
local temp_pval = v[4,1]
sort cid year
quietly replace pval = `temp_pval' in `i'
drop tcountry tyear treatment meangdp regtag

}

gen reject = pval<0.05 if pval!=.
