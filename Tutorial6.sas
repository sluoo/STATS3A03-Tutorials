LIBNAME s3a3 '/folders/myfolders/';
run; 

PROC IMPORT datafile='/folders/myfolders/airquality.csv' 
out=s3a3.airquality
dbms=csv 
replace;
run;

*Fit regression and check resiudal plots; 
Proc reg DATA=s3a3.airquality 
PLOTS(only)=Residualplot  /*Residuals vs Predictors - Check for constant variance & linearity*/
PLOTS(only)=QQPlot        /*Check normality assumption*/
PLOTS(only)=Residualbypredicted; /*Residuals vs Fitted - Check for constant variance & linearity*/
model ozone=Solar_R Wind Temp;
run;


*Constant variance assumption violated - fanning out pattern 
*Normality assumption violated - points do not close to y=x

*Fix with log transform on ozone; 
data s3a3.airnew; 
set s3a3.airquality; 
logOzone = log(ozone); 
run;


* Influential obs. must be analyzed before they can be removed
* Outliers: external studentized residuals are large 
* Leverage points: leverage vaues are large;


PROC REG DATA=s3a3.airnew plot (label only)=(RstudentByLeverage);
model logozone=Solar_R Wind Temp;
run;

*according to SAS: outliters - 20, 77, 102, leverage = 7,14,30 and both = 17; 
*cannot conclude influential yet, check 3 other measures;

*Cooks distance, DFFITS and DFbetas*;
Proc reg DATA=s3a3.airnew plot (label only)=(COOKSD DFFITS DFBETAS);
model logozone=Solar_R Wind Temp;
run;

*the larger CookSD, DFits, DFbetas are -> more influential; 

*Store these values in a dataset; 
proc reg data=s3a3.airnew plots=NONE;
	model logozone=solar_r wind temp;
	output out=s3a3.airinfluence 
	H=leverage
	DFFITS=influence
	COOKD=cooksd;
run;

PROC PRINT data=s3a3.airinfluence; 
run; 

*always best to these analysis graphically but sometimes you may want these values (like for the assignment)

*17 is an influential point, remove and refit;
data s3a3.airqualitynew; 
set s3a3.airnew; 
if _n_= 17 then delete; 
run; 

*Now refit with this dataset; 
Proc reg DATA=s3a3.airqualitynew 
PLOTS(only)=Residualplot  
PLOTS(only)=QQPlot        
PLOTS(only)=Residualbypredicted;
model logozone=Solar_R Wind Temp;
run;

*log transform + removal 17 improved model fit;








