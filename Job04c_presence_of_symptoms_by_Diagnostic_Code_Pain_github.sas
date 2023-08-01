libname in /*filepath to data*/;

proc formats cntlin=in.redcapformats; run;

data one;
set in.Severity_1c;
	/*	R_GYNSYMP_NOTE_PELVPAIN*/
/*SYMP – Painful periods*/
	/*	R_GYNSYMP_NOTE_PERIODPAIN*/
/*MEDS - Opoid*/
	/*	c_med_opiod_prior*/
/*MEDS - NSAID*/
	/*	c_med_nsaid_prior*/
/*MD -  Pain as indication for surgery*/
/*		R_PLAN_CHRONICPELVPAIN*/
/*MD – Painful periods as indication*/
	/*updated 02.13.2020*/
	/*  R_PREOPDX_DYSMENORRHEA */
/*MEDS – Tylenol */
	/*  C_Med_acetaminophen_prior*/
/*SYMP – Painful Intercourse*/
	/*  R_GYNSYMP_NOTE_INTERCOURSEPAIN*/
/*DX – ER visit*/
	/*C_ed_visits_pain_prior*/
	IF C_ed_visits_pain_prior=0 THEN ED_pain_c3=0;
		ELSE IF C_ed_visits_pain_prior=1 THEN ED_pain_c3=1;
		ELSE IF C_ed_visits_pain_prior>1 THEN ED_pain_c3=2;
	IF C_ed_visits_pain_prior=0 THEN ED_pain_c2=0;
		ELSE IF C_ed_visits_pain_prior>=1 THEN ED_pain_c2=1;
/*SYMP – Missing work*/
	/* R_GYNSYMP_NOTE_MISSDAYS*/
/*MEDS – Muscle Relaxant*/
	/* C_Med_MUSCLE_RELAXANTS*/
/*MEDS - Other*/
	/* C_Med_other_prior*/
/*MD – Painful intercourse as indication */
	/**/
	/* PREOPDX_DSYPAREUNIA 
	/**/
/*MD – Other pain as indication*/
	/* R_PREOPDX_PAINOTHER*/
/**/
/**/
/*USING THE DIAGNOSIS CODE*/
/**/
/**/
/*DX – Pain prior to surgery*/
	/*	C_DX_PAIN_PRIOR*/
/*DX – Pain at surgery*/
	/*	C_DX_PAIN*/
if C_DX_PAIN=1 or C_DX_PAIN_PRIOR=1 then PAIN_CODE_EVER=1;
	else PAIN_CODE_EVER=0;
run;

proc freq data=one;
tables PAIN_CODE_EVER*C_DX_PAIN*C_DX_PAIN_PRIOR 	C_DX_PAIN 	PAIN_CODE_EVER/	 list;
run;

data two;
set one;
pain_score=sum(R_GYNSYMP_NOTE_PELVPAIN,R_GYNSYMP_NOTE_PERIODPAIN,R_GYNSYMP_NOTE_INTERCOURSEPAIN,C_Med_acetaminophen_prior,
				2*c_med_nsaid_prior,2*R_PLAN_CHRONICPELVPAIN,2*R_PREOPDX_DYSMENORRHEA,
				3*C_DX_PAIN_PRIOR,3*C_DX_PAIN,3*C_Med_other_prior,
				4*c_med_opiod_prior,4*ED_pain_c2,4*C_Med_MUSCLE_RELAXANTS);
run;

proc means data=two;
var pain_score; run;
run;

proc means data=two min p1 q1 median q3 p99 max;
class C_DX_PAIN;
var pain_score;
run;

proc npar1way data=two wilcoxon;
class C_DX_PAIN;
var pain_score;
run;

proc freq data=two;
where pain_score>=10;
tables C_DX_PAIN;
run;
 
proc means data=two n min p1 q1 median q3 p99 max;
where C_DX_PAIN=0 and pain_score>=10;
var pain_score;
run;

