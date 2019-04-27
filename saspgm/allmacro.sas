*-----------------------------------------------------------------------------;
* Study.......: MIN1901/RECAP1901                                             ;
* Name........: allmacro.sas                                                  ;
* Date........: 2019-03-01                                                    ;
* Author......: danbai                                                        ;
* Purpose.....: This program stores macros used for RECAP1901                 ;
* Note........:                                                               ;
*-----------------------------------------------------------------------------;

/** macro km: use to plot reversed Kaplan-Meier curve by exposure **/ 
%macro km (data=, outcome=, exposure=, lbl=, max=, expfmt=);
proc lifetest data=&data NOTABLE outsurv=surv1;
time years*censored(1);
strata &exposure;
run;

data surv2;
 set surv1;
 survival = 1-survival;
 sdf_lcl=1-sdf_lcl;
 sdf_ucl=1-sdf_ucl;
 label &exposure="&lbl";
run;

ods graphics on / outputfmt=png;
title "Reverse Kaplan Meier Curve for Offspring's &outcome Probability"; 
proc gplot data=surv2 ;
axis1 order=0 to &max by 0.005 minor=none label=(a=90 "Probability of &outcome");
axis2 minor=none label=('Follow-up Time (Years)');
legend1 mode=protect position=(inside left top);
symbol1 c=red  i=join v=none w=2 l=1;
symbol2 c=blue i=join v=none w=2 l=1;
plot survival*years=&exposure 
/vaxis=axis1 haxis=axis2 legend=legend1;
format &exposure &expfmt;
run;
ods graphics off;
%mend km;


/** macro est: Cox regression, no splines **/ 
%macro est(data=, out=, class=, freq=, by=, id=, exposure=, lbl=);
proc sort data=&data; by &by &id; run;
title1 "ASD among participants - Exposure: &lbl";
title2 "Cox: Adjusted for participant's &class";
ods output estimates=&out; * NObs=nob2 censoredsummary=cens2;
%if &freq=0 %then %do;
proc phreg data=&data nosummary;
class &exposure &class / param=glm order=internal;
model years*censored(1) = &exposure &class / alpha=0.05 risklimit=wald NODUMMYPRINT;
strata &id;
by &by;
estimate "'&lbl'"  &exposure -1 1 / exp alpha=0.05;
run;
%end;
%else %do;
proc phreg data=&data nosummary;
class &exposure &class / param=glm order=internal;
model years*censored(1) = &exposure &class / alpha=0.05 risklimit=wald NODUMMYPRINT;
freq &freq;
strata &id;
by &by;
estimate "'&lbl'"  &exposure -1 1 / exp alpha=0.05;
run;
%end;
%mend est;

/** macro est_spl: Cox regression, adjusted for birth years using natural cubic splines  **/ 
%macro est_spl(data=, out=, class=, spline=, freq=, by=, id=, exposure=, lbl=);
proc sort data=&data; by &by; run;
title1 "ASD among participants - Exposure: &lbl";
title2 "Cox: Adjusted for participant's &class ";
ods output estimates=&out; 
%if &freq=0 %then %do;
proc phreg data=&data nosummary; 
  baseline /method=EMP;
  class  &exposure &class /order=internal;
  effect spl = spline(&spline/ naturalcubic);
  model years * censored(1) = &exposure &class spl/NODUMMYPRINT;
  strata &id;
  by &by;
  estimate "'&lbl'" &exposure -1 1/exp alpha=0.05;
run; 
%end;
%else %do;
proc phreg data=&data nosummary; 
  baseline /method=EMP;
  class  &exposure &class /order=internal;
  effect spl = spline(&spline/ naturalcubic);
  model years * censored(1) = &exposure &class spl/NODUMMYPRINT;
  freq &freq; 
  strata &id;
  by &by;
  estimate "'&lbl'" &exposure -1 1/exp alpha=0.05;
run; 
%end;
%mend est_spl;

/** Bootstrap before aggregation and collapse bootstrapped data, do in patches to save space **/
%macro boot (data=, out=, exp_by=, Npatch=, reps=, temp=);
%do i=1 %to &Npatch;
proc surveyselect data=&data NOPRINT seed=&i
     out=&out(rename=(Replicate=SampleID))
     method=urs              /* resample with replacement */
     samprate=1              /* each bootstrap sample has N observations */
     /*OUTHITS               /* option to suppress the frequency var */
     reps=&reps;               /* generate N bootstrap resample */
