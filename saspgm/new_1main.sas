*----------------------------------------------------------------------------------------------------;
* New analysis                                                                                       ;
* Note: 1) The program uses the datasets: cox_masib, cox_muncle, cox_maunt                           ;
*       2) Newly defined exposure on family ASD genetic load:                                        ;
*          2: High - Any ASD affected maternal aunt                                                  ;
*          1: Moderate - No ASD affect maternal aunt, but has ASD affected maternal uncle            ;
*          0: Low - With ASD free maternal aunt or uncle                                             ; 
*       3) Analytic unit: participant (offspring), one record for each individual                    ;
*       5) Macro 'est' is required for Cox model                                                     ;
*----------------------------------------------------------------------------------------------------;
filename saspgm 'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm';

* Read in local data;
libname temp 'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\sastmp';

data cox_masib; set temp.cox_masib; run;

* Create newly defined exposure: maternal genetic load - ASD;
proc sort data=cox_masib; by outcome child descending exp_ASD descending masib_sex; run;
proc sort data=cox_masib out=newexpo0 nodupkey; by outcome child; run;
data newexpo (keep=outcome child child_sex event child_ASD0 cens_type tte years censored child_birth_yr 
                   mother mom_birth_yr mom_ASD mom_AD mom_psych mom_psych2 mom_spd mom_sch mom_aff mom_ADHD mom_com mom_bip mom_sub mom_anx mom_dep mom_id
                   masib_sex exp_ASD NEWEXP_ASD); 
set newexpo0; 
NEWEXP_ASD=0;
if masib_sex=2 and exp_ASD=1 then NEWEXP_ASD=2;
else if masib_sex=1 and exp_ASD=1 then NEWEXP_ASD=1;
run; 

* Create newly defined exposure: maternal genetic load - AD;
proc sort data=cox_masib; by outcome child descending exp_AD descending masib_sex; run;
proc sort data=cox_masib out=newexpoAD0 nodupkey; by outcome child; run;
data newexpoAD (keep=outcome child child_sex event child_ASD0 cens_type tte years censored child_birth_yr 
                   mother mom_birth_yr mom_ASD mom_AD mom_psych mom_psych2 mom_spd mom_sch mom_aff mom_ADHD mom_com mom_bip mom_sub mom_anx mom_dep mom_id
                   masib_sex exp_AD NEWEXP_AD); 
set newexpoAD0; 
NEWEXP_AD=0;
if masib_sex=2 and exp_AD=1 then NEWEXP_AD=2;
else if masib_sex=1 and exp_AD=1 then NEWEXP_AD=1;
run; 

* Create newly defined exposure: maternal genetic load - ASD/ID/SZ/SPD;
proc sort data=cox_masib; by outcome child descending exp_EXT descending masib_sex; run;
proc sort data=cox_masib out=newexpoEXT0 nodupkey; by outcome child; run;
data newexpoEXT (keep=outcome child child_sex event child_ASD0 cens_type tte years censored child_birth_yr 
                   mother mom_birth_yr mom_ASD mom_AD mom_psych mom_psych2 mom_spd mom_sch mom_aff mom_ADHD mom_com mom_bip mom_sub mom_anx mom_dep mom_id
                   masib_sex exp_EXT NEWEXP_EXT); 
set newexpoEXT0; 
NEWEXP_EXT=0;
if masib_sex=2 and exp_EXT=1 then NEWEXP_EXT=2;
else if masib_sex=1 and exp_EXT=1 then NEWEXP_EXT=1;
run; 


/* proc freq data=newexpo; tables newexp_ASD*masib_sex;run;
   proc freq data=newexpoAD; tables newexp_AD*masib_sex;run;
   proc freq data=newexpoEXT; tables newexp_EXT*masib_sex;run;*/

*-------------------------------------------------------------------------------;
*  1 - Cox model, on offspring individual level, ignore offspring's sex         ;
*-------------------------------------------------------------------------------;
**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring) and mother            ;
**            3) Adjusted: 2)+ mother's any psych                                      ;
**            4) *Adjusted: 2)+ mother's specific psychs                               ; 
**-------------------------------------------------------------------------------------;

