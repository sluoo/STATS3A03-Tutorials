*MULTIPLE LINEAR REGRESSION; 

*Run library command; 
LIBNAME S3A3 '/folders/myfolders';
run; 

*Import csDATA.csv into S3A3 library; 
PROC IMPORT datafile= '/folders/myfolders/csData.csv'
out=s3a3.csData
dbms=csv;
run; 

*Correlation Plot ( y=GPA, x1=HSM, x2=SATM); 
proc corr data=s3a3.csdata plots=matrix(histogram); 
 Var GPA HSM SATM;
run;

*We don't see much of a linear relationship between gpa and the covariates (most likely due to difference in magnitude of the data); 
*In reality, we probably should standardize the data but we will ignore it here;  

*Multiple linear regression using formulas (similar to question 2 in assignment)
*X,Y and inv_xtx are GIVEN TO YOU in the assignment but we have to create ours for this dataset;
*Follow previous tutorial on PROC IML; 

*Example I'm doing is more difficult compared to your HW; 

*Create X matrix; 
PROC IML; 
USE s3a3.csdata;
read all;

*Combine covariates into a matrix X;
x1x2 = HSM ||SATM;
nx = nrow(x1x2); *Number of rows;
px = ncol(x1x2); *Number of columns; 

*Create the column vectors of 1 and combine it was x1x2; 
b0 = repeat({1},nx,1); *what you want repeated, nrow, ncol;
x = b0 || x1x2;
print x;

*Create y vector; 
y = GPA; 
print y; 

*Create xtx_inv; 
xtx_inv = inv(t(x)*x); 
print xtx_inv;

*What is the regression line (find b0, b1, b2)?
*Refer to lecture 8 for formulas; 
betas = xtx_inv * t(x) * y; 
beta0 = betas[1,1];
beta1 = betas[2,1];
beta2 = betas[3,1];
print betas beta0 beta1 beta2;

*Find a 99% CI for b1.hat; 
*Formula on lecture 8 pg 22;

*Find sigmahat_square; 
e = y-x*betas;
sigmahat_square = t(e)*e / (nx-px-1);

*cov-var matrix of the betas ; 
cv_matrix = sigmahat_square*xtx_inv; 
print cv_matrix; *recall variance of betas is on the diagonal; 

*standard error of beta1;
sebeta1 = sqrt(cv_matrix[2,2]); 
print sebeta1;

*Lower/Upper Bound; 
alpha=0.01;
CILB = beta1-abs(Quantile("T",alpha/2,nx-px-1))*sebeta1; 
CIUB = beta1+abs(Quantile("T",alpha/2,nx-px-1))*sebeta1; 
print CILB CIUB;

*Create to table to view our results; 
VariableName=shape({HSM},1,1); *place orderly as in x; 
print VariableName beta1 sebeta1 CILB CIUB; 

quit; 

*Now using SAS: EASY WAY; 
PROC REG data=s3a3.csdata plots=none;
	 title "Mutiple Linear Regression Model -- Computer Science Data";
     model GPA = HSM SATM/CLB alpha=0.01;
run;

*Compare our results to the parameter estimates table for beta1! 

PREDICTIONS;
*Predict GPA if HSM=9 and SATM=600; 

Data s3a3.newScores;
Input HSM SATM;
Datalines;
9 600
;

Data s3a3.NewCS;
Set s3a3.newScores s3a3.csdata (keep=GPA HSM SATM);

PROC REG Data=s3a3.NewCS plots=none noprint;
Model GPA = HSM SATM/ alpha=0.01;
OUTPUT Out=s3a3.cspred (where=(GPA=.))
   Predicted=PredGPA
   LCLM=LowerCI
   UCLM=UpperCI
   LCL=LowerPI
   UCL=UpperPI;
run;
quit;

proc print data=s3a3.cspred; 
run; 



















