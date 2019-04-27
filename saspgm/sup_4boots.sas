*----------------------------------------------------------------------------------------------------;
* Supplementary analysis                                                                             ;
* Note: 1) The program runs after Cox_main and used the datasets: cox_masib, cox_muncle, cox_maunt   ;
*       2) Boot straping is conducted at pair (row) level                                            ;
*----------------------------------------------------------------------------------------------------;

**-------------------------------------------------------------------------------------;
**                                Maternal Uncle or Aunt                               ;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + mother's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + mother's specific psychs ; 
**-------------------------------------------------------------------------------------;

data Forbs_masib;
keep child_birth_yr mom_birth_yr sib_birth_yr outcome exp_ASD exp_AD years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd mom_psych
     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
set cox_masib;
run;

data Forbs_muncle;
keep child_birth_yr mom_birth_yr uncle_birth_yr outcome exp_ASD exp_AD years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd mom_psych
     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
set cox_muncle;
run;

data Forbs_maunt;
keep child_birth_yr mom_birth_yr aunt_birth_yr outcome exp_ASD exp_AD years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd mom_psych
     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
set cox_maunt;
run;

* Boottrap in patches and save to '/nfs/projects/0RECAP/REC/REC1901/temp';
%boot(data=forbs_masib,out=agg_masib_boot,exp_by=sib_birth_yr, Npatch=10,reps=100); /*Bootstrap and aggregate 10 patches, each 100 resamples, total 1000 resamples*/

%boot(data=forbs_muncle,out=agg_muncle_boot,exp_by=uncle_birth_yr, Npatch=10,reps=100); /*Bootstrap and aggregate 10 patches, each 100 resamples, total 1000 resamples*/

%boot(data=forbs_maunt,out=agg_maunt_boot,exp_by=aunt_birth_yr, Npatch=10,reps=100); /*Bootstrap and aggregate 10 patches, each 100 resamples, total 1000 resamples*/


data test;
set temp.agg_masib_boot1;
run;

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

/** Main Cox Regressions: 12*2RRs- Crude, Adjusted1, Adjusted2, Adjusted3 for maternal uncle, maternal aunt, and maternal aunt/uncle, by outcome AD/ASD **/
**-Maternal uncle;
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_boot1, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Uncle Crude);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_boot2, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD Uncle Adjust1);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_boot3, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD Uncle Adjust2);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_boot4, Npatch=100, by=sampleID outcome, exposure=exp_ASD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD Uncle Adjust3);

**-Maternal aunt;
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_boot1, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Aunt Crude);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_boot2, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD Aunt Adjust1);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_boot3, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD Aunt Adjust2);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_boot4, Npatch=100, by=sampleID outcome, exposure=exp_ASD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD Aunt Adjust3);

**-Maternal uncle/aunt;
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_boot1, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Uncle/Aunt Crude);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_boot2, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust1);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_boot3, Npatch=100, by=sampleID outcome, exposure=exp_ASD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust2);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_boot4, Npatch=100, by=sampleID outcome, exposure=exp_ASD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust3);


/** Main Cox Regressions: 12*2RRs- Crude, Adjusted1, Adjusted2, Adjusted3 for maternal uncle, maternal aunt, and maternal aunt/uncle, by outcome AD/ASD, by sex **/
**-Maternal uncle;
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_bysex_boot1, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Uncle Crude);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_bysex_boot2, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD Uncle Adjust1);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_bysex_boot3, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD Uncle Adjust2);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_bysex_boot4, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD Uncle Adjust3);

**-Maternal aunt;
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_bysex_boot1, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Aunt Crude);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_bysex_boot2, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD Aunt Adjust1);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_bysex_boot3, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD Aunt Adjust2);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_bysex_boot4, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD Aunt Adjust3);

**-Maternal uncle/aunt;
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_bysex_boot1, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Uncle/Aunt Crude);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_bysex_boot2, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust1);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_bysex_boot3, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust2);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_bysex_boot4, Npatch=100, by=child_sex sampleID outcome, exposure=exp_ASD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust3);

