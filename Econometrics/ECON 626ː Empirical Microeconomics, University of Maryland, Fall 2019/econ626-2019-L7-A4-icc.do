/*
UMD ECON-626 FALL 2019
Intra-class correlation and variance
*/

// initialize the random number generator
version 11.2
version 11.2: set seed 2468

clear all
// generate group draws ("nu")
set obs 1000
gen n1g=invnorm(uniform())
gen gi=_n
// make groups of size 100
expand 100
// generate individual draws ("eta")
gen n2i=invnorm(uniform())

// pick standard deviations of the individual and group components
local sdg=3
local sdi=4
// calculate the variances and the total SD
local varg=`sdg'^2
local vari=`sdi'^2
local vart=`varg'+`vari'
local sdt=sqrt(`vart')
// calculate the intra-cluster correlation
local predictedicc=`varg'/`vart'

// simulate
gen y=`sdg'*n1g+`sdi'*n2i

// estimate icc
loneway y gi
local estimatedrho=r(rho)

// compare to the estimate
di "Predicted icc `predictedicc'; estimated icc `estimatedrho'"

