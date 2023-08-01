libname in /*path to severity data*/;
libname out /*path to analytic output*/;

proc format cntlin=in.redcapformats; run;

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
/**/
/*Bleeding score*/
/**/
if C_HGB_RESULT_KD_LOW<.z then bleed_score=.;
	else bleed_score=sum(C_DX_MENORRHAGIA,R_GYNSYMP_NOTE_HEAVYBLEED,R_GYNDX_NOTE_ABNORMALBLEEDING,R_PREOPDX_MENORRHAGIA,
					 2*R_PLAN_AUB,2*C_DX_MENORRHAGIA_PRIOR,2*R_GYNSYMP_NOTE_PERIODDURATION7,2*R_GYNSYMP_NOTE_DIZZYFATIGUE,
					 3*R_MEDUSE_RX_IRON,3*ED_menorrhagia_1,3*C_DX_ANEMIA,
					 4*C_HGB_result_KD_low,4*R_PREOPDX_ANEMIA,4*ED_menorrhagia_2,4*ED_ANEMIA_1,4*C_DX_ANEMIA_PRIOR,
					 5*ED_ANEMIA_2,5*R_pretx_bloodtrans);
/**/
/*SYMP: Bloating */
/*R_GYNSYMP_NOTE_BLOAT*/
/**/
/*SYMP: Pelvic pressure*/
/*R_GYNSYMP_NOTE_PELVPRESSURE*/
/**/
/*Uterine size category*/
/*Need to make this a three category variable*/
/*R_OPNT_PATH_UTWEIGHT*/
/**/
/*SYMP: Bulk NOS*/
/*R_GYNDX_NOTE_BULK*/
/**/
/**/
/*MD: Bulk as surgery indication - redcap */
/*R_PREOPDX_BULK*/
/**/
/*BILLING CODES*/
/**/
/*DX: code at surgery*/
/*C_DX_BULK - Bulk code at surgery (CDWH)*/
/**/
/*DX: code prior to surgery*/
/*C_DX_BULK_PRIOR - Bulk code in year prior (CDWH)*/
/**/
if C_DX_BULK=1 or C_DX_BULK_PRIOR=1 then BULK_CODE_EVER=1;
	else BULK_CODE_EVER=0;
merge=1;

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
/**/
/*pain score*/
/**/
pain_score=sum(R_GYNSYMP_NOTE_PELVPAIN,R_GYNSYMP_NOTE_PERIODPAIN,R_GYNSYMP_NOTE_INTERCOURSEPAIN,C_Med_acetaminophen_prior,
	2*c_med_nsaid_prior,2*R_PLAN_CHRONICPELVPAIN,2*R_PREOPDX_DYSMENORRHEA,
	3*C_DX_PAIN_PRIOR,3*C_DX_PAIN,3*C_Med_other_prior,
	4*c_med_opiod_prior,4*ED_pain_c2,4*C_Med_MUSCLE_RELAXANTS);
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
/*Uterine Weight 3 Category*/
if R_OPNT_PATH_UTWEIGHT>P75 then utweight_c3=3;
	else if R_OPNT_PATH_UTWEIGHT>P50 then utweight_c3=2;
	else if R_OPNT_PATH_UTWEIGHT>.z then utweight_c3=1;
label utweight_c3="Uterine Weight Category (1=<50th Percentile, 2=50-75th Percentile, 3=At or Above 75th Percentile";
/*Create indicators*/
utweight_high=(utweight_c3=3);
utweight_mod =(utweight_c3=2);
utweight_low =(utweight_c3=1);
/*1 POINT SCALES*/
/*SYMP: Bloating*/
if R_GYNSYMP_NOTE_BLOAT=1 then GYNSYMP_NOTE_BLOAT=1;
	else if R_GYNSYMP_NOTE_BLOAT=0 then GYNSYMP_NOTE_BLOAT=0;
/*SYMP: Pelvic pressure*/
if R_GYNSYMP_NOTE_PELVPRESSURE=1 then GYNSYMP_NOTE_PELVPRESSURE=1;
	else if R_GYNSYMP_NOTE_PELVPRESSURE=0 then GYNSYMP_NOTE_PELVPRESSURE=0;
