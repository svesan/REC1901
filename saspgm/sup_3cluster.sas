*----------------------------------------------------------------------------------------------------;
* Supplementary analysis                                                                             ;
* Note: 1) The program runs after Cox_main and used the datasets: cox_masib, cox_muncle, cox_maunt   ;
*       2) In Cox model, family cluster is defined as A: offspring of the same mother (id=mother)    ;
*                                                     B: offspring of the same maternal grand parents;    
*----------------------------------------------------------------------------------------------------;

**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + mother's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + mother's specific psychs ; 
**-------------------------------------------------------------------------------------;
/** ID=mother, repeat models a)b)c) with adjustment;

*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
%est(data=cox_masib, out=estmasibca1, exposure=exp_ASD, class=, id=mother, by=outcome, lbl=ASD Uncle or Aunt);
%est_spl(data=cox_masib, out=estmasibca2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, id=mother, by=outcome, lbl=ASD Uncle or Aunt);
%est_spl(data=cox_masib, out=estmasibca3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych,id=mother, by=outcome, lbl=ASD Uncle or Aunt);
%est_spl(data=cox_masib, out=estmasibca4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                 exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         id=mother, by=outcome, lbl=ASD Uncle or Aunt);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle, out=estmuncleca1, exposure=exp_ASD, class=, id=mother, by=outcome, lbl=ASD Uncle);
%est_spl(data=cox_muncle, out=estmuncleca2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, id=mother, by=outcome, lbl=ASD Uncle);
%est_spl(data=cox_muncle, out=estmuncleca3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych,id=mother, by=outcome, lbl=ASD Uncle);
%est_spl(data=cox_muncle, out=estmuncleca4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         id=mother, by=outcome, lbl=ASD Uncle);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt, out=estmauntca1, exposure=exp_ASD, class=, id=mother, by=outcome, lbl=ASD Aunt);
%est_spl(data=cox_maunt, out=estmauntca2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, id=mother, by=outcome, lbl=ASD Aunt);
%est_spl(data=cox_maunt, out=estmauntca3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, id=mother, by=outcome, lbl=ASD Aunt);
%est_spl(data=cox_maunt, out=estmauntca4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                   exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         id=mother, by=outcome, lbl=ASD Aunt);

*/

** ID=MGM MGP, repeat models a)b)c) with adjustment;

*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
%est(data=cox_masib, out=estmasibcb1, exposure=exp_ASD, class=, id=MGM MGP, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Crude);
%est_spl(data=cox_masib, out=estmasibcb2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, id=MGM MGP, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_masib, out=estmasibcb3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych,
         id=MGM MGP, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted2);
%est_spl(data=cox_masib, out=estmasibcb4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                 exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         id=MGM MGP, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted3);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle, out=estmunclecb1, exposure=exp_ASD, class=, id=MGM MGP, freq=0, by=outcome, lbl=ASD Uncle: Crude);
%est_spl(data=cox_muncle, out=estmunclecb2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, id=MGM MGP, freq=0, by=outcome, lbl=ASD Uncle: Adjusted1);
%est_spl(data=cox_muncle, out=estmunclecb3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych,
         id=MGM MGP, freq=0, by=outcome, lbl=ASD Uncle: Adjusted2);
%est_spl(data=cox_muncle, out=estmunclecb4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                       exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         id=MGM MGP, freq=0, by=outcome, lbl=ASD Uncle: Adjusted3);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt, out=estmauntcb1, exposure=exp_ASD, class=, id=MGM MGP, freq=0, by=outcome, lbl=ASD Aunt: Crude);
%est_spl(data=cox_maunt, out=estmauntcb2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, id=MGM MGP, freq=0, by=outcome, lbl=ASD Aunt: Adjusted1);
%est_spl(data=cox_maunt, out=estmauntcb3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, 
         id=MGM MGP, freq=0, by=outcome, lbl=ASD Aunt: Adjusted2);
%est_spl(data=cox_maunt, out=estmauntcb4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                   exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         id=MGM MGP, freq=0, by=outcome, lbl=ASD Aunt: Adjusted3);

*- Combine all estimates in one;
data cluster_cox_out;
length label $40.;
set estmunclecb1-estmunclecb4 estmauntcb1-estmauntcb4 estmasibcb1-estmasibcb4;
run;

proc sort data=cluster_cox_out; by outcome; run;
proc print data=cluster_cox_out; var outcome label expestimate lowerexp upperexp; run;
