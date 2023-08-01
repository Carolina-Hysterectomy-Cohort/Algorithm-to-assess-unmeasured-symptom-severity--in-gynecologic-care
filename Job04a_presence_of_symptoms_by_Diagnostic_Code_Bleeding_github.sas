libname in /*filepath to severity data*/;

proc formats cntlin=in.redcapformats; run;

data one;
set in.Severity_1c;
/*SYMP: Heavy Bleeding*/
	/*	R_GYNSYMP_NOTE_HEAVYBLEED*/
/*SYMP: Irregular Bleeding */
	/*	R_GYNDX_NOTE_ABNORMALBLEEDING*/
/*MD: Heavy Bleeding as indication*/
	/*  R_PREOPDX_MENORRHAGIA*/
/*MD: Irregular Bleeding as indication*/
	/*	R_PLAN_AUB*/
/*SYMP: Period > 7 days*/
	/*	R_GYNSYMP_NOTE_PERIODDURATION7*/
/*SYMP: LH/Dizziness*/
	/*	R_GYNSYMP_NOTE_DIZZYFATIGUE*/
/*MD: Iron Use*/
	/*	R_MEDUSE_RX_IRON*/
/*MD: Anemia as indication*/
	/*	R_PREOPDX_ANEMIA*/
/*MD: Blood Tx*/
	/*		R_pretx_bloodtrans*/
/*DX: ED Visit - Anemia*/
	/*	C_ed_visits_anemia_prior*/
	IF C_ed_visits_anemia_prior=0 THEN ED_ANEMIA=0;
		ELSE IF C_ed_visits_anemia_prior=1 THEN ED_ANEMIA=1;
		ELSE IF C_ed_visits_anemia_prior>1 THEN ED_ANEMIA=2;
ED_ANEMIA_1 = (ED_ANEMIA=1);
ED_ANEMIA_2 = (ED_ANEMIA=2);
/*DX: ED Visit - Bleeding*/
	/*	C_ed_visits_menorrhagia_prior*/
	IF C_ed_visits_menorrhagia_prior=0 THEN ED_menorrhagia=0;
		ELSE IF C_ed_visits_menorrhagia_prior=1 THEN ED_menorrhagia=1;
		ELSE IF C_ed_visits_menorrhagia_prior>1 THEN ED_menorrhagia=2;
ED_menorrhagia_1 = (ED_menorrhagia=1);
ED_menorrhagia_2 = (ED_menorrhagia=2);
/**/
/**/
/*USING THE DIAGNOSIS CODE*/
/**/
/**/
/*DX: Anemia at surgery*/
	/*	C_DX_ANEMIA*/
/*DX: Anemia prior to surgery */
	/*	C_DX_ANEMIA_PRIOR*/
if C_DX_ANEMIA=1 or C_DX_ANEMIA_PRIOR=1 then ANEMIA_CODE_EVER=1;
	else ANEMIA_CODE_EVER=0;
/*DX: VB prior to surgery*/
	/*	C_DX_MENORRHAGIA_PRIOR*/
/*DX: VB at surgery*/
	/*	C_DX_MENORRHAGIA*/
if C_DX_MENORRHAGIA=1 or C_DX_MENORRHAGIA_PRIOR=1 then MENORRHAGIA_CODE_EVER=1;
	else MENORRHAGIA_CODE_EVER=0;
merge=1;
run;

proc freq data=one;
/*tables ANEMIA_CODE_EVER*C_DX_ANEMIA*C_DX_ANEMIA_PRIOR 					C_DX_ANEMIA 		ANEMIA_CODE_EVER / list;*/
tables MENORRHAGIA_CODE_EVER*C_DX_MENORRHAGIA*C_DX_MENORRHAGIA_PRIOR 	C_DX_MENORRHAGIA 	MENORRHAGIA_CODE_EVER/	 list;
run;

data two;
set one;
if C_HGB_RESULT_KD_LOW<.z then delete;
bleed_score		=sum(C_DX_MENORRHAGIA,R_GYNSYMP_NOTE_HEAVYBLEED,R_GYNDX_NOTE_ABNORMALBLEEDING,R_PREOPDX_MENORRHAGIA,
					 2*R_PLAN_AUB,2*C_DX_MENORRHAGIA_PRIOR,2*R_GYNSYMP_NOTE_PERIODDURATION7,2*R_GYNSYMP_NOTE_DIZZYFATIGUE,
					 3*R_MEDUSE_RX_IRON,3*ED_menorrhagia_1,3*C_DX_ANEMIA,
					 4*C_HGB_result_KD_low,4*R_PREOPDX_ANEMIA,4*ED_menorrhagia_2,4*ED_ANEMIA_1,4*C_DX_ANEMIA_PRIOR,
					 5*ED_ANEMIA_2,5*R_pretx_bloodtrans);
