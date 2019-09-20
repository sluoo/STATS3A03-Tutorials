*Create a library;

*Library is nickname that you give which directs you
*to a specfic folder on your computer; 


libname s3a3 "/folders/myfolders ";

run; 



*Always run this command when starting a new session; 



*Input data manually; 

DATA s3a3.mydata; 

input weight height; 

datalines; *where you input values; 

272 180

123 723

183 828
;

run; 



*Import data; 

PROC Import 

datafile= "/folders/myfolders/faithful.csv"
 
out=s3a3.faithful_data

dbsm=csv

replace; *overwrites the original name of dataset; 

run; 



*Print or view tables or graph; 

PROC PRINT data=s3a3.faithful_data;

run; 




*View first 10 obs; 

PROC PRINT data=s3a3.faithful_data(obs=10);

run;



*summary statistics; 

PROC MEANS data=s3a3.faithful_data; 

VAR eruptions; 

run; 



*Using BY command. What if you want the eruption averages for 
each waiting time?; 



*First sort your data; 

PROC SORT 
data=s3a3.faithful_data

OUT= s3a3.faithful_sorted; 

BY Waiting; 

run; 



PROC PRINT data=s3a3.faithful_sorted;

run; 



PROC MEANS data=s3a3.faithful_sorted N Mean Median Max Min Q1; 

BY Waiting; *use by when you are sorting or organizing data; 

VAR eruptions; *use var when calculating summary stats; 

run; 































 


























































