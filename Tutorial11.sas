libname S3A3 '/folders/myfolders/';
run; 

PROC IMPORT datafile='/folders/myfolders/redwinequality.csv'
out = s3a3.wine
dbms=csv
replace;
run; 

PROC PRINT data=s3a3.wine; 
run; 

*quality -> dependent variable
*everything else -> independent variables

We have 11 indepdent variables. It will be tedious to type each these variables in the
MODEL part of PROC REG. Instead, we will create a macro variable. Essentially,
it's like creating a list() in R; 

proc sql;
select name into :ivars separated by ' ' /*select the names and put into a variable called ivars*/
from dictionary.columns /*capturing all the information related to covariates*/
where libname eq 'S3A3' /*this is my library*/
and memname eq 'WINE' /*name of the data*/
and name ne 'quality'; /*variable to not include*/ 
quit;

/*Backward Selection - start with all the variables and drop one variable at a time*/ 
Title "Backward Selection";
proc reg Data=s3a3.wine plot=none;
model quality=&ivars/Selection=Backward SLStay=0.05; *alpha=0.05;
run;

*Criteria: 
Remove the independent variables where pvalue is greather than 0.05,
continue until all variables left in the model are significant at the 0.05;



/*Forward Selection - starts with no variables only a constant term, then add
one variable at a time (once added you cannot delete)*/ 
Title "Forward Selection";
proc reg Data=s3a3.wine plot=none;
model quality=&ivars/Selection=Forward SLEntry=0.05;
run;

*Criteria: 
Only variables with pvalue less than 0.05 is considered. STOP when the last
variable entering the model has an pvalue greather 0.05 (insignificant).
 

/*StepWise - start like forward but we can delete variables like backward;
Title "Stepwise Selection";
proc reg Data=s3a3.wine plot=none;
model quality=&ivars/Selection=Stepwise SLStay=0.05 SLEntry=0.05;
run;

*Criteria:
Combine the two criterias above. 

*All three methods selected the same 7 variables - this rarely happens btw. 

**Subset Selection & ICs;
PROC REG Data=s3a3.wine plots=cp;
    Model quality=&ivars/ Selection=CP;
run;

*Criteria for Cp:
Pick the model such that Cp is close to p+1

So based on this with p=11, we can either select  model 20,21 or 22 because Cp is close to 12.
Any of these would be fine but we should select model 22 with 7 variables. Since all 3 models will perform
similarly, we select the model with less parameters (why? less estimating and easier interpretation)
This is the principle of parsimony...; 


PROC REG Data=s3a3.wine plots=none;
    Model quality=&ivars / Selection=AdjRsq;
run;

*Criteria: Select models with the highest adjusted R^2.

*This is annoying to look at, let's look at the best 5; 
PROC REG Data=s3a3.wine plots=none;
    Model quality=&ivars / Selection=AdjRsq best=5;
run;

*Based on this select 8 variables.. 

*Run all of this together; 
Title "All Subset AIC BIC";
proc reg Data=s3a3.wine plot=none OUTEST=MODELSELECTION;
model quality=&ivars/Selection= CP AIC BIC;
run; 

PROC SORT DATA=MODELSELECTION OUT=MODELSELECTION;
BY AIC;
RUN;

PROC SORT DATA=MODELSELECTION OUT=MODELSELECTION;
BY _BIC_;
RUN;
*Criteria: Select the lowest AIC or BIC value;

*BIC=-1380 and AIC=-1378, 7 variables. 
 
*CONCLUSION: 
What should we choose? Slighly different conclusions from each method. 
AIC, BIC and the 3 selection methods suggest: 

volatile_acidity chlorides free_sulfur_dioxide total_sulfur_dioxide pH sulphates alcohol

FINAL MODEL; 
PROC REG data=s3a3.wine plots=none; 
model quality = volatile_acidity chlorides free_sulfur_dioxide total_sulfur_dioxide pH sulphates alcohol;
run; 

















