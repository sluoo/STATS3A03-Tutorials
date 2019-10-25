libname s3a3 '/folders/myfolders';
run; 

proc import datafile='/folders/myfolders/gala.csv'
out= s3a3.gala
dbms=csv; 
run; 

*Assumptions about Regression
1. Linearity assumption
2. Errors are iid with mean zero and constant variance.
3. Normality assumption of the errors
4. Assumptions about the covariates 

*Run regression on gala; 
Title 'Model 1: Gala Regression';
PROC REG data=s3a3.gala plots=none;
model species = area elevation nearest scruz adjacent; 
run; 

*R^2 = 0.76, just because it is close to 1 does not mean it is a good model. 
We should not rely on this entirely, we must check the assumptions.; 


*For many of these plots, we want to see random scatters! If we see patterns,
it is an indication that the assumptions are violated!!; 

Title 'Residuals vs Covariates';
PROC REG data=s3a3.gala plots(only)=Residualplot; 
model species = area elevation nearest scruz adjacent;
run; 

*It appears tht constant variance assumption is violated. 
*For elevation, we see a fanning out pattern since 
residuals increase as x increases; 

Title 'Residual vs Fitted Values';
PROC REG data=s3a3.gala plots(only)=residualbypredicted;
model species = area elevation nearest scruz adjacent;
run; 

*Constant variance assumption is violated -- fanning out pattern is seen about 
the resiudal = 0 axis.; 

Title 'QQPlot';
PROC REG data=s3a3.gala plots(only)=QQPlot; 
model species = area elevation nearest scruz adjacent;
run; 

*Points do not lie close to the y=x line, it also appears we have 
an outlier near the end. Normality assumption violated; 

*Try transformation to fix problem with sqrt transform; 
Data s3a3.galaNew; 
SET s3a3.gala;
sqrtSpecies=sqrt(species); 

proc print data=s3a3.galaNew; 
run; 

*New Model + look at various types of residuals; 
Title 'Model 2: Gala Regression with Transformation'; 
PROC REG data=s3a3.galanew plots(only)=residualbypredicted;
model sqrtSpecies = area elevation nearest scruz adjacent; 
output out= s3a3.galanewRes
residual = Res /*raw residual*/ 
Student = Stdres /*internally studentized residuals*/ 
Rstudent = Rstdred /*Externally studentized residuals*/ 
predicted=yhat; /*fitted value*/
run; 

*After transfomration, points appear randomly scattered (no fanning out pattern like before),
overall plots looks a lot better. 

*Check if errors are iid/uncorrelated; 
Title 'Residual vs Index';
Data s3a3.index1; *create index; 
do obs=1 to 30;
output; 
end; 
run; 

*Combine with data; 
Data s3a3.index_res; 
set s3a3.index1;
set s3a3.galanewres;
output; 
run; 


*Plot use sgplot; 
proc sgplot data=s3a3.index_res; 
scatter x=obs y=stdres;
run; 

*Randomly scatterned around mean zero hence errors are uncorrelated. 


























































