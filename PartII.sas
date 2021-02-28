/*========== Import the dataset ==========*/

libname modlin "/folders/myfolders/LSTAT2120/Project";
data modlin.data;
%web_drop_table(modlin.data);
filename reffile'/folders/myfolders/LSTAT2120/Project/real_estate_org.xlsx';

proc import datafile=reffile
	dbms=xlsx
	out=modlin.data;
	getnames=yes;
	run;

%web_open_table(modlin.data);

data modlin.data;set modlin.data;
	log_Sale_Price=log(Sale_Price);
	log_Living_Area=log(Living_Area);
run;

/* Change the categorical variables into dummies variables */

data modlin.data;
	set modlin.data;

	/* Reference="Waterfront=No" */
	if Waterfront="Yes" then Waterfront_Yes=1; else Waterfront_Yes=0;
	
	/* Reference="Central_Air=No" */
	if Central_Air="Yes" then Central_Air_Yes=1; else Central_Air_Yes=0;
	
	/* Reference="Fuel_Type=Oil" */
	if Fuel_Type="Gas" then Fuel_Type_Gas=1; else Fuel_Type_Gas=0;
	if Fuel_Type="Propane" then Fuel_Type_Propane=1; else Fuel_Type_Propane=0;
	if Fuel_Type="Wood" then Fuel_Type_Wood=1; else Fuel_Type_Wood=0;
	if Fuel_Type="Electric" then Fuel_Type_Electric=1; else Fuel_Type_Electric=0;
	
	/* Reference="Condition=1" */
	if Condition=2 then Condition_Bad=1; else Condition_Bad=0;
	if Condition=3 then Condition_Medium=1; else Condition_Medium=0;
	if Condition=4 then Condition_Good=1; else Condition_Good=0;
	if Condition=5 then Condition_Excelent=1; else Condition_Excelent=0;

run;


proc reg data=modlin.data plots=none;
	model log_Sale_Price= Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Propane Fuel_Type_Electric Condition_Excelent 
	log_Living_Area Full_Baths Bedrooms	Fireplaces;
	title "chosen model - Stepwise  result";
run;


*---------------------------------------*
|           INTERACTION TERMS           |
*---------------------------------------*;


/* Example with Sales Price wrt Lot_Size by Central_Air */
proc sgplot data=modlin.data;	
	reg y=log_Sale_Price x=Lot_Size / group= Central_Air  lineattrs=(thickness=2);
	title "Log : Sale Price wrt Lot Size by Central Air";
run;


/* Brute force search to find significant interaction terms */
/* All possible interaction terms between selected qualitative 
(Waterfront_Yes, Central_Air_Yes, Fuel_Type_Propane, Fuel_Type_Electric, Condition_Excelent) 
and selected quantitative variables 
(Lot_Size, Age, log_Living_Area, Full_Baths, Bedrooms, Fireplaces)*/
data modlin.data;
	set modlin.data;
	/*First order */
	
	CA_LS = Central_Air_Yes*Lot_Size;
	
	CA_Ag = Central_Air_Yes*Age;
	
	CA_lLA= Central_Air_Yes*log_Living_Area;
	
	CA_FB = Central_Air_Yes*Full_Baths;
	
	CA_Fp = Central_Air_Yes*Fireplaces;
	
run;


/* Test each model for significance of each interaction term */
proc reg plots=none ;

model log_Sale_Price= Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Propane Fuel_Type_Electric Condition_Excelent 
	log_Living_Area Full_Baths Bedrooms	Fireplaces CA_LS ;


model log_Sale_Price= Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Propane Fuel_Type_Electric Condition_Excelent 
	log_Living_Area Full_Baths Bedrooms	Fireplaces CA_Ag;

model log_Sale_Price= Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Propane Fuel_Type_Electric Condition_Excelent 
	log_Living_Area Full_Baths Bedrooms	Fireplaces CA_lLA ;

model log_Sale_Price= Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Propane Fuel_Type_Electric Condition_Excelent 
	log_Living_Area Full_Baths Bedrooms	Fireplaces CA_FB ;

model log_Sale_Price= Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Propane Fuel_Type_Electric Condition_Excelent 
	log_Living_Area Full_Baths Bedrooms	Fireplaces CA_Fp;



run;

*---------------------------------------*
|            CHOSEN MODEL               |
*---------------------------------------*;
/* Final model + double check of regression assumptions */

proc reg plots=residualbypredicted;
	model log_Sale_Price= Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Propane Fuel_Type_Electric Condition_Excelent 
	log_Living_Area Full_Baths Bedrooms	Fireplaces CA_LS CA_Ag CA_Fp/spec white vif;
	title "chosen model - final results";
run;

*---------------------------------------*
|   Linear combination of coefficients     |
*---------------------------------------*;
;/*========== Sample means ==========*/

proc means data=modlin.data;
run;

/*========== Hypothesis test ==========*/

proc reg plots=none;
		model log_Sale_Price= Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Propane Fuel_Type_Electric Condition_Excelent 
	log_Living_Area Full_Baths Bedrooms	Fireplaces CA_LS CA_Ag CA_lLA CA_FB CA_Fp;
		test Central_Air_Yes + 0.2473704*CA_LS + 5.4500000*CA_Ag + 0.3361111*CA_Fp=0;

		title "test for marginal effect of Central_Air_Yes";
run;


