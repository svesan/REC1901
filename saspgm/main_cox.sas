*--------------------------------------------------------------------------------;
* Main analysis: Cox model, on offspring-uncle/aunt pair level                   ;
*--------------------------------------------------------------------------------;
/*
*-2019-03-10: add 'Any mental illness other than ASD';
*-Select data for Cox models;
data cox_masib(label='Cox analysis dataset for aunts and uncles');
  drop exit_dat child_diagdat child_asd death_dat emig_dat mob_dat child_birth_dat masib masib_typ sib_birth_dat father endfu_dat;

  set ana6(where = (masib_typ='Full'));

  years=round(tte/365.25, 0.01);
  censored=0;
  if cens_type in ('D','E','F') then censored=1;
  child_birth_yr=year(child_birth_dat);
  mom_birth_yr=year(mob_dat);
  dad_birth_yr=year(fab_dat);
  sib_birth_yr=year(sib_birth_dat);
  array values exp_ASD exp_ID exp_SCH exp_SPD;
  exp_EXT = max(of values[*]);
run;


data cox_muncle(label='Cox analysis dataset for uncles');
drop exit_dat child_diagdat child_asd death_dat emig_dat mob_dat child_birth_dat masib masib_typ sib_birth_dat father endfu_dat;

set ana6 (where=(masib_typ='Full' and masib_sex=1));

years=round(tte/365.25, 0.01);
censored=0;
if cens_type in ('D','E','F') then censored=1;
child_birth_yr=year(child_birth_dat);
mom_birth_yr=year(mob_dat);
uncle_birth_yr=year(sib_birth_dat);

array values exp_ASD exp_ID exp_SCH exp_SPD;
exp_EXT = max(of values[*]);
run;

data cox_maunt(label='Cox analysis dataset for aunts');
drop exit_dat child_diagdat child_asd death_dat emig_dat mob_dat child_birth_dat masib masib_typ sib_birth_dat father endfu_dat;

set ana6(where=(masib_typ='Full' and masib_sex=2));

years=round(tte/365.25, 0.01);
censored=0;
if cens_type in ('D','E','F') then censored=1;
child_birth_yr=year(child_birth_dat);
mom_birth_yr=year(mob_dat);
aunt_birth_yr=year(sib_birth_dat);

array values exp_ASD exp_ID exp_SCH exp_SPD;
exp_EXT = max(of values[*]);
run;

* Save the datasets in 'temp' folder;
data temp.cox_masib; set cox_masib;run;
data temp.cox_muncle; set cox_muncle; run;
data temp.cox_maunt; set cox_maunt; run; 

data Forbs_masib;
keep child_birth_yr mom_birth_yr sib_birth_yr outcome child_sex exp_ASD exp_AD exp_EXT years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd mom_psych
     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
set temp.cox_masib;
array values exp_ASD exp_ID exp_SCH exp_SPD;
exp_EXT = max(of values[*]);
run;

data Forbs_muncle;
keep child_birth_yr mom_birth_yr uncle_birth_yr outcome child_sex exp_ASD exp_AD exp_EXT years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd mom_psych
     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
set temp.cox_muncle;
array values exp_ASD exp_ID exp_SCH exp_SPD;
exp_EXT = max(of values[*]);
run;

data Forbs_maunt;
keep child_birth_yr mom_birth_yr aunt_birth_yr outcome child_sex exp_ASD exp_AD exp_EXT years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd mom_psych
     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
set temp.cox_maunt;
array values exp_ASD exp_ID exp_SCH exp_SPD;
exp_EXT = max(of values[*]);
run;

data temp.forbs_masib; set forbs_masib;run;
data temp.forbs_muncle; set forbs_muncle;run;
data temp.forbs_maunt; set forbs_maunt;run;

**/

*- Read in data from temp folder;
data cox_masib; set temp.cox_masib; run;
data cox_muncle; set temp.cox_muncle; run;
data cox_maunt; set temp.cox_maunt; run;

**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + mother's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + mother's specific psychs ; 
**-------------------------------------------------------------------------------------;

*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
ods listing close;
%est(data=cox_masib, out=estmasib1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle or Aunt: 0Crude);
%est_spl(data=cox_masib, out=estmasib2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_masib, out=estmasib3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych,freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted2 );
%est_spl(data=cox_masib, out=estmasib4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                 exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted3);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle, out=estmuncle1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle: 0Crude);
%est_spl(data=cox_muncle, out=estmuncle2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, freq=0, by=outcome, lbl=ASD Uncle: Adjusted1);
%est_spl(data=cox_muncle, out=estmuncle3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych, freq=0, by=outcome, lbl=ASD Uncle: Adjusted2);
%est_spl(data=cox_muncle, out=estmuncle4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Uncle: Adjusted3);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt, out=estmaunt1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=1ASD Aunt: 0Crude);
%est_spl(data=cox_maunt, out=estmaunt2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, freq=0, by=outcome, lbl=1ASD Aunt: Adjusted1);
%est_spl(data=cox_maunt, out=estmaunt3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, freq=0, by=outcome, lbl=1ASD Aunt: Adjusted2);
%est_spl(data=cox_maunt, out=estmaunt4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                  exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=1ASD Aunt: Adjusted3);
ods listing;

*- 2019-04-01: save estimates to temp folder;
data temp.estmasib1; set estmasib1; run;
data temp.estmasib2; set estmasib2; run;
data temp.estmasib3; set estmasib3; run;
data temp.estmasib4; set estmasib4; run;
data temp.estmuncle1; set estmuncle1; run;
data temp.estmuncle2; set estmuncle2; run;
data temp.estmuncle3; set estmuncle3; run;
data temp.estmuncle4; set estmuncle4; run;
data temp.estmaunt1; set estmaunt1; run;
data temp.estmaunt2; set estmaunt2; run;
data temp.estmaunt3; set estmaunt3; run;
data temp.estmaunt4; set estmaunt4; run;

*- Combine all estimates in one;
data main_cox_out;
length label $30.;
set estmasib1-estmasib4 estmuncle1-estmuncle4 estmaunt1-estmaunt4;
run;

proc sort data=main_cox_out; by outcome label;run;
proc print data=main_cox_out; var outcome label expestimate lowerexp upperexp; run;

/*- Analysis on collapsed data;
proc summary data=Cox_masib nway;
var years;
class child_birth_yr mom_birth_yr sib_birth_yr outcome exp_ASD years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd
    exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd;
output out=Cox_masib_agg n=n;
run;

%est(data=Cox_masib_agg, out=testout1, freq=_freq_, exposure=exp_ASD, class=, by=outcome, lbl=ASD Uncle or Aunt);*/
