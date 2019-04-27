*----------------------------------------------------------------------------------------------------;
* Supplementary analysis                                                                             ;
* Note: 1) The program runs after Cox_main and used the datasets: cox_masib, cox_muncle, cox_maunt   ;
*       2) Macro 'est' and 'est_spl' are required for Cox model                                      ;
*----------------------------------------------------------------------------------------------------;

/*-Create new variable exp_EXT1 and exp_EXT2 as extended exposure on uncle/aunt, including ASD, SCH, ID (and SPD);
proc sql;
create table cox_masib2 as select *, max(exp_ASD,exp_SCH,exp_ID) as exp_EXT1, max(exp_ASD,exp_SCH,exp_ID,exp_SPD) as exp_EXT2 from cox_masib;
create table cox_muncle2 as select *, max(exp_ASD,exp_SCH,exp_ID) as exp_EXT1, max(exp_ASD,exp_SCH,exp_ID,exp_SPD) as exp_EXT2 from cox_muncle;
create table cox_maunt2 as select *, max(exp_ASD,exp_SCH,exp_ID) as exp_EXT1, max(exp_ASD,exp_SCH,exp_ID,exp_SPD) as exp_EXT2 from cox_maunt;
quit;**/

**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + mother's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + mother's specific psychs ; 
**-------------------------------------------------------------------------------------;
*---------------------------------------------------------------------------------------------;
*  2a - Cox model, extended exposure ASD/SCH/ID, on offspring-uncle/aunt pair level           ;
*---------------------------------------------------------------------------------------------;
/**
*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
%est(data=cox_masib2, out=estmasib_exta1, exposure=exp_EXT1, class=, by=outcome, lbl=ASD/SCH/ID Uncle or Aunt);
%est_spl(data=cox_masib2, out=estmasib_exta2, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, by=outcome, lbl=ASD/SCH/ID Uncle or Aunt);
%est_spl(data=cox_masib2, out=estmasib_exta3, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych, by=outcome, lbl=ASD/SCH/ID Uncle or Aunt);
%est_spl(data=cox_masib2, out=estmasib_exta4, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                       exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_spd, 
     by=outcome, lbl=ASD/SCH/ID Uncle or Aunt);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle2, out=estmuncle_exta1, exposure=exp_EXT1, class=, by=outcome, lbl=ASD/SCH/ID Uncle);
%est_spl(data=cox_muncle2, out=estmuncle_exta2, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, by=outcome, lbl=ASD/SCH/ID Uncle);
%est_spl(data=cox_muncle2, out=estmuncle_exta3, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych, by=outcome, lbl=ASD/SCH/ID Uncle);
%est_spl(data=cox_muncle2, out=estmuncle_exta4, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                          exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_spd, 
     by=outcome, lbl=ASD/SCH/ID Uncle);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt2, out=estmaunt_exta1, exposure=exp_EXT1, class=, by=outcome, lbl=ASD/SCH/ID Aunt);
%est_spl(data=cox_maunt2, out=estmaunt_exta2, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, by=outcome, lbl=ASD/SCH/ID Aunt);
%est_spl(data=cox_maunt2, out=estmaunt_exta3, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, by=outcome, lbl=ASD/SCH/ID Aunt);
%est_spl(data=cox_maunt2, out=estmaunt_exta4, exposure=exp_EXT1, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                         exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_spd, 
     by=outcome, lbl=ASD/SCH/ID Aunt);
**/
*---------------------------------------------------------------------------------------------;
*  2a - Cox model, narrowed exposure to AD, on offspring-uncle/aunt pair level                ;
*---------------------------------------------------------------------------------------------;
ods listing close;
*- Exposure AD affected aunt/uncle, by outcome: ASD and AD;
%est(data=cox_masib, out=estmasib_AD1, exposure=exp_AD, class=, freq=0, by=outcome, lbl=AD Uncle or Aunt: 0Crude);
%est_spl(data=cox_masib, out=estmasib_AD2, exposure=exp_AD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0, by=outcome, lbl=AD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_masib, out=estmasib_AD3, exposure=exp_AD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych, 
         freq=0, by=outcome, lbl=AD Uncle or Aunt: Adjusted2);
%est_spl(data=cox_masib, out=estmasib_AD4, exposure=exp_AD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                      exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff, 
         freq=0, by=outcome, lbl=AD Uncle or Aunt: Adjusted3);

*- Exposure AD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle, out=estmuncle_AD1, exposure=exp_AD, class=, freq=0, by=outcome, lbl=1AD Uncle: 0Crude);
%est_spl(data=cox_muncle, out=estmuncle_AD2, exposure=exp_AD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, freq=0, by=outcome, lbl=1AD Uncle: Adjusted1);
%est_spl(data=cox_muncle, out=estmuncle_AD3, exposure=exp_AD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych, 
         freq=0, by=outcome, lbl=1AD Uncle: Adjusted2);
%est_spl(data=cox_muncle, out=estmuncle_AD4, exposure=exp_AD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                          exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff, 
         freq=0, by=outcome, lbl=1AD Uncle: Adjusted3);

*- Exposure AD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt, out=estmaunt_AD1, exposure=exp_AD, class=, freq=0, by=outcome, lbl=AD Aunt: 0Crude);
%est_spl(data=cox_maunt, out=estmaunt_AD2, exposure=exp_AD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, freq=0, by=outcome, lbl=AD Aunt: Adjusted1);
%est_spl(data=cox_maunt, out=estmaunt_AD3, exposure=exp_AD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, 
         freq=0, by=outcome, lbl=AD Aunt: Adjusted2);
