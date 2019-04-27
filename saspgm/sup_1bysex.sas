*----------------------------------------------------------------------------------------------------;
* Supplementary analysis                                                                             ;
* Note: 1) The program runs after Cox_main and used the datasets: cox_masib, cox_muncle, cox_maunt   ;
*       2) Macro 'est' is required for Cox model                                                     ;
*----------------------------------------------------------------------------------------------------;
*-------------------------------------------------------------------------------;
*  1 - Cox model, on offspring-uncle/aunt pair level, by offspring's sex        ;
*-------------------------------------------------------------------------------;
**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + mother's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + mother's specific psychs ; 
**-------------------------------------------------------------------------------------;

ods listing close;
*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD, in subgroups: male and female participants (offspring);

%est(data=cox_masib, out=estmasib_bysex1, exposure=exp_ASD, class=, freq=0, by=child_sex outcome, lbl=ASD Uncle or Aunt: 0Crude);
%est_spl(data=cox_masib, out=estmasib_bysex2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0, by=child_sex outcome, lbl=ASD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_masib, out=estmasib_bysex3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych, 
              freq=0,by=child_sex outcome, lbl=ASD Uncle or Aunt: Adjusted2);
%est_spl(data=cox_masib, out=estmasib_bysex4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                       exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
              freq=0, by=child_sex outcome, lbl=ASD Uncle or Aunt: Adjusted3);

*- Exposure ASD affected uncle, by outcome: ASD and AD, in subgroups: male and female participants (offspring);

%est(data=cox_muncle, out=estmuncle_bysex1, exposure=exp_ASD, class=, freq=0, by=child_sex outcome,lbl=1ASD Uncle: 0Crude);
%est_spl(data=cox_muncle, out=estmuncle_bysex2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, freq=0, by=child_sex outcome, lbl=1ASD Uncle: Adjusted1);
%est_spl(data=cox_muncle, out=estmuncle_bysex3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych, 
         freq=0, by=child_sex outcome, lbl=1ASD Uncle: Adjusted2);
%est_spl(data=cox_muncle, out=estmuncle_bysex4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                           exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=child_sex outcome, lbl=1ASD Uncle: Adjusted3);

*- Exposure ASD affected aunt, by outcome: ASD and AD, in subgroups: male and female participants (offspring);
%est(data=cox_maunt, out=estmaunt_bysex1, exposure=exp_ASD, class=, freq=0, by=child_sex outcome, lbl=ASD Aunt: 0Crude);
%est_spl(data=cox_maunt, out=estmaunt_bysex2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, freq=0, by=child_sex outcome, lbl=ASD Aunt: Adjusted1);
%est_spl(data=cox_maunt, out=estmaunt_bysex3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, 
         freq=0, by=child_sex outcome, lbl=ASD Aunt: Adjusted2);
%est_spl(data=cox_maunt, out=estmaunt_bysex4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                        exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=child_sex outcome, lbl=ASD Aunt: Adjusted3);
ods listing;

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
