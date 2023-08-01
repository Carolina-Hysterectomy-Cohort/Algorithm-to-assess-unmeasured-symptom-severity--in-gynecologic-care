libname in /*filepath to severity data*/;

proc formats cntlin=in.redcapformats; run;

data one;
set in.severity_1c;
/*proc freq data=in.severity_v1b;*/
/*tables*/
/*SYMP – Pelvic Pain*/
	/*	R_GYNSYMP_NOTE_PELVPAIN*/
/*SYMP – Painful periods*/
	/*	R_GYNSYMP_NOTE_PERIODPAIN*/
/*MEDS - Opoid*/
	/*	THESE NUMBERS ARE DIFFERENT THAN SHARONS*/
	/*  Updated 02.13.2020 based on questions for Sharon*/
	/*	c_med_opiod_prior*/
/*MEDS - NSAID*/
	/*	THESE NUMBERS ARE DIFFERENT THAN SHARONS*/
	/* Updated 02.13.2020 based on questions for Sharon*/
	/*	c_med_nsaid_prior*/
/*MD -  Pain as indication for surgery*/
/*		R_PLAN_CHRONICPELVPAIN*/
/*DX – Pain prior to surgery*/
	/*	C_DX_PAIN_PRIOR*/
/*DX – Pain at surgery*/
	/*	C_DX_PAIN*/
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

pain_score=sum(R_GYNSYMP_NOTE_PELVPAIN,R_GYNSYMP_NOTE_PERIODPAIN,R_GYNSYMP_NOTE_INTERCOURSEPAIN,C_Med_acetaminophen_prior,
				2*c_med_nsaid_prior,2*R_PLAN_CHRONICPELVPAIN,2*R_PREOPDX_DYSMENORRHEA,
				3*C_DX_PAIN_PRIOR,3*C_DX_PAIN,3*C_Med_other_prior,
				4*c_med_opiod_prior,4*ED_pain_c2,4*C_Med_MUSCLE_RELAXANTS);
pain_score_no_opoid=sum(R_GYNSYMP_NOTE_PELVPAIN,R_GYNSYMP_NOTE_PERIODPAIN,R_GYNSYMP_NOTE_INTERCOURSEPAIN,C_Med_acetaminophen_prior,
				2*c_med_nsaid_prior,2*R_PLAN_CHRONICPELVPAIN,2*R_PREOPDX_DYSMENORRHEA,
				3*C_DX_PAIN_PRIOR,3*C_DX_PAIN,3*C_Med_other_prior,
				4*ED_pain_c2,4*C_Med_MUSCLE_RELAXANTS);
;
run;

proc means data=one;
var pain_score;
run;



/*%LET var = R_PREOPDX_PAINOTHER;*/
/*%LET label = MD – Other pain as indication;*/

proc format;
value  in 0 ="Absent"
		  1="Yes";
value ER  0="None"
		  1="1 ER Visit"
		  2="1+ ER Visits";
run;

%macro opoid(var,label);
proc sort data=one; by &var.; run;
proc freq data=one noprint;
by &var.;                    				 /* X categories on BY statement */
tables c_med_opiod_prior / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% On Opioids by &label.";
proc sgplot data=FreqOut;
vbar &var. / response=Percent group=c_med_opiod_prior groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="%";
label &var.="&label.";
/*format high_utweight_c3 weight.;*/
keylegend / title="MEDS - Opioid";
format c_med_opiod_prior in. ER_pain_c3 er.;
run;
%mend opoid;

/*1 point*/
%opoid(R_GYNSYMP_NOTE_PELVPAIN,				SYMP – Pelvic Pain);
%opoid(R_GYNSYMP_NOTE_PERIODPAIN,			SYMP – Painful periods);
%opoid(R_GYNSYMP_NOTE_INTERCOURSEPAIN,		SYMP – Painful Intercourse);
%opoid(C_Med_acetaminophen_prior,			MEDS – Tylenol);
/*2 points - what about MD - Pain as indication for surgery*/
%opoid(c_med_nsaid_prior,					MEDS - NSAID);
%opoid(R_PLAN_CHRONICPELVPAIN,				MD - Pelvic Pain as indication for surgery);
%opoid(R_PREOPDX_DYSMENORRHEA,				MD – Painful periods as indication);
/*3 points*/
%opoid(C_DX_PAIN_PRIOR,						DX – Pain prior to surgery);
%opoid(C_DX_PAIN,							DX – Pain at surgery);
%opoid(R_GYNSYMP_NOTE_MISSDAYS,				SYMP – Missing work);
/*4 points*/
%opoid(ED_pain_c3,							DX – ER visit);
%opoid(C_Med_MUSCLE_RELAXANTS,				MEDS – Muscle Relaxant);

/*WHAT ABOUT THESE?*/
%opoid(R_PREOPDX_PAINOTHER,					MD – Other pain as indication);
%opoid(PREOPDX_DSYPAREUNIA,					MD - Painful intercourse as indication);
%opoid(C_Med_other_prior,					MEDS - Other);

data histogram;
set one;
run;

proc means data=histogram;run;