/**/
/*Bulk score*/
/*bulk score is missing for those with missing uterine weight*/
/**/
if R_OPNT_PATH_UTWEIGHT<.z then bulk_score=.;
	else bulk_score	=sum(GYNSYMP_NOTE_BLOAT,R_GYNSYMP_NOTE_PELVPRESSURE,utweight_mod,
			  	 	 2*C_DX_BULK,
			  	     3*C_DX_BULK_PRIOR,3*R_GYNDX_NOTE_BULK,3*R_PREOPDX_BULK,
			  	     4*utweight_high);
run;

proc means data=two n nmiss mean std min q1 median q3 max;
var bleed_score bulk_score pain_score;
run;

proc format; 
value 	table 	0 = " "
		  		1 = "X";
run;

/**/
/**/
/*Bulk Score*/
/**/
/**/
proc means data=two n nmiss min q1 median q3 max; var bulk_score; run;
proc sort data=two; by bulk_score; run;
proc freq data=two;
where bulk_score IN(0,1,4,14);
by bulk_score;
tables GYNSYMP_NOTE_BLOAT*R_GYNSYMP_NOTE_PELVPRESSURE*utweight_mod*C_DX_BULK*R_GYNDX_NOTE_BULK*R_PREOPDX_BULK*C_DX_BULK_PRIOR*utweight_high / list missing out=bulk;
format GYNSYMP_NOTE_BLOAT R_GYNSYMP_NOTE_PELVPRESSURE utweight_mod C_DX_BULK R_GYNDX_NOTE_BULK R_PREOPDX_BULK C_DX_BULK_PRIOR utweight_high table.;
run;
proc freq data=two;
where bulk_score>.z;
tables bulk_score / list out=bulk_score;
run;
data bulk_score_count(keep = bulk_score score);
set bulk_score;
score = strip(bulk_score)||" (N="||strip(COUNT)||")";
run;
data bulk_score_table/*(drop = bulk_score COUNT)*/;
merge bulk_score_count bulk;
by bulk_score;
total = strip(COUNT)||" ("||strip(round(PERCENT))||"%)"; 
run;
options orientation=landscape;
ods rtf file=/*path to analytic output*/ style=journal;
proc print data=bulk_score_table;
ID score;
var GYNSYMP_NOTE_BLOAT R_GYNSYMP_NOTE_PELVPRESSURE utweight_mod C_DX_BULK R_GYNDX_NOTE_BULK R_PREOPDX_BULK C_DX_BULK_PRIOR utweight_high total;
run;
ods rtf close;


/**/
/**/
/*Bleeding Score*/
/**/
/**/
proc means data=two n nmiss min q1 median q3 max; var bleed_score; run;
proc sort data=two; by bleed_score; run;
proc freq data=two;
where bleed_score IN (0,2,5,11,44);
by bleed_score;
tables C_DX_MENORRHAGIA*R_GYNSYMP_NOTE_HEAVYBLEED*R_GYNDX_NOTE_ABNORMALBLEEDING*R_PREOPDX_MENORRHAGIA*R_PLAN_AUB*C_DX_MENORRHAGIA_PRIOR*R_GYNSYMP_NOTE_PERIODDURATION7*R_GYNSYMP_NOTE_DIZZYFATIGUE*R_MEDUSE_RX_IRON*ED_menorrhagia_1*
C_DX_ANEMIA*C_HGB_result_KD_low*R_PREOPDX_ANEMIA*ED_menorrhagia_2*ED_ANEMIA_1*C_DX_ANEMIA_PRIOR*R_pretx_bloodtrans*ED_ANEMIA_2 / list missing out=bleed;
format C_DX_MENORRHAGIA R_GYNSYMP_NOTE_HEAVYBLEED R_GYNDX_NOTE_ABNORMALBLEEDING R_PREOPDX_MENORRHAGIA R_PLAN_AUB C_DX_MENORRHAGIA_PRIOR R_GYNSYMP_NOTE_PERIODDURATION7 R_GYNSYMP_NOTE_DIZZYFATIGUE R_MEDUSE_RX_IRON ED_menorrhagia_1 
C_DX_ANEMIA C_HGB_result_KD_low R_PREOPDX_ANEMIA ED_menorrhagia_2 ED_ANEMIA_1 C_DX_ANEMIA_PRIOR R_pretx_bloodtrans ED_ANEMIA_2 table.;
run;
proc freq data=two;
where bleed_score IN (0,2,5,11,44);
tables bleed_score / list out=bleed_score;
run;
data bleed_score_count(keep = bleed_score score);
set bleed_score;
score = strip(bleed_score)||" (N="||strip(COUNT)||")";
run;
data bleed_score_table/*(drop = bleed_score COUNT)*/;
merge bleed_score_count bleed;
by bleed_score;
total = strip(COUNT)||" ("||strip(round(PERCENT))||"%)"; 
run;
ods rtf file=/*path to analytic output*/ style=journal;
proc print data=bleed_score_table;
ID score;
var C_DX_MENORRHAGIA R_GYNSYMP_NOTE_HEAVYBLEED R_GYNDX_NOTE_ABNORMALBLEEDING R_PREOPDX_MENORRHAGIA R_PLAN_AUB C_DX_MENORRHAGIA_PRIOR R_GYNSYMP_NOTE_PERIODDURATION7 R_GYNSYMP_NOTE_DIZZYFATIGUE R_MEDUSE_RX_IRON ED_menorrhagia_1 
    C_DX_ANEMIA C_HGB_result_KD_low R_PREOPDX_ANEMIA ED_menorrhagia_2 ED_ANEMIA_1 C_DX_ANEMIA_PRIOR R_pretx_bloodtrans ED_ANEMIA_2 total;