run;

proc freq data=two;
tables C_HGB_result_KD_low*(R_GYNSYMP_NOTE_HEAVYBLEED /*C_DX_MENORRHAGIA_PRIOR*/R_pretx_bloodtrans);
run;


proc means data=two;
var bleed_score;
/*var */
/*C_DX_MENORRHAGIA R_GYNSYMP_NOTE_HEAVYBLEED*/
/*R_GYNDX_NOTE_ABNORMALBLEEDING R_PREOPDX_MENORRHAGIA*/
/*R_PLAN_AUB*/
/*C_DX_MENORRHAGIA_PRIOR*/
/*R_GYNSYMP_NOTE_PERIODDURATION7*/
/*R_GYNSYMP_NOTE_DIZZYFATIGUE*/
/*R_MEDUSE_RX_IRON*/
/*ED_menorrhagia_1*/
/*C_DX_ANEMIA*/
/*C_HGB_result_KD_low*/
/*R_PREOPDX_ANEMIA*/
/*ED_menorrhagia_2*/
/*ED_ANEMIA_1*/
/*C_DX_ANEMIA_PRIOR*/
/*R_pretx_bloodtrans;*/
/*ED_ANEMIA_2*/
run;

proc means data=two median min q1 median q3 max;
class C_DX_MENORRHAGIA;
var bleed_score;
run;

proc npar1way data=two wilcoxon;
class C_DX_MENORRHAGIA;
var bleed_score;
run;

proc freq data=two;
where bleed_score>=7;
tables C_DX_MENORRHAGIA; run;

proc freq data=two;
tables bleed_score;
run;
proc sort data=two; by bleed_score; run;
proc freq data=two;
where bleed_score=8;
tables
C_DX_MENORRHAGIA R_GYNSYMP_NOTE_HEAVYBLEED
R_GYNDX_NOTE_ABNORMALBLEEDING R_PREOPDX_MENORRHAGIA
R_PLAN_AUB
C_DX_MENORRHAGIA_PRIOR
R_GYNSYMP_NOTE_PERIODDURATION7
R_GYNSYMP_NOTE_DIZZYFATIGUE
R_MEDUSE_RX_IRON
ED_menorrhagia_1
C_DX_ANEMIA
C_HGB_result_KD_low
R_PREOPDX_ANEMIA
ED_menorrhagia_2
ED_ANEMIA_1
C_DX_ANEMIA_PRIOR
ED_ANEMIA_2
R_pretx_bloodtrans;
run;

proc freq data=two;
where bleed_score=1;
tables 
C_DX_MENORRHAGIA*R_GYNSYMP_NOTE_HEAVYBLEED*R_GYNDX_NOTE_ABNORMALBLEEDING*R_PREOPDX_MENORRHAGIA*R_PLAN_AUB*C_DX_MENORRHAGIA_PRIOR*R_GYNSYMP_NOTE_PERIODDURATION7*R_GYNSYMP_NOTE_DIZZYFATIGUE*R_MEDUSE_RX_IRON*ED_menorrhagia_1*
C_DX_ANEMIA*C_HGB_result_KD_low*R_PREOPDX_ANEMIA*ED_menorrhagia_2*ED_ANEMIA_1*C_DX_ANEMIA_PRIOR*R_pretx_bloodtrans*ED_ANEMIA_2 / list;
run;

/*Output csv file for Figure*/
data figure (keep = bleed_score _DX_MENORRHAGIA);
set two;
run;

PROC EXPORT DATA= WORK.figure
            OUTFILE= /*filepath for output*/
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


%macro overall_bleed(i,var);
proc freq data=two;
tables MENORRHAGIA_CODE_EVER*&var. / out=table outpct;
run;
data table2;
set table;
if &var.=1;
ROW_PERCENT=PCT_ROW/100;
run;
proc transpose data=table2 out=table3 prefix=CODE_OVERALL_; ID MENORRHAGIA_CODE_EVER; var ROW_PERCENT; run;
data out&i. (keep = order var CODE_OVERALL_0 CODE_OVERALL_1);
set table3;
length var $32;
format CODE_OVERALL_0 CODE_OVERALL_1 PERCENT.;
var="&var.";
order=&i.;
run;
proc print data=out&i.; run;
%mend overall_bleed;