ods listing close;
*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
proc sort data=newexpo; by outcome; run;

/* 1) Crude HR */
ods output HazardRatios=HRnewexpo1; 
proc phreg data=newexpo nosummary;
class newexp_ASD(ref='0')/ param=glm order=internal;
model years*censored(1) = newexp_ASD/ alpha=0.05 risklimit=wald;
by outcome;
hazardratio "Maternal Genetic Load: Crude" newexp_ASD/cl=both;
run;

/*2) Adjusted: birth year of participant (offspring) and mother*/
ods output HazardRatios=HRnewexpo2;
proc phreg data=newexpo nosummary; 
  baseline /method=EMP;
  class  newexp_ASD(ref='0') child_birth_yr mom_birth_yr / param=glm order=internal;
  effect spl = spline(child_birth_yr mom_birth_yr/ naturalcubic);
  model years * censored(1) =newexp_ASD child_birth_yr mom_birth_yr spl/NODUMMYPRINT;
  by outcome;
  hazardratio "Maternal Genetic Load: Adjusted 1" newexp_ASD/cl=both;
run; 

/* 3) Adjusted: 2)+ mother's any psych  */
ods output HazardRatios=HRnewexpo3;
proc phreg data=newexpo nosummary; 
  baseline /method=EMP;
  class  newexp_ASD(ref='0') child_birth_yr mom_birth_yr / param=glm order=internal;
  effect spl = spline(child_birth_yr mom_birth_yr mom_psych/ naturalcubic);
  model years * censored(1) =newexp_ASD child_birth_yr mom_birth_yr mom_psych spl/NODUMMYPRINT;
  by outcome;
  hazardratio "Maternal Genetic Load: Adjusted 2" newexp_ASD/cl=both;
run; 

proc print data=HRnewexpo2;run;


/* With interaction term: child's sex */ 
/* 1) Crude HR */
ods output HazardRatios=HRnewexpo_bysex1; 
proc phreg data=newexpo nosummary;
class newexp_ASD(ref='0') child_sex(ref='Female')/ param=glm order=internal;
model years*censored(1) = newexp_ASD|child_sex/ alpha=0.05 risklimit=wald;
by outcome;
hazardratio "Maternal Genetic Load" newexp_ASD/cl=both;
hazardratio "Sex" child_sex/cl=both;
run;


/*2) Adjusted: birth year of participant (offspring) and mother*/
ods output HazardRatios=HRnewexpo_bysex2;
proc phreg data=newexpo nosummary; 
  baseline /method=EMP;
  class  newexp_ASD(ref='0') child_birth_yr mom_birth_yr child_sex(ref='Female')/ param=glm order=internal;
  effect spl = spline(child_birth_yr mom_birth_yr/ naturalcubic);
  model years * censored(1) =newexp_ASD|child_sex child_birth_yr mom_birth_yr spl/NODUMMYPRINT;
  by outcome;
  hazardratio "Maternal Genetic Load: Adjusted 1" newexp_ASD/cl=both;
  hazardratio "Sex" child_sex/cl=both;
run; 

/* 3) Adjusted: 2)+ mother's any psych  */
ods output HazardRatios=HRnewexpo_bysex3;
proc phreg data=newexpo nosummary; 
  baseline /method=EMP;
  class  newexp_ASD(ref='0') child_sex(ref='Female') child_birth_yr mom_birth_yr / param=glm order=internal;
  effect spl = spline(child_birth_yr mom_birth_yr mom_psych/ naturalcubic);
  model years * censored(1) =newexp_ASD|child_sex child_birth_yr mom_birth_yr mom_psych spl/NODUMMYPRINT;
  by outcome;
  hazardratio "Maternal Genetic Load: Adjusted 2" newexp_ASD/cl=both;
  hazardratio "Sex" child_sex/cl=both;
run; 

