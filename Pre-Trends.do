******************************************************************
*************************   Pre-Trends   *************************
******************************************************************
/*
Dependent Variable: Rate of Strikes per-100,000 workers by State, Sector, and Year
*/
sum count
count if count == 0

* Testing Paraelle Trends for the difference-in-difference
* Converting enrollment in logs as the population base for Bihar and Jharkhand is different *
gen lcount = log(count)

* Generating Interactions for testing parallel trend assumption *
gen n_year=year-2005

gen year_outdoor = n_year*outdoor

gen outdoor_state = outdoor*treated_state

gen state_year = treated_state*n_year

gen outdoor_year_state = outdoor*n_year*treated_state

/* Dependent variable: Strike Incident Rate by NAICS 2-digit, State, and Year) */

/* PANEL A: Testing Parallel Trends for the Difference-in-Difference (DD) */
reg count year_outdoor outdoor n_year i.naics2_id if state == "CA" & year < treatment_year

/* PANEL B: Testing Parallel Trends for the Triple Difference (DDD) */
reg count outdoor_year_state  year_outdoor outdoor_state outdoor n_year treated_state i.state_id i.naics2_id if year < treatment_year, cluster(state_id)