/** Main Cox Regressions: 12RRs-Crude, Adjusted1, Adjusted2, Adjusted3 for maternal uncle, maternal aunt, and maternal aunt/uncle, by outcome AD/ASD
		                        exposure changed to exp_AD                                                                                   **/
**-Maternal uncle;
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_ad_boot1, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=, freq=n, spline=0, id=, lbl=AD Uncle Crude);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_ad_boot2, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=AD Uncle Adjust1);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_ad_boot3, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=AD Uncle Adjust2);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_ad_boot4, Npatch=100, by=sampleID outcome, exposure=exp_AD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=AD Uncle Adjust3);

**-Maternal aunt;
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_ad_boot1, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=, freq=n, spline=0, id=, lbl=AD Aunt Crude);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_ad_boot2, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=AD Aunt Adjust1);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_ad_boot3, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=AD Aunt Adjust2);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_ad_boot4, Npatch=100, by=sampleID outcome, exposure=exp_AD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=AD Aunt Adjust3);

**-Maternal uncle/aunt;
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_ad_boot1, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=, freq=n, spline=0, id=, lbl=AD Uncle/Aunt Crude);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_ad_boot2, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=AD Uncle/Aunt Adjust1);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_ad_boot3, Npatch=100, by=sampleID outcome, exposure=exp_AD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=AD Uncle/Aunt Adjust2);
%bootcox(data=temp.agg_masib_boot, coxout=estmasib_ad_boot4, Npatch=100, by=sampleID outcome, exposure=exp_AD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=AD Uncle/Aunt Adjust3);











%macro addboot (data=, boot=);
proc sort data=&boot; by outcome; run;
proc sort data=&data; by outcome; run;
proc univariate data=&boot noprint;
   var estimate;
   output out=Pctl pctlpre =CI95_
          pctlpts =2.5  97.5       /* compute 95% bootstrap confidence interval */
          pctlname=Lower Upper;
   by outcome;
run;

data &data;
  drop CI95_Lower CI95_Upper;
  merge &data Pctl;
  by outcome;

  bsLower=exp(CI95_Lower);
  bsUpper=exp(CI95_Upper);
  bscitxt = put(expestimate, 4.2) || '(' || put(bslower, 4.2)|| '-' || put(bsupper, 4.2) ||')';
run;
 
proc print data=&data noobs; 
var outcome label probz expestimate lowerexp upperexp bslower bsupper;
run;
%mend addboot;








proc summary data=boot_masib_test nway;
var years;
class sampleID child_birth_yr mom_birth_yr sib_birth_yr outcome exp_ASD years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd
      exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd;
output out=Boot_masib_agg0 n=n;
run;

data Boot_masib_agg1;
drop _freq_ n _type_ numberhits;
set boot_masib_agg0;
T_freq=n*numberhits;
run;

proc summary data=boot_muncle nway;
var years;
class sampleID numberhits child_birth_yr mom_birth_yr uncle_birth_yr outcome exp_ASD years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd
      exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd;
output out=Boot_muncle_agg0 n=n;
run;

data Boot_muncle_agg1;
drop _freq_ n _type_ numberhits;
set boot_muncle_agg0;
T_freq=n*numberhits;
run;

proc summary data=boot_maunt nway;
var years;
class sampleID numberhits outcome child_birth_yr mom_birth_yr aunt_birth_yr exp_ASD years censored mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd
      exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd;
output out=Boot_maunt_agg0 n=n;
run;
data Boot_maunt_agg1;
drop _freq_ n _type_ numberhits;
set boot_maunt_agg0;
T_freq=n*numberhits;
run;



data out.Boot_masib_agg; set Boot_masib_agg1; run;
data out.Boot_muncle_agg; set Boot_muncle_agg1; run;
data out.Boot_maunt_agg; set Boot_maunt_agg1; run;

*Delete boot_masib;
proc datasets lib=work mt=all nolist;delete boot_masib boot_muncle boot_maunt; quit;


