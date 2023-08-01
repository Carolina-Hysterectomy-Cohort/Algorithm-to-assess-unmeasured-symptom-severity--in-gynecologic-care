libname in /*filepath where severity data is saved*/;

options orientation=landscape;

proc formats cntlin=in.redcapformats; run;

proc format;
value ed 0="No ED visits"
		 1="1 ED visit"
		 2=">1 ED visit";
value hct 0="HCT of At Least 30"
		  1="HCT < 30";
value hbg 0="HGB of At Least 10"
		  1="HGB < 10"; 
run;

proc means data=in.severity_2;
var R_PREOPDX:;
run;


data one;
set in.severity_2;
merge=1;
/*DX: VB at surgery*/
	/*	C_DX_MENORRHAGIA*/
/*SYMP: Heavy Bleeding*/
	/*	R_GYNSYMP_NOTE_HEAVYBLEED*/
/*SYMP: Irregular Bleeding */
	/*	R_GYNDX_NOTE_ABNORMALBLEEDING*/
/*DX: VB prior to surgery*/
	/*	C_DX_MENORRHAGIA_PRIOR*/
/*MD: Heavy Bleeding as indication*/
	/*  R_PREOPDX_MENORRHAGIA*/
/*MD: Irregular Bleeding as indication*/
	/*	R_PLAN_AUB*/
/*MD: Iron Use*/
	/*	R_MEDUSE_RX_IRON*/
/*DX: Anemia at surgery*/
	/*	C_DX_ANEMIA*/
/*SYMP: Period > 7 days*/
	/*	R_GYNSYMP_NOTE_PERIODDURATION7*/
/*SYMP: LH/Dizziness*/
	/*	R_GYNSYMP_NOTE_DIZZYFATIGUE*/
/*LAB: Anemia Hgb*/
	/*	C_HGB_result_KD_low*/
/*DX: Anemia prior to surgery */
	/*	C_DX_ANEMIA_PRIOR*/
/*LAB: Anemia Hct*/
	/*	C_HCT_result_KD_low*/
/*SYMP: Missing work*/
	/*	R_GYNSYMP_NOTE_MISSDAYS*/
/*MD: Anemia as indication*/
	/*	R_PREOPDX_ANEMIA*/
/*DX: ED Visit - Bleeding*/
	/*	C_ed_visits_menorrhagia_prior*/
	IF C_ed_visits_menorrhagia_prior=0 THEN ED_menorrhagia=0;
		ELSE IF C_ed_visits_menorrhagia_prior=1 THEN ED_menorrhagia=1;
		ELSE IF C_ed_visits_menorrhagia_prior>1 THEN ED_menorrhagia=2;
/*MD: Blood Tx*/
	/*		R_pretx_bloodtrans*/
/*DX: ED Visit - Anemia*/
	/*	C_ed_visits_anemia_prior*/
	IF C_ed_visits_anemia_prior=0 THEN ED_ANEMIA=0;
		ELSE IF C_ed_visits_anemia_prior=1 THEN ED_ANEMIA=1;
		ELSE IF C_ed_visits_anemia_prior>1 THEN ED_ANEMIA=2;
format ED_ANEMIA ED_menorrhagia ed.;
format C_HGB_result_KD_low hbg.;
format C_HCT_result_KD_low hct.;
run;

proc freq data=one;
tables
C_DX_MENORRHAGIA R_GYNSYMP_NOTE_HEAVYBLEED R_GYNSYMP_NOTE_IRREGBLEED C_DX_MENORRHAGIA_PRIOR
R_PREOPDX_MENORRHAGIA R_PLAN_AUB R_MEDUSE_RX_IRON C_DX_ANEMIA R_GYNSYMP_NOTE_PERIODDURATION7 
R_GYNSYMP_NOTE_DIZZYFATIGUE C_HGB_result_KD_low C_DX_ANEMIA_PRIOR C_HCT_result_KD_low
R_GYNSYMP_NOTE_MISSDAYS R_PREOPDX_ANEMIA ED_menorrhagia R_pretx_bloodtrans ED_ANEMIA;
run;


data histogram;
set one;
/*1 POINT SCALES*/
/*DX: VB at surgery*/
	/*  C_DX_MENORRHAGIA*/
/*SYMP: Heavy Bleeding*/
	/*	R_GYNSYMP_NOTE_HEAVYBLEED*/
/*SYMP: Irregular Bleeding */
	/*	R_GYNSYMP_NOTE_IRREGBLEED*/
/*MD: Heavy Bleeding as indication*/
	/*  R_PREOPDX_MENORRHAGIA*/
/**/
/*2 POINT SCALES*/
/*DX: VB prior to surgery*/
	/*	C_DX_MENORRHAGIA_PRIOR*/
