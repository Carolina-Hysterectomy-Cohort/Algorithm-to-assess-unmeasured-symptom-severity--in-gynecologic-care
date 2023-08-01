libname in /*filepath to severity data*/;

proc formats cntlin=in.redcapformats; run;

proc format;
value race 	1="Non-Hispanic White"
			2="Non-Hispanic Black"
			3="Non-Hispanic Asian"
			4="Non-Hispanic American Indian/Alaska Native"
			5="Hispanic"
			6="Other"
			7="Unknown/Refused"
			.="Mising";
value ins   1="Tricare Only"
			2="Self-Pay Only"
			3="Private Insurance Only"
			4="Medicare Only"
			5="Medicaid Only"
			6="Agency Only";
run;

proc freq data=in.severity_v1b;
tables 	
	Medicaid*Medicare*Private*SelfPay*Tricare*Agency / list;
run;

proc freq data=one;
tables 	
	ins*Medicaid*Medicare*Private*SelfPay*Tricare*Agency / list;
run;

data one;
set in.severity_2 (keep = 
/*RACE/ETHNICITY*/
	Race_Hispanic RACE_ASIAN Race_Native race_black race_white race_other race_unknown race_refused
/*Insurance Status*/
	Agency /*(prison)*/
	Medicaid
	Medicare
	Private
	SelfPay
	Tricare
/*Hospital Type*/
	Hospital_Category
/*Year of Surgery*/
	R_DO_HYST
/*Age in Years at Hysterctomy*/
	R_AGE_HYST
/*Uterine Size*/
	/*There are missing values*/
	R_OPNT_PATH_UTWEIGHT
	);
/*Get year from Year of Surgery*/
R_YR_HYST=year(R_DO_HYST);
/*Creating Race Variable*/
/*Unknown/Refused*/
if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=0 and race_black=0 and race_white=0 and race_other=0 and race_unknown=0 and race_refused=1 then race_eth=7;
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=0 and race_black=0 and race_white=0 and race_other=0 and race_unknown=1 and race_refused=0 then race_eth=7;
/*Other*/
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=0 and race_black=0 and race_white=0 and race_other=1 and race_unknown=0 and race_refused=0 then race_eth=6;
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=0 and race_black=0 and race_white=0 and race_other=1 and race_unknown=1 and race_refused=0 then race_eth=6;
/*Non-Hispanic White*/
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=0 and race_black=0 and race_white=1 and race_other=0 and race_unknown=0 and race_refused=0 then race_eth=1;
/*Non-Hispanic Black*/
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=0 and race_black=1 and race_white=0 and race_other=0 and race_unknown=0 and race_refused=0 then race_eth=2;
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=0 and race_black=1 and race_white=1 and race_other=0 and race_unknown=0 and race_refused=0 then race_eth=2;
/*Non-Hispanic American Indian/Alaska Native*/
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=1 and race_black=0 and race_white=0 and race_other=0 and race_unknown=0 and race_refused=0 then race_eth=4;
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=1 and race_black=0 and race_white=1 and race_other=0 and race_unknown=0 and race_refused=0 then race_eth=4;
	else if Race_Hispanic=0 and RACE_ASIAN=0 and Race_Native=1 and race_black=1 and race_white=0 and race_other=0 and race_unknown=0 and race_refused=0 then race_eth=4;
/*Non-Hispanic Asian*/
	else if Race_Hispanic=0 and RACE_ASIAN=1 and Race_Native=0 and race_black=0 and race_white=0 and race_other=0 and race_unknown=0 and race_refused=0 then race_eth=3;
	else if Race_Hispanic=0 and RACE_ASIAN=1 and Race_Native=0 and race_black=0 and race_white=1 and race_other=0 and race_unknown=0 and race_refused=0 then race_eth=3;
/*Hispanic*/
	else if Race_Hispanic=1 then race_eth=5;
/*Insurance Status*/
if Agency=0 and Medicaid=0 and Medicare=0 and Private=0 and SelfPay=0 and Tricare=1 then ins=1;
	else if Agency=0 and Medicaid=0 and Medicare=0 and Private=0 and SelfPay=1 and Tricare=0 then ins=2;
	else if Agency=0 and Medicaid=0 and Medicare=0 and Private=1 and SelfPay=0 and Tricare=0 then ins=3;
	else if Agency=0 and Medicaid=0 and Medicare=0 and Private=1 and SelfPay=1 and Tricare=0 then ins=3;
	else if Agency=0 and Medicaid=0 and Medicare=1 and Private=0 and SelfPay=0 and Tricare=0 then ins=4;
	else if Agency=0 and Medicaid=1 and Medicare=0 and Private=0 and SelfPay=0 and Tricare=0 then ins=5;
	else if Agency=0 and Medicaid=1 and Medicare=0 and Private=0 and SelfPay=1 and Tricare=0 then ins=5;
	else if Agency=1 and Medicaid=0 and Medicare=0 and Private=0 and SelfPay=0 and Tricare=0 then ins=6;
format race_eth race. ins ins.;
run;

proc freq data=one;
tables race_eth ins;
run;


/*%LET var = race_eth;*/
/*%LET i = 1;*/

%macro freq(i,var);
proc freq data=one; tables &var. / missing out=freq; run;
data freq2 (keep = var value); set freq; length var value $32; var=&var.; value = strip(COUNT)||" ("||strip(round(PERCENT,1))||"%)"; run;
proc sort data=freq2 out=out&i.; by var; run;
%mend freq;

%freq(1,race_eth);
%freq(2,ins);
%freq(3,Hospital_category);
%freq(4,R_YR_HYST);


%macro mean(i,var);
proc means data=one; var &var.; output out=mean mean=m min=min max=max ; run;
data mean2 (keep = var value); set mean; length var value $32; var="&var."; value= strip(round(m,1))||" ("||strip(round(min,1))||","||strip(round(max,1))||")";
proc sort data=mean2 out=out&i.; by var; run;
%mend mean(i,var);

%mean(5,R_AGE_HYST);
%mean(6,R_OPNT_PATH_UTWEIGHT);

data table;
set out1-out6;
run;

proc freq data=one;
tables race_eth ins Hospital_Category R_YR_HYST / missing; run;

proc means data=one;
var R_AGE_HYST R_OPNT_PATH_UTWEIGHT;
run;

proc print data=table noobs; 
run;