proc freq data=two;
where pain_score=15;
tables 
R_GYNSYMP_NOTE_PELVPAIN*R_GYNSYMP_NOTE_PERIODPAIN*R_GYNSYMP_NOTE_INTERCOURSEPAIN*C_Med_acetaminophen_prior*
				c_med_nsaid_prior*R_PREOPDX_DYSMENORRHEA*R_PLAN_CHRONICPELVPAIN*
				C_DX_PAIN_PRIOR*C_DX_PAIN*C_Med_other_prior*
				c_med_opiod_prior*ED_pain_c2*C_Med_MUSCLE_RELAXANTS / list;
run;


/*Output csv file for Figure*/
data figure (keep = pain_score C_DX_PAIN);
set two;
run;

PROC EXPORT DATA= WORK.figure
            OUTFILE= /*filepath for output*/
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;



%macro overall_pain(i,var);
proc freq data=two;
tables PAIN_CODE_EVER*&var. / out=table outpct;
run;
data table2;
set table;
if &var.=1;
ROW_PERCENT=PCT_ROW/100;
run;
proc transpose data=table2 out=table3 prefix=CODE_OVERALL_; ID PAIN_CODE_EVER; var ROW_PERCENT; run;
data out&i. (keep = order var CODE_OVERALL_0 CODE_OVERALL_1);
set table3;
length var $32;
format CODE_OVERALL_0 CODE_OVERALL_1 PERCENT.;
var="&var.";
order=&i.;
run;
proc print data=out&i.; run;
%mend overall_pain;

%overall_pain(1,  R_GYNSYMP_NOTE_PELVPAIN);
%overall_pain(2,  R_GYNSYMP_NOTE_PERIODPAIN);
%overall_pain(3,  R_GYNSYMP_NOTE_INTERCOURSEPAIN);
%overall_pain(4,  C_Med_acetaminophen_prior);
%overall_pain(5,  c_med_nsaid_prior);
%overall_pain(6,  R_PLAN_CHRONICPELVPAIN);
%overall_pain(7,  R_PREOPDX_DYSMENORRHEA);
%overall_pain(8,  C_Med_other_prior);
%overall_pain(9,  c_med_opiod_prior);
%overall_pain(10, ED_pain_c2);
%overall_pain(11, C_Med_MUSCLE_RELAXANTS);

data overall_pain;
set out1-out11;
run;

%macro atsurgery_pain(i,var);
proc freq data=two;
tables C_DX_PAIN*&var. / out=table outpct;
run;
data table2;
set table;
if &var.=1;
ROW_PERCENT=PCT_ROW/100;
run;
proc transpose data=table2 out=table3 prefix=CODE_; ID C_DX_PAIN; var ROW_PERCENT; run;
data out&i. (keep = order var CODE_0 CODE_1);
set table3;
length var $32;
format CODE_0 CODE_1 PERCENT.;
var="&var.";
order=&i.;
run;
%mend atsurgery_pain;

%atsurgery_pain(1,  R_GYNSYMP_NOTE_PELVPAIN);
%atsurgery_pain(2,  R_GYNSYMP_NOTE_PERIODPAIN);
%atsurgery_pain(3,  R_GYNSYMP_NOTE_INTERCOURSEPAIN);
%atsurgery_pain(4,  C_Med_acetaminophen_prior);
%atsurgery_pain(5,  c_med_nsaid_prior);
%atsurgery_pain(6,  R_PLAN_CHRONICPELVPAIN);
%atsurgery_pain(7,  R_PREOPDX_DYSMENORRHEA);
%atsurgery_pain(8,  C_Med_other_prior);
%atsurgery_pain(9,  c_med_opiod_prior);
%atsurgery_pain(10, ED_pain_c2);
%atsurgery_pain(11, C_Med_MUSCLE_RELAXANTS);

data at_surgery;
set out1-out11;
run;

data pain;
merge overall_pain at_surgery;
by order;
if CODE_1=. 			then CODE_1=0;
if CODE_0=. 			then CODE_0=0;
if CODE_OVERALL_1=.		then CODE_OVERALL_1=0;
if CODE_OVERALL_0=. 	then CODE_OVERALL_0=0;
run;

proc print data=pain;
var var CODE_OVERALL_1 CODE_OVERALL_0 CODE_1 CODE_0;
run;
