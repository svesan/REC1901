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
/** 
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

* Boottrap in patches and save to '/nfs/projects/0RECAP/REC/REC1901/temp';
/**

%boot(data=forbs_masib,out=agg_masib_boot,exp_by=sib_birth_yr, Npatch=10,reps=100); /*Bootstrap and aggregate 10 patches, each 100 resamples, total 1000 resamples*/

%boot(data=forbs_muncle,out=agg_muncle_boot,exp_by=uncle_birth_yr, Npatch=100,reps=10); /*Bootstrap and aggregate 100 patches, each 10 resamples, total 1000 resamples*/

%boot(data=forbs_maunt,out=agg_maunt_boot,exp_by=aunt_birth_yr, Npatch=100,reps=10); /*Bootstrap and aggregate 100 patches, each 10 resamples, total 1000 resamples*/

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


/** 2019-03-26: bootstrap for masib, on Matrix work lib, not saved in temp folder **/
/*data forbs_masib; set temp.forbs_masib;run;*/

%boot(data=forbs_masib,out=agg_masib_boot,exp_by=sib_birth_yr, Npatch=10,reps=100,temp=0); /*Bootstrap and aggregate 10 patches, each 100 resamples, total 1000 resamples*/

**-Maternal uncle/aunt;
%bootcox(data=agg_masib_boot, coxout=estmasib_boot1, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Uncle/Aunt Crude);
%bootcox(data=agg_masib_boot, coxout=estmasib_boot2, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust1);
%bootcox(data=agg_masib_boot, coxout=estmasib_boot3, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust2);
%bootcox(data=agg_masib_boot, coxout=estmasib_boot4, Npatch=10, by=sampleID outcome, exposure=exp_ASD, freq=n,
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
%bootcox(data=agg_masib_boot, coxout=estmasib_bysex_boot1, Npatch=10, by=child_sex sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Uncle/Aunt Crude);
%bootcox(data=agg_masib_boot, coxout=estmasib_bysex_boot2, Npatch=10, by=child_sex sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust1);
%bootcox(data=agg_masib_boot, coxout=estmasib_bysex_boot3, Npatch=10, by=child_sex sampleID outcome, exposure=exp_ASD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD Uncle/Aunt Adjust2);
%bootcox(data=agg_masib_boot, coxout=estmasib_bysex_boot4, Npatch=10, by=child_sex sampleID outcome, exposure=exp_ASD, freq=n,
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
%bootcox(data=agg_masib_boot, coxout=estmasib_ad_boot1, Npatch=10, by=sampleID outcome, exposure=exp_AD, class=, freq=n, spline=0, id=, lbl=AD Uncle/Aunt Crude);
%bootcox(data=agg_masib_boot, coxout=estmasib_ad_boot2, Npatch=10, by=sampleID outcome, exposure=exp_AD, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=AD Uncle/Aunt Adjust1);
%bootcox(data=agg_masib_boot, coxout=estmasib_ad_boot3, Npatch=10, by=sampleID outcome, exposure=exp_AD, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=AD Uncle/Aunt Adjust2);
%bootcox(data=agg_masib_boot, coxout=estmasib_ad_boot4, Npatch=10, by=sampleID outcome, exposure=exp_AD, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=AD Uncle/Aunt Adjust3);

/** Main Cox Regressions: 12RRs-Crude, Adjusted1, Adjusted2, Adjusted3 for maternal uncle, maternal aunt, and maternal aunt/uncle, by outcome AD/ASD
		                        exposure changed to exp_EXT                                                                                   **/
**-Maternal uncle;
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_ext_boot1, Npatch=100, by=sampleID outcome, exposure=exp_EXT, class=, freq=n, spline=0, id=, lbl=ASD/ID/SCH/SPD Uncle Crude);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_ext_boot2, Npatch=100, by=sampleID outcome, exposure=exp_EXT, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Uncle Adjust1);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_ext_boot3, Npatch=100, by=sampleID outcome, exposure=exp_EXT, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Uncle Adjust2);
%bootcox(data=temp.agg_muncle_boot, coxout=estmuncle_ext_boot4, Npatch=100, by=sampleID outcome, exposure=exp_EXT, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff,  
         spline=child_birth_yr mom_birth_yr uncle_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Uncle Adjust3);