%est_spl(data=cox_maunt, out=estmaunt_AD4, exposure=exp_AD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                      exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff, 
         freq=0, by=outcome, lbl=AD Aunt: Adjusted3);
ods listing;

*- 2019-04-01: save estimates to temp folder;
data temp.estmasib_AD1; set estmasib_AD1; run;
data temp.estmasib_AD2; set estmasib_AD2; run;
data temp.estmasib_AD3; set estmasib_AD3; run;
data temp.estmasib_AD4; set estmasib_AD4; run;
data temp.estmuncle_AD1; set estmuncle_AD1; run;
data temp.estmuncle_AD2; set estmuncle_AD2; run;
data temp.estmuncle_AD3; set estmuncle_AD3; run;
data temp.estmuncle_AD4; set estmuncle_AD4; run;
data temp.estmaunt_AD1; set estmaunt_AD1; run;
data temp.estmaunt_AD2; set estmaunt_AD2; run;
data temp.estmaunt_AD3; set estmaunt_AD3; run;
data temp.estmaunt_AD4; set estmaunt_AD4; run;


*- Combine all estimates in one;
data AD_cox_out;
length label $30.;
set estmasib_AD1-estmasib_AD4 estmuncle_AD1-estmuncle_AD4 estmaunt_AD1-estmaunt_AD4;
run;

proc sort data=AD_cox_out; by descending outcome label; run;
proc print data=AD_cox_out; var outcome label expestimate lowerexp upperexp; by descending outcome; run;


*---------------------------------------------------------------------------------------------;
*  2b - Cox model, extended exposure ASD/SCH/ID/PSD, on offspring-uncle/aunt pair level       ;
*---------------------------------------------------------------------------------------------;
ods listing close;
*- Exposure ASD/SCH/ID/SPD affected aunt/uncle, by outcome: ASD and AD;
%est(data=cox_masib, out=estmasib_ext1, exposure=exp_EXT, class=, freq=0, by=outcome, lbl=ASD/SCH/ID/SPD Uncle or Aunt: 0Crude);
%est_spl(data=cox_masib, out=estmasib_ext2, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0, by=outcome, lbl=ASD/SCH/ID/SPD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_masib, out=estmasib_ext3, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych, 
         freq=0, by=outcome, lbl=ASD/SCH/ID/SPD Uncle or Aunt: Adjusted2);
%est_spl(data=cox_masib, out=estmasib_ext4, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                      exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff, 
         freq=0, by=outcome, lbl=ASD/SCH/ID/SPD Uncle or Aunt: Adjusted3);

*- Exposure ASD/SCH/ID/SPD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle, out=estmuncle_ext1, exposure=exp_EXT, class=, freq=0, by=outcome, lbl=1ASD/SCH/ID/SPD Uncle: 0Crude);
%est_spl(data=cox_muncle, out=estmuncle_ext2, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, freq=0, by=outcome, lbl=1ASD/SCH/ID/SPD Uncle: Adjusted1);
%est_spl(data=cox_muncle, out=estmuncle_ext3, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych, 
         freq=0, by=outcome, lbl=1ASD/SCH/ID/SPD Uncle: Adjusted2);
%est_spl(data=cox_muncle, out=estmuncle_ext4, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                          exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff, 
         freq=0, by=outcome, lbl=1ASD/SCH/ID/SPD Uncle: Adjusted3);

*- Exposure ASD/SCH/ID/SPD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt, out=estmaunt_ext1, exposure=exp_EXT, class=, freq=0, by=outcome, lbl=ASD/SCH/ID/SPD Aunt: 0Crude);
%est_spl(data=cox_maunt, out=estmaunt_ext2, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, freq=0, by=outcome, lbl=ASD/SCH/ID/SPD Aunt: Adjusted1);
%est_spl(data=cox_maunt, out=estmaunt_ext3, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, 
         freq=0, by=outcome, lbl=ASD/SCH/ID/SPD Aunt: Adjusted2);
%est_spl(data=cox_maunt, out=estmaunt_ext4, exposure=exp_EXT, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                      exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff, 
         freq=0, by=outcome, lbl=ASD/SCH/ID/SPD Aunt: Adjusted3);
ods listing;


*- 2019-04-01: save estimates to temp folder;
data temp.estmasib_ext1; set estmasib_ext1; run;
data temp.estmasib_ext2; set estmasib_ext2; run;
data temp.estmasib_ext3; set estmasib_ext3; run;
data temp.estmasib_ext4; set estmasib_ext4; run;
data temp.estmuncle_ext1; set estmuncle_ext1; run;
data temp.estmuncle_ext2; set estmuncle_ext2; run;
data temp.estmuncle_ext3; set estmuncle_ext3; run;
data temp.estmuncle_ext4; set estmuncle_ext4; run;
data temp.estmaunt_ext1; set estmaunt_ext1; run;
data temp.estmaunt_ext2; set estmaunt_ext2; run;
data temp.estmaunt_ext3; set estmaunt_ext3; run;
data temp.estmaunt_ext4; set estmaunt_ext4; run;

*- Combine all estimates in one;
data ext_cox_out;
length label $40.;
set estmasib_ext1-estmasib_ext4 estmuncle_ext1-estmuncle_ext4 estmaunt_ext1-estmaunt_ext4;
run;

proc sort data=ext_cox_out; by descending outcome label; run;
proc print data=ext_cox_out; var outcome label expestimate lowerexp upperexp; by descending outcome; run;
