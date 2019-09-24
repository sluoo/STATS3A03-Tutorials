*NOTE: If you are using the desktops at school you need to bring a USB drive or put everything into the K: drive (shared drive
*for the school) and save everything within there. Otherwise nothing will be saved!; 

*Create library. You must always run this command first to retrieve your data. 
Otherwise it will get stored in a temporary library; 
libname S3A3 "/folders/myfolders";
run;

*Import data iris1 to s3a3 library; 
PROC IMPORT datafile="/folders/myfolders/IRIS1.csv"
OUT=s3a3.iris /*where are you putting the data*/
dbsm=csv
replace; *overwrites the original name; 
run; 

*View table in results tab also better format; 
PROC PRINT data=s3a3.iris; 
run; 


*Plotting the data with PROC SGPLOT; 
PROC SGPLOT data=s3a3.iris; 
scatter x=sepal_length y=petal_length / group=species; *color the different type of flowers;
title "Iris Data Plot"; *give it a name; 
label petal_length = "Petal Length"; 
label sepal_length = "Sepal Length";
run; 

*Add regression line, confidence and prediction limits; 
PROC SGPLOT data=s3a3.iris; 
title "Scatterplot with regression line";
reg y=petal_length x=sepal_length / CLI CLM alpha=0.05;
run; 
quit; 

*PROC Corr: finding correlation coefficents, i.e. determine 
if there is a linear relationship between y and x,
H0: B1=0 vs Ha: B1 not equal to 0; 

PROC CORR data=s3a3.iris; 
VAR sepal_length;
WITH petal_length;
RUN;
QUIT; 

*Here the p-value is less than 0.05, there is evidence against
H0 and we conclude that a linear relationship exist between
petal length and sepal length; 

*Assume assumptions hold! MODEL: petal_length = b0 + b1*sepal_length;

PROC REG data=s3a3.iris PLOTS=none;
MODEL petal_length = sepal_length; * always the dependent = independent i.e. y = x1 x2...; 
TITLE "Simple Linear Regression";
run; 

*The Simple Linear Regression Model: petal_length = -7.09 + 1.85*sepal_length; 

*Use model to obtain the fitted values and residuals for each 
point. Put it in a seperate dataset; 
PROC REG data=s3a3.iris plots=none; 
model petal_length = sepal_length; 
output out=s3a3.iris_predicted
predicted= fitted 
residual=residuals; *res = observed-fitted; 
run; 

*Print the dataset; 
proc print data=s3a3.iris_predicted;
run; 

*Quantiles; 
data s3a3.quantile; 
q1 = quantile("T",0.01,6); *t-dist;
q2 = quantile("F",0.95,1,5); *f-dist; 
run; 

proc print data=s3a3.quantile; 
run; 

*P-Value for T distribution; 
data s3a3.pvalue; 
p1=(1-CDF("T",3.14,6))*2;  *symmetric for T-dist;
p2= 1-CDF("F",6.61,1,5); *F-distr; 
run; 

proc print data=s3a3.pvalue; 
run; 

*To save code, press the floppy disk and save in myfolders. 
*To save results, code to result tab and click on the second icon to download as pdf. 







































































