**-Maternal aunt;
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_ext_boot1, Npatch=100, by=sampleID outcome, exposure=exp_EXT, class=, freq=n, spline=0, id=, lbl=ASD/ID/SCH/SPD Aunt Crude);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_ext_boot2, Npatch=100, by=sampleID outcome, exposure=exp_EXT, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Aunt Adjust1);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_ext_boot3, Npatch=100, by=sampleID outcome, exposure=exp_EXT, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Aunt Adjust2);
%bootcox(data=temp.agg_maunt_boot, coxout=estmaunt_ext_boot4, Npatch=100, by=sampleID outcome, exposure=exp_EXT, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff,  
         spline=child_birth_yr mom_birth_yr aunt_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Aunt Adjust3);

**-Maternal uncle/aunt;
%bootcox(data=agg_masib_boot, coxout=estmasib_ext_boot1, Npatch=10, by=sampleID outcome, exposure=exp_EXT, class=, freq=n, spline=0, id=, lbl=ASD/ID/SCH/SPD Uncle/Aunt Crude);
%bootcox(data=agg_masib_boot, coxout=estmasib_ext_boot2, Npatch=10, by=sampleID outcome, exposure=exp_EXT, class=, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Uncle/Aunt Adjust1);
%bootcox(data=agg_masib_boot, coxout=estmasib_ext_boot3, Npatch=10, by=sampleID outcome, exposure=exp_EXT, class=mom_psych exp_psych, freq=n, 
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Uncle/Aunt Adjust2);
%bootcox(data=agg_masib_boot, coxout=estmasib_ext_boot4, Npatch=10, by=sampleID outcome, exposure=exp_EXT, freq=n,
         class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff,  
         spline=child_birth_yr mom_birth_yr sib_birth_yr,  id=, lbl=ASD/ID/SCH/SPD Uncle/Aunt Adjust3);


/** Calculate 95%CI from bootstrapped estimates and add to the raw estimates; **/
data estmaunt_boot1; set temp.estmaunt_boot1; run;
data estmaunt_boot2; set temp.estmaunt_boot2; run;
data estmaunt_boot3; set temp.estmaunt_boot3; run;
data estmaunt_boot4; set temp.estmaunt_boot4; run;

data estmuncle_boot1; set temp.estmuncle_boot1; run;
data estmuncle_boot2; set temp.estmuncle_boot2; run;
data estmuncle_boot3; set temp.estmuncle_boot3; run;
data estmuncle_boot4; set temp.estmuncle_boot4; run;

data estmaunt_ext_boot1; set temp.estmaunt_ext_boot1; run;
data estmaunt_ext_boot2; set temp.estmaunt_ext_boot2; run;
data estmaunt_ext_boot3; set temp.estmaunt_ext_boot3; run;
data estmaunt_ext_boot4; set temp.estmaunt_ext_boot4; run;

data estmuncle_ext_boot1; set temp.estmuncle_ext_boot1; run;
data estmuncle_ext_boot2; set temp.estmuncle_ext_boot2; run;
data estmuncle_ext_boot3; set temp.estmuncle_ext_boot3; run;
data estmuncle_ext_boot4; set temp.estmuncle_ext_boot4; run;

data estmaunt_ad_boot1; set temp.estmaunt_ad_boot1; run;
data estmaunt_ad_boot2; set temp.estmaunt_ad_boot2; run;
data estmaunt_ad_boot3; set temp.estmaunt_ad_boot3; run;
data estmaunt_ad_boot4; set temp.estmaunt_ad_boot4; run;

data estmuncle_ad_boot1; set temp.estmuncle_ad_boot1; run;
data estmuncle_ad_boot2; set temp.estmuncle_ad_boot2; run;
data estmuncle_ad_boot3; set temp.estmuncle_ad_boot3; run;
data estmuncle_ad_boot4; set temp.estmuncle_ad_boot4; run;

data estmaunt_bysex_boot1; set temp.estmaunt_bysex_boot1; run;
data estmaunt_bysex_boot2; set temp.estmaunt_bysex_boot2; run;
data estmaunt_bysex_boot3; set temp.estmaunt_bysex_boot3; run;
data estmaunt_bysex_boot4; set temp.estmaunt_bysex_boot4; run;

data estmuncle_bysex_boot1; set temp.estmuncle_bysex_boot1; run;
data estmuncle_bysex_boot2; set temp.estmuncle_bysex_boot2; run;
data estmuncle_bysex_boot3; set temp.estmuncle_bysex_boot3; run;
data estmuncle_bysex_boot4; set temp.estmuncle_bysex_boot4; run;


