/*
UMD ECON-626 FALL 2019
Power, PART 2: multiple periods (the case for more T)
*/

// -------------------------------------------------------------
// INSTALLATION OF CLUSTER ADJUSTMENT TO SAMPLE SIZE CALCULATION
capture which sampclus
if _rc!=0 {
  net install sxd4, from(http://www.stata.com/stb/stb60)
}
