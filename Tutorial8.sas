libname S3A3 '/folders/myfolders';
run; 

/*Polynomial and Piecewise Regression*/ 
PROC IMPORT datafile= '/folders/myfolders/voltage.csv'
out=s3a3.volt
dbms=csv 
replace; 
run; 

*Scatterplot; 
PROC SGPLOT data=s3a3.volt;
scatter x=time y=voltagedrop; 
run; 

*x and y are not linearly related, thus cannot model with a linear regression.
we wish to model the data with a polynomial regression; 

*voltagedrop = b0 + b1*time + b2*time^2 + b3*time^3 + .... + bd*time^d; 

*which d-order polynomial best fits the data?

*Find the best d by examining the different models; 
data s3a3.volt1;
set s3a3.volt;
x2 = time**2;
x3 = time**3; 
x4 = time**4; 
x5 = time**5; 
run; 

Title "Model 1: d=1, Linear Regression";
PROC REG data=s3a3.volt1 plots(only)= (Residualplot residualbypredicted QQPlot);
model voltagedrop = time; 
run; 


Title "Model 2: d=2";
PROC REG data=s3a3.volt1 plots(only)= (Residualplot residualbypredicted QQPlot);
model voltagedrop = time x2; 
run; 


Title "Model 3: d=3";
PROC REG data=s3a3.volt1 plots(only)= (Residualplot residualbypredicted QQPlot);
model voltagedrop = time x2 x3; 
run; 

Title "Model 4: d=4";
PROC REG data=s3a3.volt1 plots(only)= (Residualplot residualbypredicted QQPlot);
model voltagedrop = time x2 x3 x4; 
run; 


Title "Model 5: d=5";
PROC REG data=s3a3.volt1 plots(only)= (Residualplot residualbypredicted QQPlot);
model voltagedrop = time x2 x3 x4 x5; 
run; 

*Assumptions are clearly violated in all models. For model 5, there is a random scatter in the 
residual by predicted plot, but the QQPlot indicates the normality assumption is not satisfied. 
Thus polynomial regression does not work here. 

*From the scatterplot, it appears that there are two points (x=6.5 and x=13) where the trend changes. 
*These points are called knots and partitions the data into intervals. 
*Thus, fit seperate regression to each interval. 

*Assume cubic piecewise regression (lecture 17, pg 33); 
data s3a3.volt2; 
set s3a3.volt;
x2 = time**2;
x3 = time**3; 
x4 = max(time-6.5,0)**3; 
x5 = max(time-13,0)**3; 
run; 

TITLE "Cubic Piecewise Regression"; 
PROC REG data=s3a3.volt2 plots(only)=(Residualplot residualbypredicted QQPlot); 
model voltagedrop = time x2 x3 x4 x5;
run; 

*We see slight improvement to model 5. cubic piecewise regression is still preferred because 
there are less paramters (more parsimonious); 

/*WLS*/ 
PROC IMPORT datafile='/folders/myfolders/HeteroData.csv'
out=s3a3.dat
dbms=csv
replace; 
run; 

TITLE "Model 1: Without WLS"; 
PROC REG data=s3a3.dat plots(only)= (Residualplot residualbypredicted QQPlot); 
model y=x;  
run; 

*Clear violations of the constant variance assumption; 

*To satsify this assumption, we will try an appropiate transformation and WLS from lecture 17; 
Data s3a3.datmod; 
set s3a3.dat; 
yprime= y/x; 
xprime= 1/x;
weights = 1/x**2;
run; 

*Transformed Model; 
PROC REG data=s3a3.datmod plots(only)=(Residualplot residualbypredicted QQPlot); 
Model yprime = xprime; 
run; 

*WLS; 
PROC REG data=s3a3.datmod plots = none;
Model y=x;
weight weights; 
output out=fitres
residual = res
predicted=fitted;
run; 


*For WLS, the residuals must be modifeid; 
*Create weighted residual; 
data fitres; 
set fitres; 
weightedres = res*sqrt(weights);
run; 

*Plot sqrt{weight}*residual for diagnosis; 
PROC SGPLOT data=fitres;
scatter x=fitted y=weightedres;
run; 

*we see improvements with WLS. 

































 

















































 


















































