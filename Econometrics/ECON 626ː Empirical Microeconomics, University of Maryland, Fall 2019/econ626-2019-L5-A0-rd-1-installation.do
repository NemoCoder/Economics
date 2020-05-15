// -------------------------------------------------
// INSTALLATION OF REGRESSION DISCONTINUITY ROUTINES

// Cattaneo-Calonico-Farrell-Titiunik - rdrobust and rdplot
// Note that this may require Stata 13.1 or higher.
// (requires MATA features that don't exist in Stata 13.0 and below.)
capture which rdrobust
if _rc!=0 {
  net install st0366_1.pkg, from(http://www.stata-journal.com/software/sj17-2)
}

// Austin Nichols - rd
// Note this program has been in existence longer than the rdrobust package
capture which rd
if _rc!=0 {
  ssc install rd, replace
}

