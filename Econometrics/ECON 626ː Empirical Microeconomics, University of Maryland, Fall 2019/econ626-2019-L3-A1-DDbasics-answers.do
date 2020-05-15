// ECON 626:  EMPIRICAL MICROECONOMICS (FALL 2019)
// L3. DIFFERENCE-IN-DIFFERENCES
// IN-CLASS ACTIVITY 1. BASICS
// WRITTEN BY PAM JAKIELA & OWEN OZIER

// preliminaries
clear
set seed 1234
*cd "INSERT FILE PATH HERE"

use DD_data1

/* PROBLEM 1 */

gen treatment = programschool*(year==2009)

/* PROBLEM 2 */

reg score treatment if year==2009

/* PROBLEM 3 */

reg score treatment if programschool==1

/* PROBLEM 4 */

gen post = (year==2009)
reg score program post treatment

/* PROBLEM 5 */

drop treatment post
reshape wide score, i(id) j(year)
gen scorediff = score2009 - score2008
reg scorediff programschool