*-Main Cox results (12RR) + bootstrapped (1000 resamples) 95% CI, by outcome AD/ASD;
*-Exposure ASD maternal uncle;
%addboot (data=estmuncle1, boot=estmuncle_boot1, out=estmuncle_addbs1, by=outcome);
%addboot (data=estmuncle2, boot=estmuncle_boot2, out=estmuncle_addbs2, by=outcome);
%addboot (data=estmuncle3, boot=estmuncle_boot3, out=estmuncle_addbs3, by=outcome);
%addboot (data=estmuncle4, boot=estmuncle_boot4, out=estmuncle_addbs4, by=outcome);
*-Exposure ASD maternal aunt;
%addboot (data=estmaunt1, boot=estmaunt_boot1, out=estmaunt_addbs1, by=outcome);
%addboot (data=estmaunt2, boot=estmaunt_boot2, out=estmaunt_addbs2, by=outcome);
%addboot (data=estmaunt3, boot=estmaunt_boot3, out=estmaunt_addbs3, by=outcome);
%addboot (data=estmaunt4, boot=estmaunt_boot4, out=estmaunt_addbs4, by=outcome);
*-Exposure ASD maternal uncle/aunt;
%addboot (data=estmasib1, boot=estmasib_boot1, out=estmasib_addbs1, by=outcome);
%addboot (data=estmasib2, boot=estmasib_boot2, out=estmasib_addbs2, by=outcome);
%addboot (data=estmasib3, boot=estmasib_boot3, out=estmasib_addbs3, by=outcome);
%addboot (data=estmasib4, boot=estmasib_boot4, out=estmasib_addbs4, by=outcome);

*-Sup_bysex: main Cox results (12RR) + bootstrapped (1000 resamples) 95% CI, by outcome AD/ASD, by child's sex;
*-Exposure ASD maternal uncle;
%addboot (data=estmuncle_bysex1, boot=estmuncle_bysex_boot1, out=estmuncle_bysex_addbs1, by=child_sex outcome);
%addboot (data=estmuncle_bysex2, boot=estmuncle_bysex_boot2, out=estmuncle_bysex_addbs2, by=child_sex outcome);
%addboot (data=estmuncle_bysex3, boot=estmuncle_bysex_boot3, out=estmuncle_bysex_addbs3, by=child_sex outcome);
%addboot (data=estmuncle_bysex4, boot=estmuncle_bysex_boot4, out=estmuncle_bysex_addbs4, by=child_sex outcome);
*-Exposure ASD maternal aunt;
%addboot (data=estmaunt_bysex1, boot=estmaunt_bysex_boot1, out=estmaunt_bysex_addbs1, by=child_sex outcome);
%addboot (data=estmaunt_bysex2, boot=estmaunt_bysex_boot2, out=estmaunt_bysex_addbs2, by=child_sex outcome);
%addboot (data=estmaunt_bysex3, boot=estmaunt_bysex_boot3, out=estmaunt_bysex_addbs3, by=child_sex outcome);
%addboot (data=estmaunt_bysex4, boot=estmaunt_bysex_boot4, out=estmaunt_bysex_addbs4, by=child_sex outcome);
*-Exposure ASD maternal uncle/aunt;
%addboot (data=estmasib_bysex1, boot=estmasib_bysex_boot1, out=estmasib_bysex_addbs1, by=child_sex outcome);
%addboot (data=estmasib_bysex2, boot=estmasib_bysex_boot2, out=estmasib_bysex_addbs2, by=child_sex outcome);
%addboot (data=estmasib_bysex3, boot=estmasib_bysex_boot3, out=estmasib_bysex_addbs3, by=child_sex outcome);
%addboot (data=estmasib_bysex4, boot=estmasib_bysex_boot4, out=estmasib_bysex_addbs4, by=child_sex outcome);

*-Sup_expAD Cox results (12RR) + bootstrapped (1000 resamples) 95% CI, by outcome AD/ASD;
*-Exposure AD maternal uncle;
%addboot (data=estmuncle_ad1, boot=estmuncle_ad_boot1, out=estmuncle_ad_addbs1, by=outcome);
%addboot (data=estmuncle_ad2, boot=estmuncle_ad_boot2, out=estmuncle_ad_addbs2, by=outcome);
%addboot (data=estmuncle_ad3, boot=estmuncle_ad_boot3, out=estmuncle_ad_addbs3, by=outcome);
%addboot (data=estmuncle_ad4, boot=estmuncle_ad_boot4, out=estmuncle_ad_addbs4, by=outcome);
*-Exposure AD maternal aunt;
%addboot (data=estmaunt_ad1, boot=estmaunt_ad_boot1, out=estmaunt_ad_addbs1, by=outcome);
%addboot (data=estmaunt_ad2, boot=estmaunt_ad_boot2, out=estmaunt_ad_addbs2, by=outcome);
%addboot (data=estmaunt_ad3, boot=estmaunt_ad_boot3, out=estmaunt_ad_addbs3, by=outcome);
%addboot (data=estmaunt_ad4, boot=estmaunt_ad_boot4, out=estmaunt_ad_addbs4, by=outcome);
*-Exposure AD maternal uncle/aunt;
%addboot (data=estmasib_ad1, boot=estmasib_ad_boot1, out=estmasib_ad_addbs1, by=outcome);
%addboot (data=estmasib_ad2, boot=estmasib_ad_boot2, out=estmasib_ad_addbs2, by=outcome);
%addboot (data=estmasib_ad3, boot=estmasib_ad_boot3, out=estmasib_ad_addbs3, by=outcome);
%addboot (data=estmasib_ad4, boot=estmasib_ad_boot4, out=estmasib_ad_addbs4, by=outcome);

