*----------------------------------------------------------------------------------------------------;
* New analysis                                                                                       ;
* Note: 1) The program uses the datasets: cox_masib, cox_muncle, cox_maunt                           ;
*       2) Newly defined REVERSE exposure on family ASD genetic load:                                ; 
*          2: High - Any ASD affected maternal uncle                                                 ;
*          1: Moderate - No ASD affect maternal uncle, but has ASD affected maternal aunt            ;
*          0: Low - With ASD free maternal aunt or uncle                                             ; 
*       3) Analytic unit: participant (offspring), one record for each individual                    ;
*       5) Macro 'est' is required for Cox model                                                     ;
*----------------------------------------------------------------------------------------------------;

* Read in local data;
libname temp 'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\sastmp';
filename saspgm 'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm';

data cox_masib; set temp.cox_masib; run;

proc print data=cox_masib(obs=15);where exp_ASD=1 and masib_sex=1; var outcome child masib_sex exp_ASD;run;
proc print data=cox_masib;where child=10741; var outcome child masib_sex exp_ASD;run;

proc print data=high;where child=10741; run;


* Create newly defined exposure;
proc sort data=cox_masib; by outcome child descending exp_ASD masib_sex; run;
proc sort data=cox_masib out=newexpo_R0 nodupkey; by outcome child; run;
data newexpo_R (keep=outcome child child_sex event child_ASD0 cens_type tte years censored child_birth_yr 
                   mother mom_birth_yr mom_ASD mom_AD mom_psych mom_psych2 mom_spd mom_sch mom_aff mom_ADHD mom_com mom_bip mom_sub mom_anx mom_dep mom_id
                   masib_sex exp_ASD NEWEXP_ASD_R); 
set newexpo_R0; 
NEWEXP_ASD_R=0;
if masib_sex=1 and exp_ASD=1 then NEWEXP_ASD_R=2;
else if masib_sex=2 and exp_ASD=1 then NEWEXP_ASD_R=1;
run; 

/* proc freq data=newexpo_R; tables newexp_ASD_R*masib_sex;run; */

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
proc sort data=newexpo_R; by outcome; run;


ods output HazardRatios=HRnewexpo_R1; * NObs=nob2 censoredsummary=cens2;
proc phreg data=newexpo_R nosummary;
class newexp_ASD_R(ref='0')/ param=glm order=internal;
model years*censored(1) = newexp_ASD_R/ alpha=0.05 risklimit=wald;
by outcome;
hazardratio "Maternal Genetic Load" newexp_ASD_R/cl=both;
run;
proc print data=HRnewexpo_R1;run;

ods output HazardRatios=HRnewexpo_bysex_R1; * NObs=nob2 censoredsummary=cens2;
proc phreg data=newexpo_R nosummary;
class newexp_ASD_R(ref='0') child_sex(ref='Female')/ param=glm order=internal;
model years*censored(1) = newexp_ASD_R|child_sex/ alpha=0.05 risklimit=wald;
by outcome;
hazardratio "Maternal Genetic Load" newexp_ASD_R/cl=both;
run;

ods listing;


proc print data=HRnewexpo_bysex_R1;run;
































*- 2019-04-01: save estimates to temp folder;
data temp.estmasib_bysex1; set estmasib_bysex1; run;
data temp.estmasib_bysex2; set estmasib_bysex2; run;
data temp.estmasib_bysex3; set estmasib_bysex3; run;
data temp.estmasib_bysex4; set estmasib_bysex4; run;
data temp.estmuncle_bysex1; set estmuncle_bysex1; run;
data temp.estmuncle_bysex2; set estmuncle_bysex2; run;
data temp.estmuncle_bysex3; set estmuncle_bysex3; run;
data temp.estmuncle_bysex4; set estmuncle_bysex4; run;
data temp.estmaunt_bysex1; set estmaunt_bysex1; run;
data temp.estmaunt_bysex2; set estmaunt_bysex2; run;
data temp.estmaunt_bysex3; set estmaunt_bysex3; run;
data temp.estmaunt_bysex4; set estmaunt_bysex4; run;

*- Combine all estimates in one;
data bysex_cox_out;
length label $30.;
set estmasib_bysex1-estmasib_bysex4 estmuncle_bysex1-estmuncle_bysex4 estmaunt_bysex1-estmaunt_bysex4;
run;

proc sort data=bysex_cox_out; by descending outcome child_sex label;run;
proc print data=bysex_cox_out; var outcome child_sex label expestimate lowerexp upperexp; by descending outcome; run;

*- 2019-03-19: add sex*EXP_ASD and test interaction;
*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD, in subgroups: male and female participants (offspring);
proc sort data=cox_masib; by outcome child_sex; run;
proc sort data=cox_muncle; by outcome child_sex; run;
proc sort data=cox_maunt; by outcome child_sex; run;

ods listing close;
ods output ParameterEstimates=masib_inter1; 
proc phreg data=cox_masib nosummary;
class exp_ASD (ref='0') child_sex (ref='Female');
model years*censored(1) = exp_ASD|child_sex/ alpha=0.05 risklimit=wald;
by outcome;
run;

