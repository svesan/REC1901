**- Differentiate exp_AD and exp_AS/exp_PDD;
data masib_subtype(label='Cox analysis dataset for aunts and uncles');
  keep outcome years censored child_birth_yr mom_birth_yr sib_birth_yr exp_AD exp_AS exp_PDD exp_ASPDD;

  set ana6(where = (masib_typ='Full'));

  years=round(tte/365.25, 0.01);
  censored=0;
  if cens_type in ('D','E','F') then censored=1;
  child_birth_yr=year(child_birth_dat);
  mom_birth_yr=year(mob_dat);
  sib_birth_yr=year(sib_birth_dat);
  array values exp_AS exp_PDD;
  exp_ASPDD = max(of values[*]);
run;

*-Use AS/PDD as exposure;
ods listing close;
%est(data=masib_subtype, out=estmasib_subtype1, exposure=exp_ASPDD, class=, freq=0, by=outcome, lbl=AS/PDD Uncle or Aunt: 0Crude);
%est_spl(data=masib_subtype, out=estmasib_subtype2, exposure=exp_ASPDD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0, 
         by=outcome, lbl=AS/PDD Uncle or Aunt: Adjusted1);
