 ssc install synth, replace all
 
 * ===> Loading Data <=== *
import delimited "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Data\predictor.csv", clear

* Setting the Panel Data Structure *
encode state, gen(state_id)
destring naics2, replace

egen state_naics2 = group(naics2 fipsstate)
drop if state_naics2 == .
duplicates report state_naics2 year
drop if union_density == .

collapse (sum) count count_rate (first) union_density unemployment_rate cpi ptc_change_gdp, by(year state_id)
tsset state_id year
egen state_year = group(state_id year)

sort state_id year 
by state_id: gen lag = unemployment_rate[_n-1]

* Predictor Variables: union_density, unemployment_rate, 
synth count_rate union_density(1981(2)2004) unemployment_rate(1981(2)2004) cpi(1981(2)2004) count_rate(1988(2)2004) ///
, trunit(5) trperiod(2005) fig