data HRnewexpo_bysex3;
set swork.HRnewexpo_bysex3;
run;

data HRnewexpo;
length label $50 description $50;
set HRnewexpo1-HRnewexpo3 HRnewexpo_bysex1-HRnewexpo_bysex3;
run;

proc sort data=HRnewexpo; by outcome; run;
data temp.HRnewexpo; set HRnewexpo; run;
proc print data=HRnewexpo;var label description outcome hazardratio waldlower waldupper; run;

/* Calculate person-years and ASD/AD rate by new exposure: maternal genetic load - ASD */
proc sort data=newexpo; by outcome newexp_ASD; run;
ods output summary=personyr_newASD;
proc means data=newexpo sum;
class newexp_ASD;
var years event;
by outcome newexp_ASD;
run;
/* Calculate person-years and ASD/AD rate by new exposure: maternal genetic load - AD */
proc sort data=newexpoAD; by outcome newexp_AD; run;
ods output summary=personyr_newAD;
proc means data=newexpoAD sum;
class newexp_AD;
var years event;
by outcome newexp_AD;
run;
/* Calculate person-years and ASD/AD rate by new exposure: maternal genetic load - ASD/ID/SX/SPD */
proc sort data=newexpoEXT; by outcome newexp_EXT; run;
ods output summary=personyr_newEXT;
proc means data=newexpoEXT sum;
class newexp_EXT;
var years event;
by outcome newexp_EXT;
run;

data personyr_newexp;
drop vname_years vname_event ;
length exposure $40.;
set personyr_newASD(in=personyr_newASD rename=(newexp_ASD=exposed) drop=newexp_ASD2) 
    personyr_newAD(in=personyr_newAD rename=(newexp_AD=exposed) drop=newexp_AD2)
    personyr_newEXT(in=personyr_newEXT rename=(newexp_EXT=exposed) drop=newexp_EXT2);
if personyr_newASD then exposure='Maternal genetic load: ASD';
else if personyr_newAD then exposure='Maternal genetic load: AD';
else if personyr_newEXT then exposure='Maternal genetic load: ASD/ID/SZ/SPD';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

proc sort data=personyr_newexp; by outcome; run;
proc print data=personyr_newexp; run;

/*KM-curve by newly defined exposure*/
proc lifetest data=newexpo(where=(outcome='ASD')) NOTABLE outsurv=surv1;
time years*censored(1);
strata newexp_ASD;
run;

data surv2;
 set surv1;
 survival = 1-survival;
 sdf_lcl=1-sdf_lcl;
 sdf_ucl=1-sdf_ucl;
 label newexp_ASD="Maternal Genetic Load";
run;

ods graphics on / outputfmt=png;
title "Reverse Kaplan Meier Curve for Offspring's ASD Probability"; 
proc gplot data=surv2 ;
axis1 order=0 to 0.03 by 0.005 minor=none label=(a=90 "Probability of ASD");
axis2 minor=none label=('Follow-up Time (Years)');
legend1 mode=protect position=(inside left top);
symbol1 c=green  i=join v=none w=2 l=1;
symbol2 c=blue i=join v=none w=2 l=1;
symbol3 c=red i=join v=none w=2 l=1;
plot survival*years=newexp_ASD 
/vaxis=axis1 haxis=axis2 legend=legend1;
format newexp_ASD MGload.;
run;
ods graphics off;

/*KM-curve by newly defined exposure and by sex*/
proc sort data=newexpo; by outcome child_sex newexp_ASD;run;
proc lifetest data=newexpo(where=(outcome='ASD')) NOTABLE outsurv=surv_bysex1;
time years*censored(1);
strata newexp_ASD child_sex;
run;
proc sort data=surv_bysex1; by child_sex newexp_ASD;run;

