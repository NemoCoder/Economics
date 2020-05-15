// ECON-626 2019
// RD ACTIVITY
// POSSIBLE ANSWERS
// OWEN OZIER 

// 1 
reg secondary jump test intTestJump if abs(test)<0.8, vce(cluster test)
// this agrees with the paper

// 2
rdrobust secondary test
rd secondary test
// smaller bandwidth: 0.36 or 0.37 rather than 0.8 on either side.
// this shows a larger effect, identified from the locally different slope
// on the left side of the cutoff that would be smoothed out with a larger
// bandwidth (and weighted with the triangular rather than rectangular kernel).


// 3
rdplot secondary test
// this shows the pattern discussed above

// 4
rd secondary test, k(rect) bw(0.8)
reg secondary jump test intTestJump if abs(test)<0.8, r
// the results agree

// 5
reg rv jump test intTestJump if abs(test)<0.8, vce(cluster test)
rd rv test
rdplot rv test
// again it looks like the automatically selected bandwidth
// is smaller.  a similar pattern as seen before: the effect
// estimated in the smaller bandwidth is larger.

// 6
ivregress 2sls rv (secondary=jump) test intTestJump female if abs(test)<0.8, vce(cluster test)
// this lines up with the paper.

// 7
rd rv secondary test
// again a larger effect.  read the "lwald" line, which is "numer" divided by "denom."
// not as pronounced with twice the automatically selected bandwidth - reading from the "lwald200" line.