ods output ParameterEstimates=masib_inter2; 
proc phreg data=cox_masib nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female');
  effect spl = spline(child_birth_yr mom_birth_yr sib_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr sib_birth_yr exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods output ParameterEstimates=masib_inter3; 
proc phreg data=cox_masib nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female') mom_psych exp_psych;
  effect spl = spline(child_birth_yr mom_birth_yr sib_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr sib_birth_yr mom_psych exp_psych exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods output ParameterEstimates=masib_inter4; 
proc phreg data=cox_masib nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female') mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                   exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd;
  effect spl = spline(child_birth_yr mom_birth_yr sib_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr sib_birth_yr 
                              mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                              exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods output ParameterEstimates=muncle_inter1; 
proc phreg data=cox_muncle nosummary;
class exp_ASD (ref='0') child_sex (ref='Female');
model years*censored(1) = exp_ASD|child_sex/ alpha=0.05 risklimit=wald;
by outcome;
run;

ods output ParameterEstimates=muncle_inter2; 
proc phreg data=cox_muncle nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female');
  effect spl = spline(child_birth_yr mom_birth_yr uncle_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr uncle_birth_yr exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods output ParameterEstimates=muncle_inter3; 
proc phreg data=cox_muncle nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female') mom_psych exp_psych;
  effect spl = spline(child_birth_yr mom_birth_yr uncle_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr uncle_birth_yr mom_psych exp_psych exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods output ParameterEstimates=muncle_inter4; 
proc phreg data=cox_muncle nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female') mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                   exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd;
  effect spl = spline(child_birth_yr mom_birth_yr uncle_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr uncle_birth_yr 
                              mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                              exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods output ParameterEstimates=maunt_inter1; 
proc phreg data=cox_maunt nosummary;
class exp_ASD (ref='0') child_sex (ref='Female');
model years*censored(1) = exp_ASD|child_sex/ alpha=0.05 risklimit=wald;
by outcome;
run;

ods output ParameterEstimates=maunt_inter2; 
proc phreg data=cox_maunt nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female');
  effect spl = spline(child_birth_yr mom_birth_yr aunt_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr aunt_birth_yr exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods output ParameterEstimates=maunt_inter3; 
proc phreg data=cox_maunt nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female') mom_psych exp_psych;
  effect spl = spline(child_birth_yr mom_birth_yr aunt_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr aunt_birth_yr mom_psych exp_psych exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods output ParameterEstimates=maunt_inter4; 
proc phreg data=cox_maunt nosummary; 
  baseline /method=EMP;
  class exp_ASD (ref='0') child_sex (ref='Female') mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                   exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd;
  effect spl = spline(child_birth_yr mom_birth_yr aunt_birth_yr/ naturalcubic);
  model years * censored(1) = child_birth_yr mom_birth_yr aunt_birth_yr 
                              mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                              exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_ASD|child_sex /NODUMMYPRINT;
  by outcome;
run; 

ods listing;

data masib_inter;
keep outcome model parameter estimate stderr chisq probchisq label;
length model $40.;
set masib_inter1(in=masib1 where=(parameter='EXP_ASD*CHILD_SEX')) masib_inter2(in=masib2 where=(parameter='EXP_ASD*CHILD_SEX')) 
    masib_inter3(in=masib3 where=(parameter='EXP_ASD*CHILD_SEX')) masib_inter4(in=masib4 where=(parameter='EXP_ASD*CHILD_SEX'));
if masib1 then model='Crude: uncle/aunt';
else if masib2 then model='Adjusted 1: uncle/aunt';
else if masib3 then model='Adjusted 2: uncle/aunt';
else model='Adjusted 3: uncle/aunt';
run;

proc sort data=masib_inter; by outcome; run;
proc print data=masib_inter; var outcome model parameter estimate probchisq; run;

data muncle_inter;
keep outcome model parameter estimate stderr chisq probchisq label;
length model $40.;
set muncle_inter1(in=muncle1 where=(parameter='EXP_ASD*CHILD_SEX')) muncle_inter2(in=muncle2 where=(parameter='EXP_ASD*CHILD_SEX')) 
    muncle_inter3(in=muncle3 where=(parameter='EXP_ASD*CHILD_SEX')) muncle_inter4(in=muncle4 where=(parameter='EXP_ASD*CHILD_SEX'));
if muncle1 then model='Crude: uncle';
else if muncle2 then model='Adjusted 1: uncle';
else if muncle3 then model='Adjusted 2: uncle';
else model='Adjusted 3: uncle';
run;

proc sort data=muncle_inter; by outcome; run;
proc print data=muncle_inter; var outcome model parameter estimate probchisq; run;

data maunt_inter;
keep outcome model parameter estimate stderr chisq probchisq label;
length model $40.;
set maunt_inter1(in=maunt1 where=(parameter='EXP_ASD*CHILD_SEX')) maunt_inter2(in=maunt2 where=(parameter='EXP_ASD*CHILD_SEX')) 
    maunt_inter3(in=maunt3 where=(parameter='EXP_ASD*CHILD_SEX')) maunt_inter4(in=maunt4 where=(parameter='EXP_ASD*CHILD_SEX'));
if maunt1 then model='Crude: aunt';
else if maunt2 then model='Adjusted 1: aunt';
else if maunt3 then model='Adjusted 2: aunt';
else model='Adjusted 3: aunt';
run;

proc sort data=maunt_inter; by outcome; run;
proc print data=maunt_inter; var outcome model parameter estimate probchisq; run;