run;
ods rtf close;




/**/
/**/
/*Pain Score*/
/**/
/**/
proc means data=two n nmiss min q1 median q3 max; var pain_score; run;
proc sort data=two; by pain_score; run;
proc freq data=two;
where pain_score IN(0,1,4,8,30);
by pain_score;
tables R_GYNSYMP_NOTE_PELVPAIN*R_GYNSYMP_NOTE_PERIODPAIN*R_GYNSYMP_NOTE_INTERCOURSEPAIN*C_Med_acetaminophen_prior
				*c_med_nsaid_prior*R_PREOPDX_DYSMENORRHEA*R_PLAN_CHRONICPELVPAIN
				*C_DX_PAIN_PRIOR*C_DX_PAIN*C_Med_other_prior
				*c_med_opiod_prior*ED_pain_c2*C_Med_MUSCLE_RELAXANTS/ list missing out=pain;
format R_GYNSYMP_NOTE_PELVPAIN R_GYNSYMP_NOTE_PERIODPAIN R_GYNSYMP_NOTE_INTERCOURSEPAIN C_Med_acetaminophen_prior  
				c_med_nsaid_prior R_PREOPDX_DYSMENORRHEA R_PLAN_CHRONICPELVPAIN
				C_DX_PAIN_PRIOR C_DX_PAIN C_Med_other_prior
				c_med_opiod_prior ED_pain_c2 C_Med_MUSCLE_RELAXANTS table.;
run;
proc freq data=two;
where pain_score IN(0,1,4,8,30);
tables pain_score / list out=pain_score;
run;
data pain_score_count(keep = pain_score score);
set pain_score;
score = strip(pain_score)||" (N="||strip(COUNT)||")";
run;
data pain_score_table/*(drop = pain_score COUNT)*/;
merge pain_score_count pain;
by pain_score;
total = strip(COUNT)||" ("||strip(round(PERCENT))||"%)"; 
run;
ods rtf file=/*path to analytic output*/ style=journal;
proc print data=pain_score_table;
ID score;
var R_GYNSYMP_NOTE_PELVPAIN R_GYNSYMP_NOTE_PERIODPAIN R_GYNSYMP_NOTE_INTERCOURSEPAIN C_Med_acetaminophen_prior  
				c_med_nsaid_prior R_PREOPDX_DYSMENORRHEA R_PLAN_CHRONICPELVPAIN
				C_DX_PAIN_PRIOR C_DX_PAIN C_Med_other_prior
				c_med_opiod_prior ED_pain_c2 C_Med_MUSCLE_RELAXANTS total;
run;
ods rtf close;
