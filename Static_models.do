gen treat1_outdoor_CA = 0
replace treat1_outdoor_CA = 1 & n_year >= 0 & state == "CA" & outdoor == 1

gen treat1_outdoor = 0
replace treat1_outdoor = 1 if year > 2004 & outdoor == 1

gen treat1_CA = 0
replace treat1_CA = 1 if year > 2004 & state == "CA"

/* PANEL A: Estimating Difference-in-Difference (DD) */
reg count treat1_outdoor n_year outdoor i.naics2_id if inrange(year,2003,2007) & state == "CA", cluster(naics2_id)
/* PANEL B: Estimating Triple-Difference (DD) */
reg count treat1_outdoor_CA treat1_outdoor treat1_CA n_year outdoor treated_state if inrange(year,2002,2008)
reg count treat1_outdoor_CA treat1_outdoor treat1_CA n_year outdoor treated_state if inrange(year,2002,2008), cluster(state_id)
reg count treat1_outdoor_CA treat1_outdoor treat1_CA n_year outdoor treated_state i.state_id i.naics2_id if inrange(year,2002,2008), cluster(state_id)

*Bertrand, Duflo, Mullainathan 2004, "How Much Should We Trust DiD Estimates?"