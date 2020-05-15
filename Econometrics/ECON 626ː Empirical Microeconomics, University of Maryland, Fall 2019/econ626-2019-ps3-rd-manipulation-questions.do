/*
UMD Econ-626
PS 3 QUESTION 4: Regression discontinuity with manipulated running variables.
*/

/* --------------------------------------------------------------------------------- */
/* We begin by generating data for a hypothetical poverty-targeted social protection program. */

clear all
version 11.2
version 11.2: set seed 9876
set obs 10000

/* Initial wealth will vary on a scale from -1 to 1. */
gen truewealth=2*uniform()-1
/* Noisy measure of partial assets */
gen someassets=truewealth*0.5+0.1*uniform()


/* What wealth do program applicants report at the time of the poverty targeting exercise? */

/* In one scenario, program applicants report their true wealth. */
gen reportwealth1=truewealth

/* In one scenario, program applicants report their true wealth with some noise. */
gen reportwealth2=truewealth+0.1*invnorm(uniform())

/* In another scenario, program applicants with true wealth above 0 but below 0.5 
   sometimes misrepresent themselves as having wealth just below the cutoff.      */
gen reportwealth3=cond(truewealth>0 & uniform()<0.8 & truewealth<0.5*uniform(),-0.5*abs(uniform()+uniform()-1),truewealth)

/* In another scenario, program applicants in general
   sometimes misrepresent themselves as having lower wealth, but not with any precision.      */
gen reportwealth4=cond(uniform()<0.5 & truewealth>-0.5*uniform(),truewealth-0.5*uniform(),truewealth)


/* --------------------------------------------------------------------------------- */

/*

4.1 Density

Take a look at the densities of each of the three reported wealth variables.
Make sure that you can see the density separately on both sides of zero.
You might try the histogram command, forcing a starting point and a bin
width that goes evenly into 1, such as 0.1, 0.01, or something in between.

What do you see?   

*/

/* ******** YOUR COMMANDS HERE ******** */








/*

4.2 Density test

Justin McCrary and Brian Kovak have developed code to test for a density
change at the cutoff; McCrary's website has the code and an example of its use:
http://emlab.berkeley.edu/~jmccrary/DCdensity/

Be sure the DCdensity.ado is in one of your Stata ado directories, probably
the "PERSONAL" one.  To find out where this is, you can type: sysdir

Having done that, the basic McCrary command in this setting is of the form:

DCdensity <running variable>, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)

You can try this for each of the three running variables.  Running the command
will generate the variables listed, so in between running this for a new variable,
be sure to drop the generated variables.  You might use this command to do that:

capture drop Xj Yj r0 fhat se_fhat

The McCrary routine will report, among other things, the estimated
log difference in density height, and the standard error of that estimate.
For which of the three variables can you reject the null hypothesis of
a zero change in density?

*/

/* ******** YOUR COMMANDS HERE ******** */





/* Several more lines of data generating process: */
/* Now we add the treament. */
/* In each case, treatment in the social safety net program is determined by reported wealth being below the cutoff. */
gen t1=cond(reportwealth1<0,1,0)
gen t2=cond(reportwealth2<0,1,0)
gen t3=cond(reportwealth3<0,1,0)
gen t4=cond(reportwealth4<0,1,0)

/* here are the interactions between treatment and the running variable: */
gen t1r=reportwealth1*t1
gen t2r=reportwealth2*t2
gen t3r=reportwealth3*t3
gen t4r=reportwealth4*t4

/* add a treatment effect to unobserved true wealth */
gen newwealth1=truewealth+t1*0.2+0.25*invnorm(uniform())
gen newwealth2=truewealth+t2*0.2+0.25*invnorm(uniform())
gen newwealth3=truewealth+t3*0.2+0.25*invnorm(uniform())
gen newwealth4=truewealth+t4*0.2+0.25*invnorm(uniform())

/*

4.3 Biased estimates of treatment effect under manipulation

Assume we do *not* observe the initial true wealth, but we do observe
the reported initial wealth, the treatment status, and the new wealth.

Using the regress command to conduct a regression discontinuity analysis,
estimate the effect of the program in each scenario (t1, t2, t3, t4) on
the outcome, (newwealth1/2/3/4).  Control for the running variable on both
sides of the cutoff.  Try relatively wide and narrow bandwidths.

After exploring with the regress command, use the rd or rdrobust command.

(Note that the estimates of treatment effects that "rd" finds will be
 negative because treatment goes from one to zero at the cutoff rather
 than from zero to one.)

What do you find?  What is the true effect?
When do the estimated effects differ from the true effect, and why?

*/

/* ******** YOUR COMMANDS HERE ******** */











/*
4.4 Baseline covariates

The "someassets" variable is highly correlated with true wealth.
The regression discontinuity design depends on unobserved covariates
not changing at the cutoff score.  Indeed, "someassets" is a pre-program
measure, so it *should* not change at the cutoff score.  For each of
the four versions of reported wealth and the associated cutoff, does
"someassets" change discretely at the cutoff?  If it does, we should
worry that the RD design would not yield credible estimates of program
impact. 

*/

/* ******** YOUR COMMANDS HERE ******** */








/*
4.5 Continuation

Consider what would happen if the program were targeted based on true initial
wealth (data generating process 1), but instead of observing true initial wealth,
we only observed wealth with substantial noise.  For example, type:

 gen reportwealth1b = reportwealth1 + 0.5*invnorm(uniform())

This is mis-reporting, rather than manipulation, since the program is actually
targeted correctly.  Now run the analysis for t1 but observing only reportwealth1b,
not reportwealth1.  What goes wrong?  Is there a jump in treatment status at
reported wealth equal to zero? (you might use rdplot or other commands to see this.)

*/
 
/* ******** YOUR COMMANDS HERE ******** */



