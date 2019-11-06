libname S3A3 "/folders/myfolders";
run; 

PROC IMPORT datafile="/folders/myfolders/wool.csv"
out = s3a3.wool
dbms=csv 
replace; 
run; 

PROC PRINT data=s3a3.wool;
run;

*Understand how cycles to failure depend on these factors;
*Each factor (covariate) has 3 levels; 

*Exploratory analysis; 
PROC MEANS data=s3a3.wool mean median q1 q3 min max; 
var cycles; 
run; 

*Boxplot; 
PROC SGPLOT data=s3a3.wool;
vbox cycles; 
run; 

*Pairwise Scatterplot; 
PROC SGSCATTER data=s3a3.wool;
MATRIX cycles len amp load; 
run; 

*Fit regression -- cycles = b0 + b1*len + b2*amp + b3*load;
*check regression plots; 
TITLE "Model 1";
proc reg data=s3a3.wool plots(only label)=(Residualplot residualbypredicted QQPLOT);
model cycles = len amp load; 
run; 

*We see patterns; 
*constant variance and normality assumption are violated hence use 
*box-cox transform; 

*Transform the dependent variable cycles using Boxcox approach; 
PROC TRANSREG details data=s3a3.wool SS2 plots=res; 
model boxcox(cycles/lambda=-2 to 2 by 0.05) = identity(len amp load); 
run; 

*Select lambda where the log-likelihood is maximized
in this case, lambda = 0. Hence we apply a log transformation to cycles; 
data s3a3.woolnew; 
set s3a3.wool; 
logcycles = log(cycles);
run; 

*Rerun regression with logcycles; 
*Does it improve the residuals?; 
TITLE "Model 2";
proc reg data=s3a3.woolnew plots(only label)= (ResidualPlot residualbypredicted QQPLOT); 
model logcycles = len amp load; 
run; 

*Model 2 is an improvement of Model 1 based on the residuals; 
*QQ Plot still not too great, we may have outliers or influential points; 
*Check for obs. with large Rstudent and leverage; 
PROC REG data=s3a3.woolnew plot(label only)=(RstudentbyLeverage); 
model logcycles = len amp load; 
run; 

*obs. 24 may be an outlier. 

*Find obs. with large cook's distance, dffits and dfbetas;
PROC REG data=s3a3.woolnew plot(label only)= (Cooksd dffits dfbetas);
model logcycles = len amp load; 
run; 

*Based on these 3 measures, it seems 24 and 27 may be influential.
*remove them and examine if there are any changes; 

data s3a3.woolnew2; 
set s3a3.woolnew;
if _n_ = 24 or _n_=27 then delete; 
run; 

proc print data=s3a3.woolnew2; 
run; 

Title "Model 3"; 
proc reg data=s3a3.woolnew2 plots(only label)= (Residualplot residualbypredicted QQPlot); 
model logcycles = len amp load; 
run; 

*Comparing Model 2 and 3.... 
*The fit didn't change a lot after deleting the observations. 
The estimates for the coeffcients didn't vary much. 
*Therefore obs. 24 and obs.27 do not appear to be strongly infludential; 

*Interpret and find a 99% CI for beta1 with woolnew2 dataset; 
PROC REG data=s3a3.woolnew2 PLOTS=NONE; 
model logcycles = len amp load /CLB alpha=0.01;
run; 

*logcycles = 9.52 + 0.01778*x1 - 0.6068*x2 - 0.06720*x3 
* cycles = exp(9.52 + 0.01778*x1 - 0.6068*x2 - 0.06720*x3)
* cycles = exp(9.52)* exp(0.01778*x1)*..........

Interpretation: 
On average,the number of cycles increases by a multiple of exp(0.01778)= 1.01 for 
every mm increase in length, while all other factors are held constant* 

*99 CI for beta1 (len) is (0.01573,0.01983). 


















 



































































