/*SYMP: Period > 7 days*/
	/*	R_GYNSYMP_NOTE_PERIODDURATION7*/
/*SYMP: LH/Dizziness*/
	/*	R_GYNSYMP_NOTE_DIZZYFATIGUE*/
/**/
/*3 POINT SCALES*/
/*MD: Iron Use*/
	/*	R_MEDUSE_RX_IRON*/
/*DX: ED Visit – Bleeding 1 */
if ED_menorrhagia=1 then ED_BLEEDING_1=1;
	else if ED_menorrhagia IN(0,2) then ED_BLEEDING_1=0;
/*DX: Anemia at surgery*/
	/*	C_DX_ANEMIA*/
/**/
/*4 POINT SCALES*/
/*LAB: Anemia Hgb*/
/*	C_HGB_result_KD_low*/
/*LAB: Anemia Hct*/
	/*	C_HCT_result_KD_low*/
/*MD: Anemia as indication*/
	/*	R_PREOPDX_ANEMIA*/
/*DX: ED Visit – Bleeding 1+ */
if ED_menorrhagia=2 then ED_BLEEDING_2=1;
	else if ED_menorrhagia IN(0,1) then ED_BLEEDING_2=0;
/*DX: ED Visit – Anemia 1 */
if ED_ANEMIA=1 then ED_ANEMIA_1=1;
	else if ED_ANEMIA IN(0,2) then ED_ANEMIA_1=0;
/*DX: Anemia prior to surgery */
	/*	C_DX_ANEMIA_PRIOR*/
/**/
/*5 POINT SCALES*/
/*MD: Blood Tx*/
/*DX: ED Visit –Anemia 1+ */
if ED_ANEMIA=2 then ED_ANEMIA_2=1;
	else if ED_ANEMIA IN(0,1) then ED_ANEMIA_2=0;
/**/
bleed_score		=sum(C_DX_MENORRHAGIA,R_GYNSYMP_NOTE_HEAVYBLEED,R_GYNDX_NOTE_ABNORMALBLEEDING,R_PREOPDX_MENORRHAGIA,
					 2*R_PLAN_AUB,2*C_DX_MENORRHAGIA_PRIOR,2*R_GYNSYMP_NOTE_PERIODDURATION7,2*R_GYNSYMP_NOTE_DIZZYFATIGUE,
					 3*R_MEDUSE_RX_IRON,3*ED_BLEEDING_1,3*C_DX_ANEMIA,
					 4*C_HGB_result_KD_low,4*R_PREOPDX_ANEMIA,4*ED_BLEEDING_2,4*ED_ANEMIA_1,4*C_DX_ANEMIA_PRIOR,
					 5*ED_ANEMIA_2,5*R_pretx_bloodtrans);
bleed_score_nl  =sum(C_DX_MENORRHAGIA,R_GYNSYMP_NOTE_HEAVYBLEED,R_GYNDX_NOTE_ABNORMALBLEEDING,R_PREOPDX_MENORRHAGIA,
					 2*R_PLAN_AUB,2*C_DX_MENORRHAGIA_PRIOR,2*R_GYNSYMP_NOTE_PERIODDURATION7,2*R_GYNSYMP_NOTE_DIZZYFATIGUE,
					 3*R_MEDUSE_RX_IRON,3*ED_BLEEDING_1,3*C_DX_ANEMIA,
					 4*R_PREOPDX_ANEMIA,4*ED_BLEEDING_2,4*ED_ANEMIA_1,4*C_DX_ANEMIA_PRIOR,
					 5*ED_ANEMIA_2,5*R_pretx_bloodtrans);
run;

/*For new variables*/ 
proc sort data=histogram; by C_DX_MENORRHAGIA; run;
proc freq data=histogram noprint;
by C_DX_MENORRHAGIA;                    	     	 /* X categories on BY statement */
tables C_HCT_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HCT < 30 by Vaginal Bleeding Diagnosis Code at Surgery (DX)";
proc sgplot data=FreqOut;
vbar C_DX_MENORRHAGIA / response=Percent group=C_HCT_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label C_DX_MENORRHAGIA="Vaginal Bleeding Diagnosis Code at Surgery (DX)";
run;

proc sort data=histogram; by C_DX_MENORRHAGIA; run;
proc freq data=histogram noprint;
by C_DX_MENORRHAGIA;                    	     	 /* X categories on BY statement */
tables C_HGB_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HGB < 10 by Vaginal Bleeding Diagnosis Code at Surgery (DX)";
proc sgplot data=FreqOut;
vbar C_DX_MENORRHAGIA / response=Percent group=C_HGB_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label C_DX_MENORRHAGIA="Vaginal Bleeding Diagnosis Code at Surgery (DX)";
run;

