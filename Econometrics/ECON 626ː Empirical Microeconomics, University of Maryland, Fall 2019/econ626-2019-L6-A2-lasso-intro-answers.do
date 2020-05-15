// ECON 626:  EMPIRICAL MICROECONOMICS (FALL 2019)
// L6. SELECTION ON OBSERVABLES
// IN-CLASS ACTIVITY 2. INTRO TO LASSO 
// WRITTEN BY PAM JAKIELA & OWEN OZIER

// SETUP

** install lassopack, pdslasso if not already installed
*ssc install lassopack
*ssc install pdslasso

** preliminaries
clear
set seed 12345
set obs 200
gen id = _n

** generate outcome and covariates
forvalues i = 1/9 {
	gen A`i' = rnormal()
	gen B`i' = rnormal()
	gen C`i' = rnormal()
}

forvalues i = 1/20 {
	gen D`i' = rnormal()
}

egen sumA=rowtotal(A*)
egen sumB=rowtotal(B*)
egen sumC=rowtotal(C*)
egen sumD=rowtotal(D*)

gen Y = 0.5*sumA + 0.2*sumB + 0.1*sumC + rnormal()

// 1. OLS
reg Y A* B* C* D* if id<=100
reg Y A* B* C* D* if id>100

// 2. Stepwise selection
reg Y A* B* C* D* if id<=100 // step 1
reg Y A* B1 B2 B4 B7 C1 C3 C9 D11 D13 D17 D18 if id<=100 // step 2
reg Y A* 	B2 	  B7 	C3 C9 D11 	  D17 D18 if id<=100 // step 3
reg Y A* 	B2 	  B7 	C3 C9 D11 	  D17 D18 if id>100 // out-of-sample prediction

// 3. LASSO
lasso2 Y A* B* C* if id<=100

// 4. LASSO (EBIC)
lasso2, lic(ebic)
reg Y A* B2 B4 B6 C3 D15 if id>100

// 5. LASSO (AIC)
lasso2 Y A* B* C* D* if id<=100
lasso2, lic(aic)
reg Y A* B* C1 C2 C3 C4 C6 C7 C9 D4 D5 D7 D9 D10 D11 D12 D13 D15 D17 D18 D19 D20 if id>100

// 6. Square-root LASSO
lasso2 Y A* B* C* D* if id<=100, sqrt
lasso2, lic(ebic)
reg Y A* B2 B4 B6 C3 C9 D15 if id>100

// 7. Cross-validated LASSO
cvlasso Y A* B* C* D* if id<=100
cvlasso, lopt
reg Y A* B1 B2 B3 B4 B5 B6 B7 B9 C1 C2 C3 C4 C6 C7 C9 D4 D5 D7 D9 D10 D11 D12 D13 D15 D17 D18 D19 D20 if id>100

// 8. So-called "rigorous" LASSO (theoretically-motivated choice of lambda)
rlasso Y A* B* C* D* if id<=100
reg Y A1 A2 if id>100



