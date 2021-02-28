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


proc univariate data=modlin.data;
	ods select Moments;
	var Sale_Price;
	title "Moments: Sale Price";
run;

proc sgplot data=modlin.data;
	vbox Sale_Price;
	title "Boxplot: Sale Price";
run;

proc univariate data=modlin.data;
	ods select Moments;
	var Lot_Size;
	title "Moments: Lot Size";
run;

proc sgplot data=modlin.data;
	vbox Lot_Size;
	title "Boxplot: Lot Size";
run;

proc univariate data=modlin.data;
	ods select Moments;
	var Age;
	title "Moments: Age";
run;

proc sgplot data=modlin.data;
	vbox Age;
	title "Boxplot: Age";
run;


proc univariate data=modlin.data;
ods select Moments;
var Full_Baths;
title "Moments: Full Baths";
run;

proc sgplot data=modlin.data;
vbox Full_Baths;
title "Boxplot: Full Baths";
run;

proc univariate data=modlin.data;
	ods select Moments;
	var Half_Baths;
	title "Moments: Half Baths";
run;

proc sgplot data=modlin.data;
	vbox Half_Baths;
	title "Boxplot: Half Baths";
run;

proc univariate data=modlin.data;
	ods select Moments;
	var Bedrooms;
	title "Moments: Bedrooms";
run;

proc sgplot data=modlin.data;
	vbox Bedrooms;
	title "Boxplot: Bedrooms";
run;

proc univariate data=modlin.data;
	ods select Moments;
	var Fireplaces;
	title "Moments: Fireplaces";
run;

proc sgplot data=modlin.data;
	vbox Fireplaces;
	title "Boxplot: Fireplaces";
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

/* Compute the log of Sales Price and Living Area */

data modlin.data;set modlin.data;
	log_Sale_Price=log(Sale_Price);
	log_Living_Area=log(Living_Area);
run;


/*========== Basic model ==========*/


*/*---------------------------------------*
|     MULTICOLLINEARITY ANALYSIS         |
*---------------------------------------*;

/*========== Multicollinearity between quantitative variables =============*/

proc reg data=modlin.data corr plots=none;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces / vif;
	title "Basic regression model with autocorrelation matrix and vif";
run;


/*========== Relation between quantitative and qualitative variables =============*/
/* Two-way anova (with GML because we have unbalanced data)focus on type III SS , better for unbalanced data */



proc glm data = modlin.data plots=none;
	class Waterfront Fuel_Type Central_Air Condition;
	model Age = Waterfront Fuel_Type Central_Air Condition Waterfront*Fuel_Type*Central_Air*Condition;
	title "Anova Age";
run;

proc glm data = modlin.data plots=none;
	class Waterfront Fuel_Type Central_Air Condition;
	model Living_Area = Waterfront Fuel_Type Central_Air Condition Waterfront*Fuel_Type*Central_Air*Condition;
	title "Anova Living Area";
run;

proc glm data = modlin.data plots=none;
	class Waterfront Fuel_Type Central_Air Condition;
	model Lot_Size = Waterfront Fuel_Type Central_Air Condition Waterfront*Fuel_Type*Central_Air*Condition;
	title "Anova Lot Size";
run;


proc glm data = modlin.data plots=none;
	class Waterfront Fuel_Type Central_Air Condition;
	model Full_Baths = Waterfront Fuel_Type Central_Air Condition Waterfront*Fuel_Type*Central_Air*Condition;
	title "Anova Full Baths";
run;

proc glm data = modlin.data plots=none;
	class Waterfront Fuel_Type Central_Air Condition;
	model Half_Baths = Waterfront Fuel_Type Central_Air Condition Waterfront*Fuel_Type*Central_Air*Condition;
	title "Anova Half Baths";
run;