data surv_bysex2;
 set surv_bysex1;
 survival = 1-survival;
 sdf_lcl=1-sdf_lcl;
 sdf_ucl=1-sdf_ucl;
 exp_ASD_bysex='Reference-Female';
 if newexp_ASD=2 and child_sex=1 then exp_ASD_bysex='High-Male';
 else if newexp_ASD=2 and child_sex=2 then exp_ASD_bysex='High-Female';
 else if newexp_ASD=1 and child_sex=1 then exp_ASD_bysex='Moderate-Male';
 else if newexp_ASD=1 and child_sex=2 then exp_ASD_bysex='Moderate-Female';
 else if newexp_ASD=0 and child_sex=1 then exp_ASD_bysex='Reference-Male';
 label newexp_ASD="Maternal Genetic Load"
       exp_ASD_bysex="Maternal Genetic Load by Offspring's Sex";
run;

proc freq data=surv_bysex2; tables newexp_ASD*exp_ASD_bysex/missing; run; 

ods graphics on / outputfmt=png;
title "Reverse Kaplan Meier Curve for Offspring's ASD Probability"; 
proc gplot data=surv_bysex2 ;
axis1 order=0 to 0.10 by 0.005 minor=none label=(a=90 "Probability of ASD");
axis2 minor=none label=('Follow-up Time (Years)');
legend1 mode=protect position=(inside left top);
symbol1 c=LIPK i=join v=none w=2 l=1;
symbol2 c=VIPK i=join v=none w=2 l=1;
symbol3 c=VLIGB  i=join v=none w=2 l=1;
symbol4 c=BIGB  i=join v=none w=2 l=1;
symbol5 c=VLIYG i=join v=none w=2 l=1;
symbol6 c=VIYG  i=join v=none w=2 l=1;
plot survival*years=exp_ASD_bysex/vaxis=axis1 haxis=axis2 legend=legend1;
run;
ods graphics off;

/*Plot by child's sex */
ods graphics on / outputfmt=png;
title "Reverse Kaplan Meier Curve for Offspring's ASD Probability: Male offspring"; 
proc gplot data=surv_bysex2(where=(child_sex=1)) ;
axis1 order=0 to 0.10 by 0.005 minor=none label=(a=90 "Probability of ASD");
axis2 minor=none label=('Follow-up Time (Years)');
legend1 mode=protect position=(inside left top);
symbol1 c=green  i=join v=none w=2 l=1;
symbol2 c=blue i=join v=none w=2 l=1;
symbol3 c=red i=join v=none w=2 l=1;
plot survival*years=newexp_ASD/vaxis=axis1 haxis=axis2 legend=legend1;
format newexp_ASD MGload.;
run;

title "Reverse Kaplan Meier Curve for Offspring's ASD Probability: Female offspring"; 
proc gplot data=surv_bysex2(where=(child_sex=2)) ;
axis1 order=0 to 0.03 by 0.005 minor=none label=(a=90 "Probability of ASD");
axis2 minor=none label=('Follow-up Time (Years)');
legend1 mode=protect position=(inside left top);
symbol1 c=green  i=join v=none w=2 l=1;
symbol2 c=blue i=join v=none w=2 l=1;
symbol3 c=red i=join v=none w=2 l=1;
plot survival*years=newexp_ASD/vaxis=axis1 haxis=axis2 legend=legend1;
format newexp_ASD MGload. child_sex sexfmt.;
run;
ods graphics off;

/* Has to run on Matrix, desktop SAS will collapse */
ods graphics on / outputfmt=png;
title1 "Reverse Kaplan Meier Curve for Offspring's ASD Probability: by Sex";
proc sgpanel data=surv_bysex2 noautolegend ;
ods html gpath='.' image_dpi=200 ;
  label survival='ASD Probability'
        years='Follow-up Time (Years)';
  panelby exp_ASD_bysex / columns=2 rows=3 novarname;
  series x=years y=survival  / lineattrs=GraphFit;
  series x=years y=sdf_lcl / lineattrs=(pattern=2 color=darkgray);
  series x=years y=sdf_ucl / lineattrs=(pattern=2 color=darkgray);
  rowaxis max=0.03 min=0 refticks=(values) grid;
  colaxis min=0 max=17;
run;
ods graphics off;