*-Sup_expAD Cox results (12RR) + bootstrapped (1000 resamples) 95% CI, by outcome AD/ASD;
*-Exposure AD maternal uncle;
%addboot (data=estmuncle_ext1, boot=estmuncle_ext_boot1, out=estmuncle_ext_addbs1, by=outcome);
%addboot (data=estmuncle_ext2, boot=estmuncle_ext_boot2, out=estmuncle_ext_addbs2, by=outcome);
%addboot (data=estmuncle_ext3, boot=estmuncle_ext_boot3, out=estmuncle_ext_addbs3, by=outcome);
%addboot (data=estmuncle_ext4, boot=estmuncle_ext_boot4, out=estmuncle_ext_addbs4, by=outcome);
*-Exposure AD maternal aunt;
%addboot (data=estmaunt_ext1, boot=estmaunt_ext_boot1, out=estmaunt_ext_addbs1, by=outcome);
%addboot (data=estmaunt_ext2, boot=estmaunt_ext_boot2, out=estmaunt_ext_addbs2, by=outcome);
%addboot (data=estmaunt_ext3, boot=estmaunt_ext_boot3, out=estmaunt_ext_addbs3, by=outcome);
%addboot (data=estmaunt_ext4, boot=estmaunt_ext_boot4, out=estmaunt_ext_addbs4, by=outcome);
*-Exposure AD maternal uncle/aunt;
%addboot (data=estmasib_ext1, boot=estmasib_ext_boot1, out=estmasib_ext_addbs1, by=outcome);
%addboot (data=estmasib_ext2, boot=estmasib_ext_boot2, out=estmasib_ext_addbs2, by=outcome);
%addboot (data=estmasib_ext3, boot=estmasib_ext_boot3, out=estmasib_ext_addbs3, by=outcome);
%addboot (data=estmasib_ext4, boot=estmasib_ext_boot4, out=estmasib_ext_addbs4, by=outcome);


*- Combine estimates in one and print for tables;
/** 2019-03-01: bootstrapping was done for muncle and maunt first, add masib later; **/
/** 2019-03-26: masib added; **/
/** Main cox 12RR, exp_ASD,exp_AD, exp_EXT by outcome ASD/AD **/
data boot_cox_out;
length label $40.;
set estmuncle_addbs1-estmuncle_addbs4 estmaunt_addbs1-estmaunt_addbs4 estmasib_addbs1-estmasib_addbs4
    estmuncle_ad_addbs1-estmuncle_ad_addbs4 estmaunt_ad_addbs1-estmaunt_ad_addbs4 estmasib_ad_addbs1-estmasib_ad_addbs4
    estmuncle_ext_addbs1-estmuncle_ext_addbs4 estmaunt_ext_addbs1-estmaunt_ext_addbs4 estmasib_ext_addbs1-estmasib_ext_addbs4
;
run;
proc sort data=boot_cox_out; by outcome label;run;
proc print data=boot_cox_out; var outcome label bscitxt;run;

/** Main cox 12RR, exp_ASD, by child's sex and by outcome ASD/AD **/
data boot_cox_bysex_out; 
length label $40.;
set estmuncle_bysex_addbs1-estmuncle_bysex_addbs4 estmaunt_bysex_addbs1-estmaunt_bysex_addbs4 estmasib_bysex_addbs1-estmasib_bysex_addbs4
;
run;
proc sort data=boot_cox_bysex_out; by child_sex outcome label;run;
proc print data=boot_cox_bysex_out; var child_sex outcome label bscitxt; by child_sex; run;

*-2019-04-01: save to temp folder;
data temp.boot_cox_out; set boot_cox_out; run;
data temp.boot_cox_bysex_out; set boot_cox_bysex_out; run;

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


