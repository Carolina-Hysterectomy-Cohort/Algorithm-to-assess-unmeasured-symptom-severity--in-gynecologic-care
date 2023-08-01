libname in /*filepath to where severity data is save*/;



proc formats cntlin=in.redcapformats; run;

data one;
set in.Severity_1c;
/*BILLING CODES - FROM REDCAP*/
/**/
/*DX: code at surgery*/
/*C_DX_BULK - Bulk code at surgery (CDWH)*/
/**/
/*DX: code prior to surgery*/
/*C_DX_BULK_PRIOR - Bulk code in year prior (CDWH)*/
/**/
/**/
/*SYMPTOMS - PATIENT REPORTED - REDCAP*/
/**/
/*SYMP: Urinary incontinence*/
/*R_GYNSYMP_NOTE_URINARY - Urinary symptoms: frequency, retention, or incontinence*/
/**/
/*SYMP: Constipation*/
/*R_GYNSYMP_NOTE_CONSTIPATION - Constipation*/
/**/
/*SYMP: Bloating */
/*R_GYNSYMP_NOTE_BLOAT*/
/**/
/*SYMP: Pelvic pressure*/
/*R_GYNSYMP_NOTE_PELVPRESSURE*/
/**/
/*SYMP: Weight gain*/
/*R_GYNSYMP_NOTE_WEIGHTGAIN*/
/**/
/*SYMP: Bulk NOS*/
/*ASK SHARON - SYMP: Bulk NOS, in redcap*/
/*R_GYNDX_NOTE_BULK*/
/**/
/**/
/*MD: Bulk as surgery indication - redcap */
/*R_PREOPDX_BULK*/
/**/
/**/
merge=1;
run;


/*defining above or below 75th percentile*/
proc univariate data=one noprint;
   var R_OPNT_PATH_UTWEIGHT;
   output out=percentiles pctlpts=50 75 pctlpre=P;
run;
data pct;
set percentiles;
merge=1;
run;

data two;
merge one pct;
by merge;
if R_OPNT_PATH_UTWEIGHT>P75 then high_utweight=1;
	else if R_OPNT_PATH_UTWEIGHT>.z then high_utweight=0;
label high_utweight="Uterine Weight At or Above 75th Percentile";
if R_OPNT_PATH_UTWEIGHT>P75 then high_utweight_c3=3;
	else if R_OPNT_PATH_UTWEIGHT>P50 then high_utweight_c3=2;
	else if R_OPNT_PATH_UTWEIGHT>.z then high_utweight_c3=1;
label high_utweight_c3="Uterine Weight Category (1=<50th Percentile, 2=50-75th Percentile, 3=At or Above 75th Percentile";
/*removing those with missing uterine weight*/
if R_OPNT_PATH_UTWEIGHT<.z then delete;
run;

/*These two measures are removed from the score according notes from 2/28/2020 Meeting*/
/*				R_GYNSYMP_NOTE_URINARY	*/
/*				R_GYNSYMP_NOTE_CONSTIPATION*/
/*				R_GYNSYMP_NOTE_WEIGHTGAIN	*/
/*These variables remain*/
/**/
/*DX: code at surgery*/
/*				C_DX_BULK					*/
/*SYMP: Bloating */
/*				R_GYNSYMP_NOTE_BLOAT	*/
/*SYMP: Pelvic pressure*/
/*				R_GYNSYMP_NOTE_PELVPRESSURE*/
/*DX: code prior to surgery*/
/*				C_DX_BULK_PRIOR			*/
/*SYMP: Bulk NOS*/
/*				R_GYNDX_NOTE_BULK		*/
/*MD: Bulk as surgery indication - redcap */
/*				R_PREOPDX_BULK*/

proc format;
value weight 1="< 50th Percentile of Uterine Weight"
			 2="50-75th Percentile of Uterine Weight"
			 3=">=75th Percentile of Uterine Weight";
run;

/*%LET var = C_DX_BULK;*/
/*%LET label = Diagnosis Bulk;*/

%macro u_weight(var,label);
proc sort data=two; by &var.; run;
proc freq data=two noprint;
by &var.;                    				 /* X categories on BY statement */
tables high_utweight_c3 / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% by Uterine Weight Group by &label.";
proc sgplot data=FreqOut;
vbar &var. / response=Percent group=high_utweight_c3 groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="%";
label &var.="&label.";
format high_utweight_c3 weight.;
keylegend / title="Uterine Weight Category";
run;
%mend u_weight;

%u_weight(C_DX_BULK,						DX: code at surgery);
%u_weight(R_GYNSYMP_NOTE_BLOAT,				SYMP: Bloating);
%u_weight(R_GYNSYMP_NOTE_PELVPRESSURE,		SYMP: Pelvic pressure);
%u_weight(C_DX_BULK_PRIOR,					DX: code prior to surgery);
%u_weight(R_GYNDX_NOTE_BULK,				SYMP: Bulk NOS);
%u_weight(R_PREOPDX_BULK,					MD: Bulk as surgery indication);

