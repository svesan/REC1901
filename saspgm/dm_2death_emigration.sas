*-------------------------------------------------------------------;
* Add censor time: date of death  and  date of emigration           ;
*-------------------------------------------------------------------;
data emigrat;
set childdsn2;
if emig_dat gt .z;
run;

data death;
set childdsn2;
if death_dat gt .z;
run;


proc sort data=emigrat; by lopnr;run;
proc sort data=s7;by child;run;

data s8;
  drop _c_;
  retain _c_ 0;
  merge emigrat(in=emigrat rename=(lopnr=child) drop=sex birth_dat birth_yr death_dat) s7(in=s7) end=eof; by child;
  if emigrat and s7 then _c_=_c_+1;
  if eof then put 'Note: There are ' _c_ ' children censored due to emigration';
  if emigrat and not s7 then delete;
run;

proc sort data=death;by lopnr;run;
proc sort data=s8;by child;run;
data s9;
  drop _c_;
  retain _c_ 0;
  merge s8(in=s8) death(in=death rename=(lopnr=child) drop=sex birth_dat birth_yr emig_dat) end=eof;by child;
  if death and not s8 then do;
    if eof then put 'Note: There are ' _c_ ' children censored due to death';
  delete;
  end;
  else if death and s8 then _c_=_c_+1;
  if eof then put 'Note: There are ' _c_ ' children censored due to death';
run;
