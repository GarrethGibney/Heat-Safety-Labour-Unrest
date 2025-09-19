import delimited "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Data\State_Year_FMCS.csv", clear

* Cleaning
* If needed:
ssc install reghdfe, replace
ssc install ppmlhdfe, replace

* Encode strings to categorical numerics for FE and interactions
encode state, gen(state_id)
capture confirm numeric variable naics2
if _rc { // NAICS2 is string
    encode naics2, gen(naics2_id)
}
else {
    gen long naics2_id = naics2
}

* Treatment and timing
gen byte treated_state = state=="CA"
gen year_rel = year - 2005     // 0=2005 (vote), 1=2006 (implementation)
label var year_rel "Year relative to 2005"


* Optional: state-specific linear time (centered at 2005)
gen t = year - 2005
label var t "years since 2005"


* Triple Difference
* Baseline year = 2005
foreach var of varlist count avg_length severity short_share {
	reghdfe `var' ib2005.year##i.outdoor##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
}

import delimited "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Data\State_Year_FMCS_Rate.csv", clear

* Encode strings to categorical numerics for FE and interactions
encode state, gen(state_id)
capture confirm numeric variable naics2
if _rc { // NAICS2 is string
    encode naics2, gen(naics2_id)
}
else {
    gen long naics2_id = naics2
}

* Treatment and timing
gen byte treated_state = state=="CA"
gen year_rel = year - 2005     // 0=2005 (vote), 1=2006 (implementation)
label var year_rel "Year relative to 2005"


* Optional: state-specific linear time (centered at 2005)
gen t = year - 2005
label var t "years since 2005"

* DID Difference
foreach var of varlist count {
	reghdfe `var' ib2005.year##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
}
* Triple Difference
* Baseline year = 2005
foreach var of varlist count {
	reghdfe `var' ib2005.year##i.outdoor##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
}

* Joint pre-trend test: all DDD leads (2000–2004) == 0
test (1.outdoor#1.treated_state#2000.year = 0) ///
     (1.outdoor#1.treated_state#2001.year = 0) ///
     (1.outdoor#1.treated_state#2002.year = 0) ///
     (1.outdoor#1.treated_state#2003.year = 0) ///
     (1.outdoor#1.treated_state#2004.year = 0)
* Estimate a pre-period slope difference (through 2004)
gen t = year - 2005
reghdfe count i.outdoor##i.treated_state##c.t if year<=2004, ///
    absorb(state_id naics2_id) vce(cluster state_id)
* The coef on 1.outdoor#1.treated_state#c.t is the pre-trend slope gap.
	 
* Joint Signifigance of Post-Treatment Variables
lincom (1.outdoor#1.treated_state#2006.year + 1.outdoor#1.treated_state#2007.year ///
      + 1.outdoor#1.treated_state#2008.year + 1.outdoor#1.treated_state#2009.year ///
      + 1.outdoor#1.treated_state#2010.year) / 5

	  foreach var of varlist count {
	reghdfe `var' ib2005.year##i.outdoor##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
}

egen state_outdoor = group(state_id outdoor)
egen ind_year = group(naics2_id year)

reghdfe count ib2005.year##i.outdoor##i.treated_state ///
    , absorb(state_id ind_year) vce(cluster state_id)

* Re-check pre leads
testparm 1.outdoor#1.treated_state#(2000/2004).year


	
reghdfe short_share ib2005.year##i.outdoor##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
	
reghdfe severity ib2005.year##i.outdoor##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
	  