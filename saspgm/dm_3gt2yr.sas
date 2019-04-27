*-------------------------------------------------------------;
* Keep those children lived up to 2 years old                 ;
*-------------------------------------------------------------;
data s10;
  drop _D_ _E_;
  retain _d_ _e_ 0;
  set s9 end=eof;
  if .z<(death_dat-child_birth_dat)/365.25<2 then do; _d_=_d_+1; delete; end;
  else if .z<(emig_dat-child_birth_dat)/365.25<2 then do; _e_=_e_+1; delete; end;
  if eof then put 'Note: There are ' _d_ ' and ' _e_ '  children deleted due to death and emigration before 2';
run; 
