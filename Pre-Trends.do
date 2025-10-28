******************************************************************
*************************   Pre-Trends   *************************
******************************************************************
* Testing Paraelle Trends for the difference-in-difference
/* Dependent variable: Strike Incident Rate by NAICS 2-digit, State, and Year) */
* Labels (as you had)
label var state_year       "State x Year"
label var n_year             "Year"
label var treated_state      "CA"

/* Table 1: Testing Parallel Trends for the Difference-in-Difference (DD) */
reg count  state_year n_year treated_state ///
    if n_year < 0 & inrange(year,2002,2004), vce(cluster state_id)
estimates store b1

* Export exactly the body you want (booktabs, one columns, t-stats in parentheses)
* NOTE: `fragment` lets us fully control the tabular begin/end and headings.
esttab b1 ///
using "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Results\PT.tex", ///
    replace booktabs label ///
    prehead("\begin{tabular}{@{}l r@{}}\toprule \multicolumn{2}{l}{\textbf{Strike Incident Rate per 1,000,000 workers}}\\") ///
    posthead("\midrule") ///
    refcat(outdoor_year_state "\emph{Testing Parallel Trends for Triple Difference}", nolabel) ///
    mlabels(none) collabels(none) nonumber nomtitles nonotes compress ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels(Observations)) ///
    postfoot("\bottomrule\end{tabular}")
	
	
* Alternative Control Groups *
preserve

keep if inlist(state, "CA", "AZ","NV","NM","OR","WA","UT","CO","ID")
reg count  state_year n_year treated_state ///
    if n_year < 0 & inrange(year,2002,2004), vce(cluster state_id)

restore


preserve

keep if inlist(state, "CA", "AZ","NV","NM","TX","FL","LA","OK","AR")
reg count  state_year n_year treated_state ///
    if n_year < 0 & inrange(year,2002,2004), vce(cluster state_id)

restore