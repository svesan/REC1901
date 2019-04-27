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
