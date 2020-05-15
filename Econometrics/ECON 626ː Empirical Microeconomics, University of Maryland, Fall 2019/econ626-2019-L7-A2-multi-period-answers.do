/*
UMD ECON-626 FALL 2019
Power, PART 2: multiple periods (the case for more T)
*/

set more off

// consider typing "help sampsi"

// 2.1.
// we have a guess about the mean among CONTROL    = 0
// we have a guess about the mean among TREATMENT  = 0.5
// we have a guess about the SD of the outcome     = 1
// we want to have enough observations for power   = 0.80
// what sample size is needed? use the sampsi command.
sampsi 0 0.5, p(0.8) sd1(1)

// 2.2.
// to these four options, add:
//   pre(1) post(1) r1(0) r01(0)
// meaning
//  one pre-treatment observation per unit
//  one post-treatment observation per unit
//  zero correlation from pre to post
//  zero correlation among post treatment observations
// nothing changes for two methods, but a change for one method.  why?
sampsi 0.5 0, ratio(1) p(0.8) sd1(1) pre(1) post(1) r1(0) r01(0)

// 2.3.
// now change the correlations (r1 and r01) which had been set to zero:
// first so they are both 0.2,
// then so they are both 0.4,
// then so they are both 0.6.  What happens?
sampsi 0.5 0, ratio(1) p(0.8) sd1(1) pre(1) post(1) r1(0.2) r01(0.2)
sampsi 0.5 0, ratio(1) p(0.8) sd1(1) pre(1) post(1) r1(0.4) r01(0.4)
sampsi 0.5 0, ratio(1) p(0.8) sd1(1) pre(1) post(1) r1(0.6) r01(0.6)

// 2.4.
// now with each of those correlations,
// try setting the number of "pre" observations to zero,
// and the number of "post" observations to 2.
// What changes?  Why?
sampsi 0.5 0, ratio(1) p(0.8) sd1(1) pre(0) post(2) r1(0.2) r01(0.2)
sampsi 0.5 0, ratio(1) p(0.8) sd1(1) pre(0) post(2) r1(0.4) r01(0.4)
sampsi 0.5 0, ratio(1) p(0.8) sd1(1) pre(0) post(2) r1(0.6) r01(0.6)

