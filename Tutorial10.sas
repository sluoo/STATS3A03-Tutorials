libname S3A3 '/folders/myfolders/';
run; 

PROC IMPORT datafile='/folders/myfolders/batteries.csv'
out=s3a3.batteries
dbms=csv
replace; 
run; 

*Devices - 3 levels
*Brand - 2 levels 
Life - continuous 

/Question 1:
Is there an overall difference in lifetime between the battery brands?;

*Exploratory; 
PROC SGPLOT data=s3a3.batteries;
vbox life / category=brand;
run; 

*From boxplots, it appears there is an overall difference in lifetime between brand A and B.;


PROC GLM Data=s3a3.batteries plots=none;
    Class Brand Device;
    Model Life=Brand /solution;
run;

*NOTE: SAS choose B to be the reference category, so Brand=0. 

Regression:
lifetime = 8.02 - 1.79*Brand

Intepretation: 
average lifetime for A is 1.79 hours less than B
average lifetime for B is 8.02



*Need 1 dummy variable only because 2 categories for Brand; 
Data s3a3.batteries;
set s3a3.batteries;
	*Brand A is reference category;
if Brand="B" then BrandB=1; else BrandB=0;
run;

PROC REG data=s3a3.batteries plots=none; 
model Life = BrandB; 
run; 

*Regression: 
lifetime = 6.20 + 1.79*BrandB

Interpretation: 
average lifetime for B is 1.79 hours more than A
average lifetime for A is 6.20 

*So depending on reference category, interpretation is different but same conclusion. 

/Question 2
What happens to the coefficient estimate, standard error, and p-value for Brand B if we take
device into account?;

PROC GLM Data=s3a3.batteries plots=none;
    Class Brand Device;
    Model Life=Brand Device/solution;
run;

Data s3a3.batteries1;
    Set s3a3.batteries;
	If Device='Radio' then Radio=1; else Radio=0;
	If Device='DVD' then DVD=1; else DVD=0;
	If Device='Camera' then Camera=1; else Camera=0;
run;


PROC REG Data=s3a3.batteries1 plots=none;
   * In this case I will use Radio as the reference category of Device;
   Model Life=BrandB DVD Camera;
run;

*With device included, estimate for brand b remained the same, standard of error decreased from 0.800 to 0.467.
*assuming alpha=0.01, before p=0.0351  (not statistically significant) and now p=0.0010 (statistically significant). 


/Question 3
Is there any evidence of an interaction between brand and device? What happens to the
main effect of brand if we have an interaction term in the model?;

*PROC REG is not preferred for models with interactions, so use PROC GLM; 

PROC GLM Data=s3a3.batteries plots=none;
    Class Brand Device;
    Model Life=Brand Device Brand*Device/solution;
run;

PROC GLM Data=s3a3.batteries plots=none;
    Class Brand Device;
    Model Life=Brand Device/solution;
run;

*Use F-test in Type III SS Table. Assume alpha = 0.01, from table pvalue=0.7481. 
Since p >>> alpha, we conclude no interaction between brand and device. 

If interactiona added, brand is not statistically significant. 













