* Importing Data *
import delimited "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Data\State_Month_FMCS_Rate.csv", clear

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

capture confirm string variable date_month
if _rc == 0 {
    * date_month is a string like "2005-09-01" (YMD)
    gen double date_d = daily(date_month, "YMD")
    format date_d %td
}
else {
    * date_month is already numeric (assumed %td daily)
    gen double date_d = date_month
    format date_d %td
}

gen int date_m = mofd(date_d)
format date_m %tm
label var date_m "Monthly date (%tm)"

* Month-of-year for a %tm monthly date
gen byte moy = month(dofm(date_m))   // 1=Jan,...,12=Dec
label define moy 1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label values moy moy

* Make a value label mapping numeric %tm codes to readable year-month
* Drop any existing label with that name (avoids conflict if re-run)
capture label drop monthlbl

* Get all unique month values
levelsof date_m, local(months)

* Loop over them and define labels
foreach m of local months {
    local lbl : display %tm `m'
    label define monthlbl `m' "`lbl'", add
}

* Attach the labels to the variable
label values date_m monthlbl

*-----------------------------*
* 5a) One year before/after Sep 2005: 2004m9–2006m9
*-----------------------------*
preserve
    local start = tm(2004m9)
    local end   = tm(2006m9)
    keep if inrange(date_m, `start', `end')

    local base = tm(2005m9)   // Sep 2005 baseline (first full post month)
    reghdfe count ib`base'.date_m##i.outdoor##i.treated_state, ///
        absorb(state_id naics2_id) vce(cluster state_id)
    estimates store win_1yra
 reghdfe count ib`base'.date_m##i.outdoor##i.treated_state if sector_type != "Partial Treated", ///
        absorb(state_id naics2_id) vce(cluster state_id)
    estimates store win_1yrb
restore

*-----------------------------*
* 5b alt) First full warm-season baseline (implementation/learning)
* Baseline: 2006m5
* window: 2005m5–2007m5
*-----------------------------*
preserve
    local start = tm(2005m5)
    local end   = tm(2007m5)
    keep if inrange(date_m, `start', `end')

    local base = tm(2006m5)
    reghdfe count ib`base'.date_m##i.outdoor##i.treated_state, ///
        absorb(state_id naics2_id) vce(cluster state_id)
    estimates store warm_2006m5
 reghdfe count ib`base'.date_m##i.outdoor##i.treated_state if sector_type != "Partial Treated", ///
        absorb(state_id naics2_id) vce(cluster state_id)
restore
	
*-----------------------------*
* 5c alt) permanent rule effective 27 Jul 2006 + one full month
* Baseline: 2006m8
* Same window: 2005m8–2007m8
*-----------------------------*
preserve
    local start = tm(2005m8)
    local end   = tm(2007m8)
    keep if inrange(date_m, `start', `end')

    local base = tm(2006m8)
    reghdfe count ib`base'.date_m##i.outdoor##i.treated_state, ///
        absorb(state_id naics2_id) vce(cluster state_id)
    estimates store warm_2006m5
 reghdfe count ib`base'.date_m##i.outdoor##i.treated_state if sector_type != "Partial Treated", ///
        absorb(state_id naics2_id) vce(cluster state_id)
restore
	
	
	
	
	
	