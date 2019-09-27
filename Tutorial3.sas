*Run library command; 
libname s3a3 '/folders/myfolders';
run; 

*Import iris data into library s3a3;
PROC IMPORT datafile='/folders/myfolders/IRIS.csv'
out=s3a3.iris
dbms=csv;
run; 

*We will predict mean response and individual predictions for 
the petal_length variable. Both are calcualted the same but have
different standard of errors; 

*Given x=sepal_length, determine 99% CI/PI for mean response mu 
and indiviudal predictions yhat; 

PROC REG data=s3a3.iris (keep=petal_length sepal_length) PLOTS=none;
model petal_length =  sepal_length /alpha=0.01; 
output out=s3a3.irisprediction
PREDICTED=yhats
LCLM=LowerCI /*CI for mean response, mu- narrower = less uncertainity */ 
UCLM=UpperCI
LCL=LowerPI /*PI for yhat - wider = more uncertainity */
UCL=UpperPI
;
run;
quit; 

*Predict the indiviudal response; 
*yhat= -7.09 + 1.95*sepal_length

Predict mean response; 
*mu = -7.09 + 1.95*sepal_length; 

*Use the first equation to predict petal_length when sepal length is 
7.1 8.0 6.5 and 7.6; 

DATA s3a3.new_sepal; 
INPUT sepal_length; *x variable; 
DATALINES; *input data; 
7.1 
8.0
6.5
7.6
;

*Combine this test data with original iris data; 
data s3a3.new_iris;
set s3a3.new_sepal s3a3.iris; 
run; 

PROC PRINT data=s3a3.new_iris (keep=petal_length sepal_length);
run; 

*See the blanks? We want to predict petal_length given sepal_length; 

*Predicting time...; 
PROC REG data=s3a3.new_iris (keep=petal_length sepal_length) plots=none; 
model petal_length = sepal_length;
OUTPUT OUT= s3a3.new_irispred (where=(petal_length=.))
Predicted=yhatPetalLength
LCLM=LowerCI
UCLM=UpperCI
LCL=LowerPI
UCL=UpperPI;
run;
quit; 

*View our predictions; 
PROC PRINT data=s3a3.new_irispred;
run; 

*Transform data and input new columns with DATA; 
data s3a3.new_iris1;
set s3a3.iris; *applying transformation to this dataset; 
logy= log(petal_length); *transform and add new column; 
run; 

*Some extra stuff, matrix algebra; 
PROC IML;
A=1; 
B={1 2 3}; *row vector; 
C={100,200}; *column vector; 
D={1 2, 3 4, 5 .}; *3 x 2 matrix; 
print A B C D; 
run; 

*Some manipulation;
PROC IML; 
D={1 2, 3 4, 5 6};
D32 = D[3,2];
Dsub=D[2:3,1:2]; 
PRINT D D32 Dsub;
run;

*Addition/Multiplication/Inverse/Transpose/etc;
PROC IML; 
A={1 3, 2 5};
B={-3 2, 1 2};
add = A + B; 
multi= A * B; 
multi_element= A # B; 
Atrans= t(A);
Ainv=inv(A);
PRINT A B add multi multi_element Atrans Ainv;
run; 

*View iris data in matrix form; 
PROC IML;
use S3a3.iris;
read all var {petal_length} into x;
read all var {sepal_length} into y; 
print x y;
run; 






















































































































 












