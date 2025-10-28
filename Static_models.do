/* Table 2: Estimating Difference-in-Difference (DD) */ 
label var treat1_CA     "Treat x Year"
label var n_year             "Year"
label var treated_state      "Treat"
reghdfe count i.treat1_CA treated_state n_year if inrange(year,2002,2008), cluster(state_id)
estimates store b1

* Export exactly the body you want (booktabs, one columns, t-stats in parentheses)
* NOTE: `fragment` lets us fully control the tabular begin/end and headings.
esttab b1 ///
using "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Results\TWFE_Diff.tex", ///
    replace booktabs label ///
    prehead("\begin{tabular}{@{}l r@{}}\toprule \multicolumn{2}{l}{\textbf{Strike Incident Rate per 1,000,000 workers}}\\ \midrule Treatment Group = California \\ Control Group = All other U.S. States \\") ///
    posthead("\midrule") ///
    mlabels(none) collabels(none) nonumber nomtitles nonotes compress ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels(Observations)) ///
    postfoot("\bottomrule\end{tabular}")


/* Table 3: Hetrogenous/Continuous treatment */ 
* A) Calculating Normalised Measure of Sectoral Exposure
summ weighted_exposure if inrange(year,2002,2008)
scalar mw = r(mean)
scalar sd = r(sd)

gen double weighted_exposure_SD = (weighted_exposure - mw)/sd
label var weighted_exposure_SD "weighted_exposure (normalised on estimation sample)"

* B) Re-run your model with the centered variable
reghdfe count i.treat1_CA c.weighted_exposure_SD#i.treat1_CA n_year treated_state c.weighted_exposure_SD if inrange(year,2002,2008), cluster(state_id)
estimates store b2

* Export exactly the body you want (booktabs, one columns, t-stats in parentheses)
* NOTE: `fragment` lets us fully control the tabular begin/end and headings.
esttab b2 ///
using "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Results\TWFE_Diff_Cont_Exp.tex", ///
    replace booktabs label ///
    prehead("\begin{tabular}{@{}l r@{}}\toprule \multicolumn{2}{l}{\textbf{Strike Incident Rate per 1,000,000 workers}}\\ \midrule Treatment Group = California \\ Control Group = All other U.S. States \\") ///
    posthead("\midrule") ///
    mlabels(none) collabels(none) nonumber nomtitles nonotes compress ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels(Observations)) ///
    postfoot("\bottomrule\end{tabular}")
	
* Graphing Marginal Effects
margins, at(weighted_exposure_SD = (-2.5(0.25)2.5)) dydx(treat1_CA)

marginsplot, xdimension(weighted_exposure_SD) /// 
title(" ") /// 
ytitle("Estimated Effect on Rate of Strikes Incidence") /// 
xtitle("Sectoral Exposure (SD units)") /// 
recast(scatter) /// 
plotopts(msymbol(O) mcolor(black) lcolor(black)) /// 
ciopts(recast(rcap) lcolor(black)) /// 
yline(0, lpattern(dash) lcolor(gs8)) ///
xlabel(, angle(45))
	
graph export "C:\Users\20234503\Desktop\Research\Strikes, Temperature, and Heat Safety Laws\Project\Results\TWFE_Diff_Cont_Exp_mp.png", replace width(2000)


* Alternative Control Groups *
preserve

keep if inlist(state, "CA", "AZ","NV","NM","OR","WA","UT","CO","ID")
reghdfe count i.treat1_CA treated_state n_year if inrange(year,2002,2008), cluster(state_id)

reghdfe count i.treat1_CA c.weighted_exposure_SD#i.treat1_CA n_year treated_state c.weighted_exposure_SD if inrange(year,2002,2008), cluster(state_id)

*Graphing Marginal Effects
margins, at(weighted_exposure_SD = (-2.5(0.25)2.5)) dydx(treat1_CA)

marginsplot, xdimension(weighted_exposure_SD) /// 
title(" ") /// 
ytitle("Estimated Effect on Rate of Strikes Incidence") /// 
xtitle("Sectoral Exposure (SD units)") /// 
recast(scatter) /// 
plotopts(msymbol(O) mcolor(black) lcolor(black)) /// 
ciopts(recast(rcap) lcolor(black)) /// 
yline(0, lpattern(dash) lcolor(gs8)) ///
xlabel(, angle(45))
	
restore
