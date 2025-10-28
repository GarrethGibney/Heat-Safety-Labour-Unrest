*****************************************************************
*************************   Analysis   *************************
*****************************************************************
* ===> Triple Difference (State x Year x Sector) <=== *
* Policy: An emergency heat stress standard for outdoor workers took effect in August 2005 and included provisions for water, shade, and heat stress training for employees and supervisors.
* The emergency standard had an intended end date of December 2005 but was renewed twice into July 2006
* A permanent standard, which went into effect July 2006.
* The 2005/6 standard requires: 
* (1) Training: Supervisory and nonsupervisory employee training on elements of heat-related illnesses and injuries.  
* (2) Provision of Water Employee access to free, drinking water as close as practicable to the areas where they are working.
* (3) Access to Shade: Mandatory provision of shade when the temperature exceeds 80 ° F, and encouragement of preventative cool-down rests in the shade.
* Stanard has been strenghtened into 2010, and 2015

* ===> Baseline <=== *
foreach var of varlist count {
	reghdfe `var' ib2005.year##i.treated_state if inrange(year,2002,2008), /// 
 vce(cluster state_id)
}

estimates store es

* ===> Joint Signifigance of Pre-Trends <=== *
test (1.treated_state#2002.year = 0) ///
     (1.treated_state#2003.year = 0) ///
     (1.treated_state#2004.year = 0)

* ===> Avg. Effect of Post-Trends <=== *
lincom (1.treated_state#2006.year + 1.treated_state#2007.year ///
      + 1.treated_state#2008.year) / 3

* Plot only the interaction terms (the dynamic treatment effects)
coefplot es, ///
    keep(*.year#1.treated_state 1.treated_state#*.year) ///
    order(2002.year#1.treated_state 2003.year#1.treated_state ///
          2004.year#1.treated_state 2006.year#1.treated_state ///
          2007.year#1.treated_state 2008.year#1.treated_state) ///
    coeflabels(2002.year#1.treated_state = "-3" 1.treated_state#2002.year = "-3" ///
               2003.year#1.treated_state = "-2" 1.treated_state#2003.year = "-2" ///
               2004.year#1.treated_state = "-1" 1.treated_state#2004.year = "-1" ///
               2006.year#1.treated_state = "1"  1.treated_state#2006.year = "1"  ///
               2007.year#1.treated_state = "2"  1.treated_state#2007.year = "2"  ///
               2008.year#1.treated_state = "3"  1.treated_state#2008.year = "3") ///
    recast(connected) msymbol(O) mcolor(black) lcolor(black) ///
    ciopts(recast(rcap) lcolor(black)) ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Years Relative to Treatment (Base = 2005)") ///
    ytitle("Effect on Rate of Strike Incidence") ///
    title(" ") ///
    legend(off) ///
	vertical
	
graph export "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Results\EventStudy_Baseline.png", replace width(2200)


* Alternative Control Groups *
preserve

keep if inlist(state, "CA", "AZ","NV","NM","OR","WA","UT","CO","ID")
reghdfe count ib2005.year##i.treated_state if inrange(year,2002,2008), /// 
 vce(cluster state_id)

restore


	