proc glm data = modlin.data plots=none;
class Waterfront Fuel_Type Central_Air Condition;
model Bedrooms = Waterfront Fuel_Type Central_Air Condition Waterfront*Fuel_Type*Central_Air*Condition;
title "Anova Bedrooms";
run;

proc glm data = modlin.data plots=none;
	class Waterfront Fuel_Type Central_Air Condition;
	model Fireplaces = Waterfront Fuel_Type Central_Air Condition Waterfront*Fuel_Type*Central_Air*Condition;
	title "Anova Fireplaces";
run;


/*========== Relation between the two qualitative variables =============*/
proc freq data=modlin.data order=data;
	tables Waterfront*Fuel_Type  / FISHER;
run;

proc freq data=modlin.data order=data;
	tables Waterfront*Central_Air / FISHER;
run;

proc freq data=modlin.data order=data;
	tables Waterfront*Condition  / FISHER;
run;

proc freq data=modlin.data order=data;
	tables Fuel_Type*Central_Air  / FISHER;
run;

proc freq data=modlin.data order=data;
	tables Fuel_Type*Condition  / FISHER;
run;

proc freq data=modlin.data order=data;
	tables Central_Air*Condition  / FISHER;
run;

*---------------------------------------*
|              OUTLIERS                 |
*---------------------------------------*;
;/*========== Outliers wrt X (nxp) ==========*/
/*        - p = 14 - n = 1080- leverage = 2*p/n = 0.025 */

proc reg data=modlin.data;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
Fuel_Type_Wood Fuel_Type_Electric  Condition_Excelent log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/noprint;
	output out=outliers h=lev;
	title "Detect outliers by calculating the leverage";
run;
	
proc print data=outliers;
	var Lot_Size log_Sale_Price lev;
	where lev > 0.025;
run;
	
	
/*========== Outliers wrt Y ==========*/



proc reg data=modlin.data;	
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
Fuel_Type_Wood Fuel_Type_Electric  Condition_Excelent log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/noprint;
		output out=outliers rstudent=stud;
		title "Detect outliers for Y at level alpha = 0.05";
run;
		
proc print data=outliers;		
	var Lot_Size log_Sale_Price stud;
	where abs(stud) > tinv(0.975, 1080-14-1);/* t_{1-alpha/2;n-p-1}, alpha=0.05 */
run;
		

/*========== Influential observations ==========*/
/* According to DFFITS criterion: |DFFITS| = 2*sqrt(p/n) = 0.228 - p = 14 - n = 1080 */

 
proc reg data=modlin.data plots(only)=dffits;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric  Condition_Excelent log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/noprint;
	title "Detect influancal observations according to DFFITS criterion";
run;

/* According to DFFITS criterion: |DFFITS| = 2*sqrt(p/n) = 0.228 */
proc reg data=modlin.data plots(only)=dffits;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric  Condition_Excelent log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/noprint;
	output out=influential dffits=df;
	title "Detect influancal observations according to DFFITS criterion";
run;
	

proc print data=influential;
	var Lot_Size log_Sale_Price df;
	where df > 0.228 or df < -0.228;
	run;

/*========== Cook's distance ==========*/

proc reg data=modlin.data;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
Fuel_Type_Wood Fuel_Type_Electric  Condition_Excelent log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/noprint;
	output out=outliers cookd=cd;
	title "Detect outliers according to Cook's distance";
	run;


proc reg data=modlin.data;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
Fuel_Type_Wood Fuel_Type_Electric  Condition_Excelent log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/noprint;
	title "Detect outliers according to Cook's distance";	
	run;

proc print data=outliers;
	var Lot_Size log_Sale_Price cd;
	where cd > finv(0.95, 14, 1080-14);/* F_{1-alpha,p,n-p}, alpha = 0.05 */
run;
	
	
*----------------------------------------------------*
|               RESIDUALS ANALYSIS                   |
|   Heteroskedasticity,autocorrelation & normality   |
*----------------------------------------------------*;
proc reg data=modlin.data plots=residualbypredicted ;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces;

	title "Residuals analysis";
