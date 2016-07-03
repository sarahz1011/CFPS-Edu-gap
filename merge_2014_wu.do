*******************************************************************************/
*						cfps

*	Goal:			clean cfps2014   
*	Data:			cfps2014child_20160601.dta
*   Author(s):      Wumengying wumengyingceee@163.com 15871821321
*	Created: 		 July.1 2016
*   Last Modified: 	 July.2 2016
*******************************************************************************/
clear
set more off
set scrollbufsize 2048000
capture log close
global dtadir      "C:\Users\lenovo\Desktop\cfps-molly\dta"
global workingdir  "C:\Users\lenovo\Desktop\cfps-molly\working"
global savedir     "C:\Users\lenovo\Desktop\cfps-molly\save"
cd "$workingdir"

local date 0701_cfps2014
log using "clean_`date'",replace

********************************************************************************
***PART 1. keep sample in 2014child (aged from 10 to15)
***PART 2. merge some information on 2014child from 2010child.
***PART 3. keep useful var in adult2014
***PART 4. merge some information on child2014 from adult2014.
***PART 5. merge some information on chid2014 from famconf2014

********************************************************************************
use "$dtadir\cfps2014child_20160601.dta", clear
***PART 1. keep sample in 2014child (aged from 10 to15)
count if cfps2014_age>=10  // sample is 2956
keep if cfps2014_age>=10
save  "$savedir\cfps2014child_10-15.dta"
 
****PART 2. merge some information on 2014child from 2010child.
****information includes ethnic ,father's education ,mother's education
use "$savedir\cfps2014child_10-15.dta",clear
duplicates report pid
save "$workingdir\cfps2014child_10-15.dta"

use "$dtadir\ecfps2010child_112014.dta", clear
duplicates report pid
sort pid
bro pid
keep pid fid pid_m pid_f fedu feduy medu meduy wa6code
foreach mm of varlist fid-meduy {
   rename `mm' `mm'_2010
   }

save "$workingdir\ecfps2010child_112014_1.dta",replace


use "$savedir\cfps2014child_10-15.dta",clear
sort pid
bro pid
save "$workingdir\cfps2014child_10-15.dta"

use "$workingdir\cfps2014child_10-15.dta", clear
merge pid using "$workingdir\ecfps2010child_112014_1.dta"
tab _merge,m
drop if _merge==2
bro pid fid10 fid14 if _merge==1
save "$savedir\cfps2014child_10-15_merge_2010child.dta"


***PART 3. keep useful var in adult_2014
use "$dtadir\cfps2014_adult_20160601.dta", clear
keep pid fid14 fid12 fid10 provcd14 countyid14 cid14 urban14 code_b_1 qa701code ///
egc2012y_a_1 egc2012m_a_1 egc2013y_a_1 egc2013m_a_1 egc2013c_a_1 egc202_a_1 ///
egc2021_a_1 egc203_a_1 egc2031_a_1 egc204_a_1 egc205_a_1 egc2012y_a_2 ///
egc2012m_a_2 egc2013y_a_2 egc2013m_a_2 egc2013c_a_2 egc202_a_2 egc2021_a_2 /// 
egc203_a_2 egc2031_a_2 egc204_a_2 egc205_a_2 egc2012y_a_3 egc2012m_a_3 egc2013y_a_3 ///
egc2013m_a_3 egc2013c_a_3 egc202_a_3 egc2021_a_3 egc203_a_3 egc2031_a_3 egc204_a_3 ///
 egc205_a_3 egc2012y_a_4 egc2012m_a_4 egc2013y_a_4 egc2013m_a_4 egc2013c_a_4 ///
 egc202_a_4 egc2021_a_4 egc203_a_4 egc2031_a_4 egc204_a_4 egc205_a_4 egc2012y_a_5 ///
egc2012m_a_5 egc2013y_a_5 egc2013m_a_5 egc2013c_a_5 egc202_a_5 egc2021_a_5 ///
egc203_a_5 egc2031_a_5 egc204_a_5 egc204_a_5 egc205_a_5 egc2012y_a_6 ///
egc2012m_a_6 egc2013y_a_6 egc2013m_a_6 egc2013c_a_6 egc202_a_6 egc2021_a_6 ///
egc203_a_6 egc2031_a_6 egc204_a_6 egc205_a_6 egc2012y_a_7 egc2012m_a_7 ///
egc2013y_a_7 egc2013m_a_7 egc2013c_a_7 egc202_a_7 egc2021_a_7 egc203_a_7 ///
egc2031_a_7 egc204_a_7 egc205_a_7 egc2012y_a_8 egc2012m_a_8 egc2013y_a_8 ///
egc2013m_a_8 egc2013c_a_8 egc202_a_8 egc2021_a_8 egc203_a_8 egc2031_a_8 ///
egc204_a_8 egc205_a_8 egc2012y_a_9 egc2012m_a_9 egc2013y_a_9 egc2013m_a_9 ///
egc2013c_a_9 egc202_a_9 egc2021_a_9 egc203_a_9 egc203_a_9 egc2031_a_9 ///
egc204_a_9 egc2012y_a_10 egc205_a_9 egc2012m_a_10 egc2013y_a_10 egc2013m_a_10 ///
 egc2013c_a_10 egc202_a_10 egc2021_a_10 egc203_a_10 egc2031_a_10 egc204_a_10 ///
 egc204_a_10 egc205_a_10 egc101 egc104y egc104m egc104c egc103 egc105 egc1052m  ///
 egc1052y egc1053y egc1053m egc1053c egc201 egc201q egc202_b_1 egc2021_b_1 ///
 egc203_b_1 egc2031_b_1 egc204_b_1 egc205_b_1 egc2051_min_a_1 egc2051_max_a_1 ///
 egc2051_min_a_2 egc2051_max_a_2 egc2051_min_a_3 egc2051_max_a_3 ///
 egc2051_min_a_4 egc2051_max_a_4 egc2051_min_a_5 egc2051_max_a_5 ///
 egc2051_min_a_6 egc2051_max_a_6 egc2051_min_a_7 egc2051_max_a_7 ///
 egc2051_min_a_8 egc2051_max_a_8 egc2051_max_a_8 egc2051_min_a_9 ///
 egc2051_max_a_9 egc2051_min_a_10 egc2051_max_a_10 egc2051_min_b_1 ///
 egc2051_max_b_1  cfps2012_latest_edu cfps2012_latest_r1 qg101
