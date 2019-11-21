libname S3A3 '/folders/myfolders/';
run; 

PROC IMPORT datafile='/folders/myfolders/lab9sim.csv'
out=s3a3.dat
dbms=csv
replace; 
run; 

proc sgplot data = s3a3.dat; 
 scatter x = x y = y; 
run;

*From the plot, the variation of the residual changes for different 
covariate values, thus homoscedasticity assumption is violated. Estimate 
the weights and perform WLS.;

proc means data=s3a3.dat n mean std;
var y;
by x;
run;

*Only one covarite, use inverse of sample variance at each x-value as the weight; 
data s3a3.datwt;
set s3a3.dat;
if x=1 then wt=1/1.922**2;
else if x=2 then wt=1/4.382**2;
else if x=4 then wt=1/1.126**2;
else if x=6 then wt=1/0.673**2;
else wt=1/3.871**2;
run;

*Re-fit the model to the data using proc reg;
proc reg data=s3a3.datwt;
model y=x;
weight wt;
output out=fitres
residual=res
predicted=fitted;
run;


*Create weighted residual;
data fitres;
set fitres;
weightedres=res*sqrt(wt);
run;

*plot sqrt{wt}*residual for diagonosis ;
proc sgplot data=fitres;
scatter x=fitted y=weightedres;
run;

*OLS estimation on untransformed model;
proc reg data=s3a3.dat plots(only)=Residualbypredicted;
model y=x;
run;

*Comparing the two plots above, we see great improvements with WLS. 

*One way Anova - Second Example; 
PROC IMPORT datafile='/folders/myfolders/salary.csv' 
out=s3a3.salary
dbms=csv 
replace
;
run;

*Are there any differences in salary for each education level?;
PROC SGPLOT data=s3a3.salary;
vbox S/ category=E;
run; 

*S = salary E=education (1=high school, 2=bachelors, 3=advanced degree)

*Appears no diffence in salary between a bachelor and advanced degree . Avg salary
the lowest if you've only completed high school.

*Use regression to study this relationship further (i.e quantify the differences). Code dummy variables for E. 
E has 3 levels, so use 2 dummy variables E1, E2;
Data s3a3.salary;
    set s3a3.salary;
   * Construct the dummy variables with 0-1 coding;
    if E=1 then E1=1; else E1=0;
    if E=2 then E2=1; else E2=0;
    if E=3 then E3=1; else E3=0;
run;

*Fit regression with dummy variables; 
PROC REG Data=s3a3.salary plots=none;
    * In this model I will use Category 1 as the reference;
    Model S=E2 E3; 
run;

*Avg. Salary = 14942 + 3344*E2 + 3351*E3;  

*Intepretation: 
-Avg salary with a high school degree is $14,942 
-Avg salary with a bachelors is $3,344 more compared to a high school degree
-Avg salary with an advanced degree is $3,351 more compared to a high school degree

*This corresponds with out conclusions from before. 

*If we use GLM then we do not need to create dummy variables; 
PROC GLM Data=s3a3.salary plots=none;
    Class E;
    Model S=E /solution ;
run;

*Another way using PROC ANOVA;
PROC ANOVA Data=s3a3.salary plots=none;
    Class E; 
    Model S=E;
    Means E; 
run;

*Avg. Salary of Bachelor = 14942 + 3344*(1) + 3351*(0) = 18286.3684
*This corresponds to level of E=2 in the ANOVA procedure. 
  
