run;

proc summary data=&out nway;
var years;
class sampleID child_birth_yr child_sex mom_birth_yr &exp_by outcome exp_ASD exp_AD exp_EXT years censored 
      mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd mom_psych
      exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
freq numberhits;
output out=&out&i n=n;
run;
%if &temp eq 0 %then %do;
data &out&i; set &out&i; sampleID=sampleID+&reps*(&i-1);run;
%end;
%else %do;
data temp.&out&i (compress=yes); set &out&i; sampleID=sampleID+&reps*(&i-1); run;
proc datasets lib=work mt=all nolist;delete &out &out&i; quit;
%end;
%end;
%mend boot;

/** For Paternal side: Bootstrap before aggregation and collapse bootstrapped data, do in patches to save space **/
%macro bootp (data=, out=, exp_by=, Npatch=, reps=, temp=);
%do i=1 %to &Npatch;
proc surveyselect data=&data NOPRINT seed=&i
     out=&out(rename=(Replicate=SampleID))
     method=urs              /* resample with replacement */
     samprate=1              /* each bootstrap sample has N observations */
     /*OUTHITS               /* option to suppress the frequency var */
     reps=&reps;               /* generate N bootstrap resample */
run;

proc summary data=&out nway;
var years;
class sampleID child_birth_yr child_sex dad_birth_yr &exp_by outcome exp_ASD exp_AD exp_EXT years censored 
      dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd dad_psych
      exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
freq numberhits;
output out=&out&i n=n;
run;
%if &temp eq 0 %then %do;
data &out&i; set &out&i; sampleID=sampleID+&reps*(&i-1);run;
%end;
%else %do;
data temp.&out&i (compress=yes); set &out&i; sampleID=sampleID+&reps*(&i-1); run;
proc datasets lib=work mt=all nolist;delete &out &out&i; quit;
%end;
%end;
%mend bootp;

/** macro bootcox: run cox regressions on the bootstrapped datasets (100 patches so far) **/ 
%macro bootcox (data=, coxout=, Npatch=, by=, exposure=, class=, freq=, spline=, id=, lbl=);
%do i=1 %to &Npatch;
data bootcox; set &data&i; run;
proc sort data=bootcox; by &by; run;
title1 "ASD among participants - Exposure: &lbl";
title2 "Cox: Adjusted for participant's &class ";
ods listing close;
ods output estimates=bootout; 
%if &spline=0 %then %do;
proc phreg data=bootcox nosummary;
class &exposure &class / param=glm order=internal;
model years*censored(1) = &exposure &class / alpha=0.05 risklimit=wald NODUMMYPRINT;
freq &freq;
strata &id;
by &by;
estimate "'&lbl'"  &exposure -1 1 / exp alpha=0.05;
run;
%end;
%else %do;
proc phreg data=bootcox nosummary; 
  baseline /method=EMP;
  class  &exposure &class /order=internal;
  effect spl = spline(&spline/ naturalcubic);
  model years * censored(1) = &exposure &class spl/NODUMMYPRINT;
  freq &freq; 
  strata &id;
  by &by;
  estimate "'&lbl'" &exposure -1 1/exp alpha=0.05;
run;
%end;
proc append base=&coxout data=bootout force; run;
ods listing;
proc datasets lib=work mt=data nolist; delete bootcox bootout;
quit;
%end;
data temp.&coxout; set &coxout; run;
%mend bootcox;

/** macro addboot: add bootstrapping 95% CI to the main Cox regression results **/ 
%macro addboot (data=, boot=, by=, out=);
proc sort data=&boot; by &by; run;
proc sort data=&data; by &by; run;
proc univariate data=&boot noprint;
   var estimate;
   output out=Pctl pctlpre =CI95_
          pctlpts =2.5  97.5       /* compute 95% bootstrap confidence interval */
          pctlname=Lower Upper;
   by &by;
run;

data &out;
  drop CI95_Lower CI95_Upper;
  merge &data Pctl;
  by &by;

  bsLower=exp(CI95_Lower);
  bsUpper=exp(CI95_Upper);
  bscitxt = put(expestimate, 4.2) || '(' || put(bslower, 4.2)|| '-' || put(bsupper, 4.2) ||')';
run;
 
proc print data=&out noobs; 
var &by label probz expestimate lowerexp upperexp bslower bsupper bscitxt;
run;
%mend addboot;