/*For new variables*/ 
proc sort data=histogram; by R_GYNSYMP_NOTE_HEAVYBLEED; run;
proc freq data=histogram noprint;
by R_GYNSYMP_NOTE_HEAVYBLEED;                    	     	 /* X categories on BY statement */
tables C_HCT_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HCT < 30 by Heavy Bleeding (SYMP)";
proc sgplot data=FreqOut;
vbar R_GYNSYMP_NOTE_HEAVYBLEED / response=Percent group=C_HCT_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label R_GYNSYMP_NOTE_HEAVYBLEED="Heavy Bleeding (SYMP)";
run;

proc sort data=histogram; by R_GYNSYMP_NOTE_HEAVYBLEED; run;
proc freq data=histogram noprint;
by R_GYNSYMP_NOTE_HEAVYBLEED;                    	     	 /* X categories on BY statement */
tables C_HGB_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HGB < 10 by Heavy Bleeding (SYMP)";
proc sgplot data=FreqOut;
vbar R_GYNSYMP_NOTE_HEAVYBLEED / response=Percent group=C_HGB_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label R_GYNSYMP_NOTE_HEAVYBLEED="Heavy Bleeding (SYMP)";
run;

/*For new variables*/ 
proc sort data=histogram; by R_GYNSYMP_NOTE_MISSDAYS; run;
proc freq data=histogram noprint;
by R_GYNSYMP_NOTE_MISSDAYS;                    	     	 /* X categories on BY statement */
tables C_HCT_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HCT < 30 by Missing work (SYMP)";
proc sgplot data=FreqOut;
vbar R_GYNSYMP_NOTE_MISSDAYS / response=Percent group=C_HCT_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label R_GYNSYMP_NOTE_MISSDAYS="Missing work (SYMP)";
run;

proc sort data=histogram; by R_GYNSYMP_NOTE_MISSDAYS; run;
proc freq data=histogram noprint;
by R_GYNSYMP_NOTE_MISSDAYS;                    	     	 /* X categories on BY statement */
tables C_HGB_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HGB < 10 by Missing work (SYMP)";
proc sgplot data=FreqOut;
vbar R_GYNSYMP_NOTE_MISSDAYS / response=Percent group=C_HGB_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label R_GYNSYMP_NOTE_MISSDAYS="Missing work (SYMP)";
run;


/*For new variables*/ 
proc sort data=histogram; by R_GYNSYMP_NOTE_PERIODDURATION7; run;
proc freq data=histogram noprint;
by R_GYNSYMP_NOTE_PERIODDURATION7;                    	     	 /* X categories on BY statement */
tables C_HCT_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HCT < 30 by Period Last Longer than 7 Days (SYMP)";
proc sgplot data=FreqOut;
vbar R_GYNSYMP_NOTE_PERIODDURATION7 / response=Percent group=C_HCT_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label R_GYNSYMP_NOTE_PERIODDURATION7="Period Last Longer than 7 Days (SYMP)";
run;

proc sort data=histogram; by R_GYNSYMP_NOTE_PERIODDURATION7; run;
proc freq data=histogram noprint;
by R_GYNSYMP_NOTE_PERIODDURATION7;                    	     	 /* X categories on BY statement */
tables C_HGB_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HGB < 10 by Period Last Longer than 7 Days (SYMP)";
proc sgplot data=FreqOut;
vbar R_GYNSYMP_NOTE_PERIODDURATION7 / response=Percent group=C_HGB_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label R_GYNSYMP_NOTE_PERIODDURATION7="Period Last Longer than 7 Days (SYMP)";
run;

/*For new variables*/ 
proc sort data=histogram; by ED_menorrhagia; run;
proc freq data=histogram noprint;
by ED_menorrhagia;                    	     	 /* X categories on BY statement */
tables C_HCT_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HCT < 30 by ER Visits Related to Bleeding (DX)";
proc sgplot data=FreqOut;
vbar ED_menorrhagia / response=Percent group=C_HCT_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label ED_menorrhagia="ER Visits Related to Bleeding (DX) ";
run;

proc sort data=histogram; by ED_menorrhagia; run;
proc freq data=histogram noprint;
by ED_menorrhagia;                    	     	 /* X categories on BY statement */
tables C_HGB_result_KD_low / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% with HGB < 10 by ER Visits Related to Bleeding (DX) ";
proc sgplot data=FreqOut;
vbar ED_menorrhagia / response=Percent group=C_HGB_result_KD_low groupdisplay=stack;
yaxis grid values=(0 to 100 by 10) label="%";
label ED_menorrhagia="ER Visits Related to Bleeding (DX) ";
run;
