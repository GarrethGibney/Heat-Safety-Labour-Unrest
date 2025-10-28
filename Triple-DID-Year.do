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
	reghdfe `var' ib2005.year##i.outdoor##i.treated_state if inrange(year,2002,2008), /// 
	vce(cluster state_id)
}
* ===> Joint Signifigance of Pre-Trends <=== *
test (1.outdoor#1.treated_state#2002.year = 0) ///
     (1.outdoor#1.treated_state#2003.year = 0) ///
     (1.outdoor#1.treated_state#2004.year = 0)

* ===> Avg. Effect of Post-Trends <=== *
lincom (1.outdoor#1.treated_state#2006.year + 1.outdoor#1.treated_state#2007.year ///
      + 1.outdoor#1.treated_state#2008.year) / 3
	
* ===> Excludes Potential Partially Treated Sectors from Untreated <=== *
foreach var of varlist count {
	reghdfe `var' ib2005.year##i.outdoor##i.treated_state if sector_type != "Partial Treated" & inrange(year,2002,2008), ///
    vce(cluster state_id)
}


* ===> Falseifcation Tests Using (Simually Hot) States <=== *

local hotstates "TX AZ NV NM FL GA AL LA"

foreach s of local hotstates {
    di "=== Running placebo DID with treated_state_false = `s' ==="

    * Flag this state as pseudo-treated
    gen byte treated_state_false = state=="`s'"

    foreach var of varlist count {
        reghdfe `var' ib2005.year##i.outdoor##i.treated_state_false, ///
            absorb(state_id naics2_id) vce(cluster state_id)

        estimates store placebo_`s'_`var'
    }

    drop treated_state_false
}

* ===> Examine if Incidence is Trending Across Sectors Over Time <=== *
preserve
keep if state=="CA"
reghdfe count i.year##i.outdoor, absorb(naics2_id) vce(cluster naics2_id)
restore


* ===> Indoor as "Treated" <=== *
gen indoor = 0
replace indoor = 1 if outdoor != 1 & sector_type != "partial treated"
foreach var of varlist count {
	reghdfe `var' ib2005.year##i.indoor##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
}
* Notes:
* (1) Posible violation of SUTVA, as spillover through unions across states or spillover in demading simular rights in other sectors - The sharp positive jump in 2007–08 is exactly when we'd expect indoor workers to mobilise if they were inspired by outdoor protections.

* Treat Indoor CA as "pseudo-treated"

	  