%overall_bleed(1, R_GYNSYMP_NOTE_HEAVYBLEED);
%overall_bleed(2, R_GYNDX_NOTE_ABNORMALBLEEDING);
%overall_bleed(3, R_PREOPDX_MENORRHAGIA);
%overall_bleed(4, R_PLAN_AUB);
/*%overall_bleed(5, C_DX_MENORRHAGIA_PRIOR);*/
%overall_bleed(5, R_GYNSYMP_NOTE_PERIODDURATION7);
%overall_bleed(6, R_GYNSYMP_NOTE_DIZZYFATIGUE);
%overall_bleed(7, R_MEDUSE_RX_IRON);
%overall_bleed(8, ED_menorrhagia_1); /*Not in original version*/
%overall_bleed(9,C_DX_ANEMIA); /*Not in original version*/
%overall_bleed(10,R_PREOPDX_ANEMIA);
%overall_bleed(11,ED_menorrhagia_2); /*Not in original version*/
%overall_bleed(12,ED_ANEMIA_1); /*Not in original version*/
%overall_bleed(13,C_DX_ANEMIA_PRIOR); /*Not in original version*/
%overall_bleed(14,R_pretx_bloodtrans);
%overall_bleed(15,ED_ANEMIA_2);/*ED_ANEMIA_2*/
%overall_bleed(16,C_HGB_result_KD_low);

data overall_bleed;
set out1-out16;
run;

%LET i = 2;
%LET var =R_GYNDX_NOTE_ABNORMALBLEEDING;
%macro atsurgery_bleed(i,var);
proc freq data=two;
tables C_DX_MENORRHAGIA*&var. / out=table outpct;
run;
data table2;
set table;
if &var.=1;
ROW_PERCENT=PCT_ROW/100;
run;
proc transpose data=table2 out=table3 prefix=CODE_; ID C_DX_MENORRHAGIA; var ROW_PERCENT; run;
data out&i. (keep = order var CODE_0 CODE_1);
set table3;
length var $32;
format CODE_0 CODE_1 PERCENT.;
var="&var.";
order=&i.;
run;
%mend atsurgery_bleed;

%atsurgery_bleed(1, R_GYNSYMP_NOTE_HEAVYBLEED);
%atsurgery_bleed(2, R_GYNDX_NOTE_ABNORMALBLEEDING);
%atsurgery_bleed(3, R_PREOPDX_MENORRHAGIA);
%atsurgery_bleed(4, R_PLAN_AUB);
/*%atsurgery_bleed(5, C_DX_MENORRHAGIA_PRIOR);*/
%atsurgery_bleed(5, R_GYNSYMP_NOTE_PERIODDURATION7);
%atsurgery_bleed(6, R_GYNSYMP_NOTE_DIZZYFATIGUE);
%atsurgery_bleed(7, R_MEDUSE_RX_IRON);
%atsurgery_bleed(8, ED_menorrhagia_1); /*Not in original version*/
%atsurgery_bleed(9,C_DX_ANEMIA); /*Not in original version*/
%atsurgery_bleed(10,R_PREOPDX_ANEMIA);
%atsurgery_bleed(11,ED_menorrhagia_2); /*Not in original version*/
%atsurgery_bleed(12,ED_ANEMIA_1); /*Not in original version*/
%atsurgery_bleed(13,C_DX_ANEMIA_PRIOR); /*Not in original version*/
%atsurgery_bleed(14,R_pretx_bloodtrans);
%atsurgery_bleed(15,ED_ANEMIA_2);/*ED_ANEMIA_2*/
%atsurgery_bleed(16,C_HGB_result_KD_low);

data at_surgery;
set out1-out16;
run;

data bleed;
merge overall_bleed at_surgery;
by order;
if CODE_1=. 			then CODE_1=0;
if CODE_0=. 			then CODE_0=0;
if CODE_OVERALL_1=.		then CODE_OVERALL_1=0;
if CODE_OVERALL_0=. 	then CODE_OVERALL_0=0;
run;

proc print data=bleed;
var var CODE_OVERALL_1 CODE_OVERALL_0 CODE_1 CODE_0;
run;

