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

/* Create newly defined exposure: maternal genetic load - ASD;
proc sort data=cox_masib; by outcome child descending exp_ASD descending masib_sex; run;
proc sort data=cox_masib out=newexpo0 nodupkey; by outcome child; run;
data newexpo (keep=outcome child child_sex event child_ASD0 cens_type tte years censored child_birth_yr 
                   mother mom_birth_yr mom_ASD mom_AD mom_psych mom_psych2 mom_spd mom_sch mom_aff mom_ADHD mom_com mom_bip mom_sub mom_anx mom_dep mom_id
                   masib_sex exp_ASD NEWEXP_ASD); 
set newexpo0; 
NEWEXP_ASD=0;
if masib_sex=2 and exp_ASD=1 then NEWEXP_ASD=2;
else if masib_sex=1 and exp_ASD=1 then NEWEXP_ASD=1;
run; */

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


**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring) and mother            ;
**            3) Adjusted: 2)+ mother's any psych                                      ;
**            4) *Adjusted: 2)+ mother's specific psychs                               ; 
**-------------------------------------------------------------------------------------;
*--------------------------------------------------------------------------------------------;
*  1 - Exposure AD: Cox model, on offspring individual level, ignore offspring's sex         ;
*--------------------------------------------------------------------------------------------;

ods listing close;
*- Exposure AD affected aunt/uncle, by outcome: ASD and AD;
proc sort data=newexpoAD; by outcome; run;

/* 1) Crude HR */
ods output HazardRatios=HRnewexpo_AD1; 
proc phreg data=newexpoAD nosummary;
class newexp_AD(ref='0')/ param=glm order=internal;
model years*censored(1) = newexp_AD/ alpha=0.05 risklimit=wald;
by outcome;
hazardratio "AD Maternal Genetic Load: Crude" newexp_AD/cl=both;
run;

/*2) Adjusted: birth year of participant (offspring) and mother*/
ods output HazardRatios=HRnewexpo_AD2;
proc phreg data=newexpoAD nosummary; 
  baseline /method=EMP;
  class  newexp_AD(ref='0') child_birth_yr mom_birth_yr / param=glm order=internal;
  effect spl = spline(child_birth_yr mom_birth_yr/ naturalcubic);
  model years * censored(1) =newexp_AD child_birth_yr mom_birth_yr spl/NODUMMYPRINT;
  by outcome;
  hazardratio "AD Maternal Genetic Load: Adjusted 1" newexp_AD/cl=both;
run; 

/* 3) Adjusted: 2)+ mother's any psych  */
ods output HazardRatios=HRnewexpo_AD3;
proc phreg data=newexpoAD nosummary; 
  baseline /method=EMP;
  class  newexp_AD(ref='0') child_birth_yr mom_birth_yr / param=glm order=internal;
  effect spl = spline(child_birth_yr mom_birth_yr mom_psych/ naturalcubic);
  model years * censored(1) =newexp_AD child_birth_yr mom_birth_yr mom_psych spl/NODUMMYPRINT;
  by outcome;
  hazardratio "AD Maternal Genetic Load: Adjusted 2" newexp_AD/cl=both;
run; 
ods listing;

data HRnewexpo_AD;
length label $50 description $50;
set HRnewexpo_AD1-HRnewexpo_AD3;
run;

proc sort data=HRnewexpo_AD; by outcome; run;
data temp.HRnewexpo_AD; set HRnewexpo_AD; run;
proc print data=HRnewexpo_AD;var label description outcome hazardratio waldlower waldupper; run;

*-------------------------------------------------------------------------------------------------------;
*  2 - Exposure ASD/ID/SZ/SPD: Cox model, on offspring individual level, ignore offspring's sex         ;
*-------------------------------------------------------------------------------------------------------;
ods listing close;
*- Exposure ASD/ID/SZ/SPD affected aunt/uncle, by outcome: ASD and AD;
proc sort data=newexpoEXT; by outcome; run;

/* 1) Crude HR */
ods output HazardRatios=HRnewexpo_EXT1; 
proc phreg data=newexpoEXT nosummary;
class newexp_EXT(ref='0')/ param=glm order=internal;
model years*censored(1) = newexp_EXT/ alpha=0.05 risklimit=wald;
by outcome;
hazardratio "ASD/ID/SZ/SPD Maternal Genetic Load: Crude" newexp_EXT/cl=both;
run;

/*2) Adjusted: birth year of participant (offspring) and mother*/
ods output HazardRatios=HRnewexpo_EXT2;
proc phreg data=newexpoEXT nosummary; 
  baseline /method=EMP;
  class  newexp_EXT(ref='0') child_birth_yr mom_birth_yr / param=glm order=internal;
  effect spl = spline(child_birth_yr mom_birth_yr/ naturalcubic);
  model years * censored(1) =newexp_EXT child_birth_yr mom_birth_yr spl/NODUMMYPRINT;
  by outcome;
  hazardratio "ASD/ID/SZ/SPD Maternal Genetic Load: Adjusted 1" newexp_EXT/cl=both;
run; 

/* 3) Adjusted: 2)+ mother's any psych  */
ods output HazardRatios=HRnewexpo_EXT3;
proc phreg data=newexpoEXT nosummary; 
  baseline /method=EMP;
  class  newexp_EXT(ref='0') child_birth_yr mom_birth_yr / param=glm order=internal;
  effect spl = spline(child_birth_yr mom_birth_yr mom_psych/ naturalcubic);
  model years * censored(1) =newexp_EXT child_birth_yr mom_birth_yr mom_psych spl/NODUMMYPRINT;
  by outcome;
  hazardratio "ASD/ID/SZ/SPD Maternal Genetic Load: Adjusted 2" newexp_EXT/cl=both;
run; 
ods listing;

data HRnewexpo_EXT;
length label $50 description $50;
set HRnewexpo_EXT1-HRnewexpo_EXT3;
run;

proc sort data=HRnewexpo_EXT; by outcome; run;
data HRnewexpo_EXT; set swork.HRnewexpo_EXT;run;
data temp.HRnewexpo_EXT; set HRnewexpo_EXT; run;
proc print data=HRnewexpo_EXT;var label description outcome hazardratio waldlower waldupper; run;