save  "$savedir\cfps2014adult.dta" ,replace

***PART 4. merge some information on child_2014 from adult_2014.
****merge father's information
use "$savedir\cfps2014adult.dta" ,clear
foreach mm of varlist pid-egc2051_max_b_1 {
   rename `mm' `mm'_2014adult_f
   } 
rename  pid_2014adult  pid_f   //aim var in 2014child is pid_f
save "$workingdir\cfps2014adult.dta" ,replace

use "$workingdir\cfps2014adult.dta",clear
sort pid_f
duplicates report pid_f
bro pid_f
save "$workingdir\cfps2014adult.dta" ,replace

use "cfps2014child_10-15_merge_2010child.dta",clear
sort pid_f
bro pid_f
rename _merge _merge1
merge m:1 pid_f using "$workingdir\cfps2014adult.dta"
drop if _merge==2 
save "$savedir\cfps2014child_10-15_merge_2010child_2014adult.dta" ,replace

***merge mother's information
use "$savedir\cfps2014adult.dta" ,clear
foreach mm of varlist pid-egc2051_max_b_1 {
   rename `mm' `mm'_2014_adult_m
   } 
rename pid_2014_adult_m pid_m
save "$workingdir\cfps2014adult.dta" ,replace

use "$savedir\cfps2014child_10-15_merge_2010child_2014adult.dta",clear
sort pid_m
duplicates report pid_m
bro pid_m
save "$workingdir\cfps2014child_10-15_merge_2010child_2014adult.dta" ,replace

use "$workingdir\cfps2014child_10-15_merge_2010child_2014adult.dta",clear
sort pid_m
bro pid_m
rename _merge _merge2
merge m:1 pid_m using "$workingdir\cfps2014adult.dta"
drop if _merge==2 
save "$savedir\cfps2014child_10-15_merge_2010child_2014adult.dta" ,replace

***PART 5. merge some information on chid_2014 from famconf_2014
use "$dtadir\cfps2014famconf_20160601.dta", clear
keep fid14 fid12 fid10 provcd14 countyid14 cid14  urban14 pid tb4_a14_p ///
 tb4_a14_f tb6_a14_f tb4_a14_m tb6_a14_m
duplicates report pid
duplicates tag pid ,gen(dup)
list pid if dup==1
bro pid tb4_a14_f  tb4_a14_m if dup==1  
save  "$savedir\cfps2014famconf_20160601.dta" ,replace

use  "$savedir\cfps2014famconf_20160601.dta" ,clear
foreach mm of varlist fid14-dup {
   rename `mm' `mm'_2014famconf
   } 
rename pid_2014famconf pid
sort pid
bro pid
save "$workingdir\cfps2014famconf_20160601.dta" ,replace

use "$savedir\cfps2014child_10-15_merge_2010child_2014adult.dta", clear
sort pid
bro pid
rename _merge  _merge3
merge 1:m pid using "$workingdir\cfps2014famconf_20160601.dta" 
drop if _merge==2
save "$workingdir\cfps2014child_10-15_merge_2010child_2014adult_2014famconf.dta",replace
***clear
use "$savedir\cfps2014child_10-15_merge_2010child_2014adult_2014famconf.dta",clear
duplicates report pid
sort pid
duplicates tag pid ,gen(dup)
bro pid tb4_a14_f tb4_a14_m if dup==1  
gen x=_n if dup==1
replace x=1 if x==.
keep if mod(x,2)
duplicates report pid
duplicates tag pid ,gen(dup1)
list pid if dup1==2
drop x
gen x=_n
bro x pid tb4_a14_f tb4_a14_m if dup==2
drop if x==2168 | x==2167
bro
save "$savedir\cfps2014child_10-15_merge_2010child_2014adult_2014famconf.dta", replace

use "$savedir\cfps2014child_10-15_merge_2010child_2014adult_2014famconf.dta", clear
tab tb4_a14_f
save "$workingdir\cfps2014child_10-15_merge_2010child_2014adult_2014famconf.dta", replace