%est(data=Bootdata, out=BootEst1a, exposure=exp_ASD, class=, id=, spline=&spline, by=sampleID outcome, lbl=&label);
%est(data=Bootdata, out=BootEst2a, exposure=exp_ASD, class=, id=, spline=&spline, by=outcome, lbl=&label);
%est(data=Bootdata, out=BootEst3a, exposure=exp_ASD, class=mom_psych exp_psych, spline=&spline, by=outcome, lbl=&label);
%est(data=Bootdata, out=BootEst4a, exposure=exp_ASD, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                           exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
     spline=&spline, by=outcome, lbl=&label);


%doboot(Npatch=1,data=Cox_masib,estout=estmasib_bs, spline=child_birth_yr mom_birth_yr sib_birth_yr, label=ASD Uncle or Aunt);

title "Bootstrap Distribution"; /*Plot for maternal uncle or aunt: crude ASD HR only */
proc sgplot data=estmasib_bs1(where=(outcome='ASD'));
   label expestimate= 'Hazard Ratio';
   histogram expestimate;
   /* Optional: draw reference line at observed value and draw 95% CI */
   refline  2.7355/ axis=x lineattrs=(color=red) 
                  name="HR" legendlabel="Observed Hazard = 2.7355";
   refline  2.1770 3.4374  / axis=x lineattrs=(color=blue) 
                  name="CI" legendlabel="95% CI";
   keylegend "HR" "CI";
run;

%addboot (data=estmasib1, boot=estmasib_bs1);
%addboot (data=estmasib2, boot=estmasib_bs2);
%addboot (data=estmasib3, boot=estmasib_bs3);
%addboot (data=estmasib4, boot=estmasib_bs4);

** Delete bootstrapped data after use;
proc datasets lib=work mt=data nolist;
delete Bootdata Bootest1a Bootest2a Bootest3a Bootest4a Pctl;
quit;


**-------------------------------------------------------------------------------------;
**                                Maternal Uncle                                       ;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle        ;
**            3) Adjusted: 2)+ uncle's any psych + mother's any psych                  ;
**            4) Adjusted: 2)+ uncle's specific psychs + mother's specific psychs      ; 
**-------------------------------------------------------------------------------------;

%doboot(Npatch=100,data=Cox_muncle,estout=estmuncle_bs, spline=child_birth_yr mom_birth_yr uncle_birth_yr,  label=ASD Uncle);
%addboot (data=estmuncle1, boot=estmuncle_bs1);
%addboot (data=estmuncle2, boot=estmuncle_bs2);
%addboot (data=estmuncle3, boot=estmuncle_bs3);
%addboot (data=estmuncle4, boot=estmuncle_bs4);

** Delete bootstrapped data after use;
proc datasets lib=work mt=data nolist;
delete Bootdata Bootest1a Bootest2a Bootest3a Bootest4a Pctl;
quit;

**-------------------------------------------------------------------------------------;
**                                Maternal Aunt                                        ;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, aunt         ;
**            3) Adjusted: 2)+ aunt's any psych + mother's any psych                   ;
**            4) Adjusted: 2)+ aunt's specific psychs + mother's specific psychs       ; 
**-------------------------------------------------------------------------------------;
%doboot(Npatch=100,data=Cox_maunt,estout=estmaunt_bs, spline=child_birth_yr mom_birth_yr aunt_birth_yr, label=ASD Aunt);
%addboot (data=estmaunt1, boot=estmaunt_bs1);
%addboot (data=estmaunt2, boot=estmaunt_bs2);
%addboot (data=estmaunt3, boot=estmaunt_bs3);
%addboot (data=estmaunt4, boot=estmaunt_bs4);

** Delete bootstrapped data after use;
proc datasets lib=work mt=data nolist;
delete Bootdata Bootest1a Bootest2a Bootest3a Bootest4a Pctl;
quit;

*- Combine all estimates in one;
data boot_cox_out;
set estmasib1-estmasib4 estmuncle1-estmuncle4 estmaunt1-estmaunt4;
run;
