libname in /*filepath to data*/;

proc formats cntlin=in.redcapformats; run;

data one;
set in.Severity_1c;
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
run;

proc freq data=one;
tables BULK_CODE_EVER*C_DX_BULK*C_DX_BULK_PRIOR C_DX_BULK BULK_CODE_EVER/ list;
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
/*removing those with missing uterine weight*/
if R_OPNT_PATH_UTWEIGHT<.z then delete;
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

/*2 POINT SCALES*/
/*DX: code at surgery*/
/*Creating indicator*/
bulk_score_v2	=sum(GYNSYMP_NOTE_BLOAT,R_GYNSYMP_NOTE_PELVPRESSURE,utweight_mod,
			  	 2*C_DX_BULK,
			  	 3*C_DX_BULK_PRIOR,3*R_GYNDX_NOTE_BULK,3*R_PREOPDX_BULK,
			  	 4*utweight_high);
run;

proc freq data=two;
tables bulk_score_v2;run;

/*Getting overall distribution*/
proc means data=two n q1 median q3;
var bulk_score_v2;
run;

/*Getting % with no diagnosis at or above Median*/
proc freq data=two;
where bulk_score_v2>=6;
tables C_DX_BULK;
run;

/*Getting values for those iwth and without diatnggos*/
proc means data=two n q1 median q3 max;
class C_DX_BULK;
var bulk_score_v2;
run;

/*Testing for differences in medians*/
proc npar1way data=two wilcoxon;
class C_DX_BULK;
var  bulk_score_v2;
run;

/*Experimenting with how you get to what score*/
proc sort data=two; by bulk_score_v2; run;
proc freq data=two;
by bulk_score_V2;
tables GYNSYMP_NOTE_BLOAT*R_GYNSYMP_NOTE_PELVPRESSURE*utweight_mod*C_DX_BULK*R_GYNDX_NOTE_BULK*R_PREOPDX_BULK*C_DX_BULK_PRIOR*utweight_high / missing list;
run;

proc freq data=two;
where bulk_score_v2=7;
tables  GYNSYMP_NOTE_BLOAT
		R_GYNSYMP_NOTE_PELVPRESSURE
		utweight_mod	
		C_DX_BULK
		C_DX_BULK_PRIOR
		R_GYNDX_NOTE_BULK
		R_PREOPDX_BULK	
		utweight_high / missing list;
run;

/*Output csv file for Figure*/
data figure (keep = bulk_score_v2 C_DX_BULK);
set two;
run;

PROC EXPORT DATA= WORK.figure
            OUTFILE= /*filepath for output*/
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

%macro overall_bulk(i,var);
proc freq data=two;
tables BULK_CODE_EVER*&var. / out=table outpct;
run;
data table2;
set table;
if &var.=1;
ROW_PERCENT=PCT_ROW/100;
run;
proc transpose data=table2 out=table3 prefix=CODE_OVERALL_; ID BULK_CODE_EVER; var ROW_PERCENT; run;
data out&i. (keep = order var CODE_OVERALL_0 CODE_OVERALL_1);
set table3;
length var $32;
format CODE_OVERALL_0 CODE_OVERALL_1 PERCENT.;
var="&var.";
order=&i.;
run;
proc print data=out&i.; run;
%mend overall_bulk;

/*%overall_bulk(1,R_GYNSYMP_NOTE_BLOAT);*/
/*%overall_bulk(2,R_GYNSYMP_NOTE_PELVPRESSURE);*/
/*%overall_bulk(3,utweight_mod);*/
/*%overall_bulk(4,R_GYNDX_NOTE_BULK);*/
/*%overall_bulk(5,R_PREOPDX_BULK);*/
/*%overall_bulk(6,utweight_high);*/

data overall_bulk;
set out1-out6;
run;

%macro atsurgery_bulk(i,var);
proc freq data=two;
tables C_DX_BULK*&var. / out=table outpct;
run;
data table2;
set table;
if &var.=1;
ROW_PERCENT=PCT_ROW/100;
run;
proc transpose data=table2 out=table3 prefix=CODE_; ID C_DX_BULK; var ROW_PERCENT; run;
data out&i. (keep = order var CODE_0 CODE_1);
set table3;
length var $32;
format CODE_0 CODE_1 PERCENT.;
var="&var.";
order=&i.;
run;
%mend atsurgery_bulk;

/*%atsurgery_bulk(1,R_GYNSYMP_NOTE_BLOAT);*/
/*%atsurgery_bulk(2,R_GYNSYMP_NOTE_PELVPRESSURE);*/
/*%atsurgery_bulk(3,utweight_mod);*/
/*%atsurgery_bulk(4,R_GYNDX_NOTE_BULK);*/
/*%atsurgery_bulk(5,R_PREOPDX_BULK);*/
/*%atsurgery_bulk(6,utweight_high);*/

data at_surgery;
set out1-out6;
run;

data bulk;
merge overall_bulk at_surgery;
by order;
run;

