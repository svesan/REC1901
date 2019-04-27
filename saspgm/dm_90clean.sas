*--------------------------------------------------------;
* Clean trash datasets in work library                   ;
*--------------------------------------------------------;

proc datasets library=work;
   delete P2-P5 S1-S12 H0-H4 ana1-ana4;
run;