/*Now I am interested in generating overlapping histograms*/
data histogram (keep = C_Pr_PAT_ID
/*				R_GYNSYMP_NOTE_URINARY	*/
				C_DX_BULK					
/*				R_GYNSYMP_NOTE_CONSTIPATION*/
				R_GYNSYMP_NOTE_BLOAT	
				R_GYNSYMP_NOTE_PELVPRESSURE
/*				R_GYNSYMP_NOTE_WEIGHTGAIN	*/
				C_DX_BULK_PRIOR			
				R_GYNDX_NOTE_BULK		
				R_PREOPDX_BULK
				R_OPNT_PATH_UTWEIGHT
				high_utweight
				high_utweight_c3
				bulk_score
				bulk_score_v2
				bulk_score_nw
				diff);
set two;
/*Creating score*/

/*1 POINT SCALES*/
/*SYMP: Bloating*/
if R_GYNSYMP_NOTE_BLOAT=1 then GYNSYMP_NOTE_BLOAT=1;
	else if R_GYNSYMP_NOTE_BLOAT=0 then GYNSYMP_NOTE_BLOAT=0;
/*SYMP: Pelvic pressure*/
if R_GYNSYMP_NOTE_PELVPRESSURE=1 then GYNSYMP_NOTE_PELVPRESSURE=1;
	else if R_GYNSYMP_NOTE_PELVPRESSURE=0 then GYNSYMP_NOTE_PELVPRESSURE=0;

/*2 POINT SCALES*/
/*DX: code at surgery*/
/*Creating indicator*/
if high_utweight_c3=2 then pct_50_75=1;	
	else if high_utweight_c3 IN(1,3) then pct_50_75=0;

/*3 POINT SCALES*/
/*SYMP: Bulk NOS*/
/*MD: Bulk indication*/
/*DX: prior to surgery*/

/*4 POINT SCALES*/
/*Uterine size > 75% */
bulk_score		=sum(GYNSYMP_NOTE_BLOAT,R_GYNSYMP_NOTE_PELVPRESSURE,
			  	 2*C_DX_BULK,
			  	 3*C_DX_BULK_PRIOR,3*R_GYNDX_NOTE_BULK,3*R_PREOPDX_BULK,
			  	 4*high_utweight);
/*Giving people with 50-75th percentiel of uterine weight 2 extra points*/
bulk_score_v2	=sum(GYNSYMP_NOTE_BLOAT,R_GYNSYMP_NOTE_PELVPRESSURE,pct_50_75,
			  	 2*C_DX_BULK,
			  	 3*C_DX_BULK_PRIOR,3*R_GYNDX_NOTE_BULK,3*R_PREOPDX_BULK,
			  	 4*high_utweight);
/*Removing uterine weight to explore distribution*/
bulk_score_nw	=sum(GYNSYMP_NOTE_BLOAT,R_GYNSYMP_NOTE_PELVPRESSURE,
			  	 2*C_DX_BULK,
			  	 3*C_DX_BULK_PRIOR,3*R_GYNDX_NOTE_BULK,3*R_PREOPDX_BULK);
/*Looking at differences*/
diff = bulk_score-bulk_score_nw;
run;

proc means data=histogram;
class diff;
var bulk_score_v2;
run;

title1 "Distribution of Bulk Score (Excluding Uterine Weight) For those with Uterine Weight > 75th Percentile";
proc gchart data=histogram;
where diff=4;
vbar bulk_score_nw / discrete;
label bulk_score_nw ="Bulk Score (Excluding Uterine Weight)";
run; quit;

proc freq data=histogram;
where diff=4;
tables bulk_score_nw / out=high_ut outcum;
run;

data high_ut_v2;
set high_ut;
CUM_AT_OR_ABOVE=1907-CUM_FREQ+COUNT;
PCT_ABOVE=100-CUM_PCT+PERCENT;
run;

proc print data=high_ut_v2; run;


proc freq data=histogram;
tables bulk_score / out=test outcum;
run; 

data test_v2;
set test;
CUM_AT_OR_ABOVE=1907-CUM_FREQ+COUNT;
PCT_ABOVE=100-CUM_PCT+PERCENT;
run;

proc print data=test_v2; run;




ods graphics off;
proc sort data=histogram; by bulk_score; run;
title 'Box Plot for Uterine Weight by Bulk Score (Including Uterine Weight)';
proc boxplot data=histogram;
   plot R_OPNT_PATH_UTWEIGHT*bulk_score;
   insetgroup n med min max /
      header = 'Distribution by Bulk Score';
label bulk_score="Bulk Score (Including Uterine Weight)";
run;

ods graphics off;
proc sort data=histogram; by bulk_score_v2; run;
title 'Box Plot for Uterine Weight by Bulk Score (Including 2 Points for those with 50th-75th Percentile Uterine Weight)';
proc boxplot data=histogram;
   plot R_OPNT_PATH_UTWEIGHT*bulk_score_v2;
   insetgroup n med min max /
      header = 'Distribution by Bulk Score';
label bulk_score_v2="Bulk Score (Including 2 Points for those with 50th-75th Percentile Uterine Weight)";
run;

proc freq data=histogram;
tables bulk_score*bulk_score_v2;
run;

