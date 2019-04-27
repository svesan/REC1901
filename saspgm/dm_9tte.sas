*--------------------------------------------------------------------------------;
* Add information about end of follow-up and create tte                          ;
*--------------------------------------------------------------------------------;

proc sql; select max(child_diagdat) as max format=date9. from ana4; quit;  *Checking purpose: Latest date of diagnosis: 31DEC2017;

proc sort data=ana4; by outcome child; run;
data ana5;
  drop min;
  retain endfu_dat '31DEC2017'd; 
  * retain endfu_dat '31DEC2010'd; /*test on similar diagnose date as old data*/
  set ana4;
  min = min(death_dat, emig_dat, child_diagdat, endfu_dat);
  if min=child_diagdat then do;
    cens_type='A'; exit_dat=min;
  end;
  else if min=death_dat then do;
    cens_type='D'; exit_dat=min;
  end;
  else if min=emig_dat then do;
    cens_type='E'; exit_dat=min;
  end;
  else if min=endfu_dat then do;
    cens_type='F'; exit_dat=min;
  end;
  else abort;
  tte=exit_dat-child_birth_dat;
run;