run;

/* Heteroskedasticity =
		- check constant variance on residual plot wrt each Xi and residual plot wrt Y
		- SPEC test : null hypothesis -->
				°the errors are homoscedastic°the errors are independent of the regressors
				°the model is correctly specified.
		- comparison  with robust estimator (White's errors)
		- Goldfeld-Quandt test */

/* Autocorrelation =
	- check for clusters in residual plots- could not find a relevant test on SAS for "non-time series" data
	- only way to have autocorrelation on "non-time series" data is to havea wrong functional form --> check SPEC test (specification test) */
	
/* Normality of errors =- check for normal distribution in residual plots- qq-plots- did not find Jarque-Bera test in SAS for "non-time series" data */


/*---------------------------------------------------------------------------------------------*/
/*========== Heteroskedasticity ==========*/

/* Spec, white test */
proc reg data=modlin.data plots=none;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces / spec white;
	title "Residuals analysis - Heteroskedasticity";
run;
	
/* Goldfeld-Quandt test */

proc reg data=modlin.data outest=modlin.data2 tableout;
	A: model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces /sse noprint;
	where (Condition_Bad=1 or Condition_Medium=1 or Condition_Good=1);
run;
	
proc print data=modlin.data2;
	var _edf_ _sse_;
run;
	
proc reg data=modlin.data outest=modlin.data2 tableout;
	B: model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces /sse noprint;
	where (Condition_Bad=0 or Condition_Medium=0 or Condition_Good=0);
run;
	
	
proc print data=modlin.data2;
	var _edf_ _sse_;
	run;
			
			
/*========== Normality ==========*/
proc reg data=modlin.data plots(only)=(qq residualhistogram);
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces;
	title "Normality of the errors - qq residualhistogram";
run;


*---------------------------------------*
|           MODEL SELECTION             |
*---------------------------------------*;

/* Model selection according to 3 types of strategies:
	TYPE I :- Mallow criterion
		- Adjusted Rsquared
	TYPE II:- Forward selection
		- Backward selection
		- Stepwise selection (forward-backward)
	TYPE III:- LASSO */
/*------------------------------------------------------------------------*/

/*========== Type I : Mallow criterion ==========*/

proc reg data=modlin.data plots=none;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/ selection=cp best=16;
	title "Selection variables by Mallows statistic";
run;


/*========== Type I: adjusted Rsquared ==========*/	
	
proc reg data=modlin.data plots=none;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/ selection=adjrsq best=16;
	title "Selection variables by adjusted R-sq";
run;

/*========== Type II: forward selection ==========*/
proc reg data=modlin.data outest=stepwise tableout plots=none;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/ selection=forward noprint;
	title "Selection variables by forward selection";
run;

proc print data=stepwise;
run;

/*========== Type II: backward selection ==========*/

proc reg data=modlin.data outest=stepwise tableout plots=none;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/ selection=backward noprint;
	title "Selection variables by backward selection";
run;

proc print data=stepwise;
run;

/*========== Type II: stepwise selection ==========*/

proc reg data=modlin.data outest=stepwise tableout plots=none;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/ selection=stepwise noprint;
	title "Selection variables by stepwise selection";
run;

proc print data=stepwise;
run;


/*========== Type III: LASSO ==========*/
proc glmselect data=modlin.data plots(stepaxis=normb)=all seed=123;
	model log_Sale_Price=Lot_Size Waterfront_Yes Age Central_Air_Yes Fuel_Type_Gas Fuel_Type_Propane 
	Fuel_Type_Wood Fuel_Type_Electric Condition_Bad Condition_Medium Condition_Good Condition_Excelent 
	log_Living_Area Full_Baths Half_Baths Bedrooms Fireplaces/ selection=lasso(stop=none choose=cvex)
	cvmethod=random(5);
	title "Selection variables by LASSO";
run;
	

