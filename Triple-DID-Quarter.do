* Importing Data *
import delimited "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Data\State_Quarter_FMCS_Rate.csv", clear

* Pre-Processing for Analysis *
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

* Emergency standard filed & effective: 22 August 2005 (https://www.dir.ca.gov/title8/3395.html?utm_source=chatgpt.com)
* Emergency refiled: 20 December 2005 (https://www.dir.ca.gov/title8/3395.html?utm_source=chatgpt.com)
* Emergency refiled again: 19 April 2006 (https://www.dir.ca.gov/title8/3395.html?utm_source=chatgpt.com)
* Permanent standard adopted: 15 June 2006 (https://www.dir.ca.gov/dosh/heatillnessinvestigations-2006.pdf?utm_source=chatgpt.com)
* Permanent standard effective: 27 July 2006 (Permanent standard effective: 27 July 2006.)
* --- 1) Build a proper monthly %tm variable from date_month ---

capture confirm string variable date_quarter
if _rc == 0 {
    * If date_quarter is a string like "2005-09-01"
    gen double date_q = qofd(daily(date_quarter, "YMD"))
}
else {
    * If already numeric quarter (%tq)
    gen double date_q = date_quarter
}

* Format properly as yearq#
format date_q %tq

* Ensure date_q is numeric quarterly (%tq)
* e.g., if you started from a string "2005-09-01":
* gen double date_q = qofd(daily(date_quarter,"YMD"))

capture label drop quarterlbl

* Get all unique quarter values
levelsof date_q, local(qs)

* Map each numeric %tq code to a readable label
foreach q of local qs {
    local lbl : display %tq `q'
    label define quarterlbl `q' "`lbl'", add
}

* Attach the labels
label values date_q quarterlbl

*-----------------------------*
* 5a) One year before/after Sep 2005: 2004m9–2006m9
*-----------------------------*
preserve
local start = tq(2003q4)
local end   = tq(2007q4)
keep if inrange(date_q, `start', `end')

* Choose a proper quarterly base (example: 2005q4)
local base = tq(2005q4)

* sanity check
count if date_q == `base'
assert r(N) > 0   // ensure the base quarter is in the sample

reghdfe count ib`base'.date_q##i.outdoor##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
estimates store win_1yra

reghdfe count ib`base'.date_q##i.outdoor##i.treated_state if sector_type != "Partial Treated", ///
    absorb(state_id naics2_id) vce(cluster state_id)
estimates store win_1yrb
restore

*-----------------------------*
* 5c alt) permanent rule effective 27 Jul 2006 
* Baseline: 2006q3
* Same window: 2004q3–2008q3
*-----------------------------*
preserve
local start = tq(2004q3)
local end   = tq(2008q3)
keep if inrange(date_q, `start', `end')

* Choose a proper quarterly base (example: 2005q4)
local base = tq(2006q3)

* sanity check
count if date_q == `base'
assert r(N) > 0   // ensure the base quarter is in the sample

reghdfe count ib`base'.date_q##i.outdoor##i.treated_state, ///
    absorb(state_id naics2_id) vce(cluster state_id)
estimates store win_1yra

reghdfe count ib`base'.date_q##i.outdoor##i.treated_state if sector_type != "Partial Treated", ///
    absorb(state_id naics2_id) vce(cluster state_id)
estimates store win_1yrb
restore