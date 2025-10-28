*****************************************************************
***********************   Data Set-up   *************************
*****************************************************************
* ===> Loading Data <=== *
import delimited "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Data\State_Year_FMCS_Rate.csv", clear

* ===> Encoding Fixed Effects <=== *
encode state, gen(state_id)

capture confirm numeric variable naics2
if _rc { // NAICS2 is string
    encode naics2, gen(naics2_id)
}
else {
    gen long naics2_id = naics2
}

* ===> Treatment <=== *
gen byte treated_state = state=="CA"
gen treatment_year = 2005

* Generating Interactions for testing parallel trend assumption *
gen n_year=year-2005

gen state_year = treated_state*n_year

* Generating Interactions for DID Analysis
gen treat1_CA = 0
replace treat1_CA = 1 if n_year >= 0 & state == "CA"
