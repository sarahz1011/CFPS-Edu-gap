*******************************************************************************/
*				      cfps

*	Goal:			Clean the cfps2012  
*	Data:			cfps2012childcombined_032015compress.dta
*   Author(s):      Zhangsiqi sarahz1011@163.com 15399182411
*	Created: 		July.2 2016
*   Last Modified: 	July.2 2016
*******************************************************************************/
clear
set more off
set scrollbufsize 2048000
capture log close
global dtadir      "C:\Users\Administrator\Desktop\cfps\dta"
global workingdir  "C:\Users\Administrator\Desktop\cfps\working"
global savedir     "C:\Users\Administrator\Desktop\cfps\save"
cd "$workingdir"


local date 0702_cfps2012
log using "clean_`date'",replace
********************************************************************************
***PART 1. keep sample which age from 10-15 in 2012child
***PART 2. add some information in 2012child from 2010child
***PART 3. keep useful var in adult2012
***PART 4. merge some information on child2012 from adult2012
***PART 5. merge some information on child2012 from famconf2012
********************************************************************************


********************************************************************************
use "$dtadir/cfps2012childcombined_032015compress.dta",clear
*** PART 1. keep sample which age from 10-15 in 2012child
count if cfps2012_age>=10 //3056个样本
keep if cfps2012_age>=10
save  "$savedir\cfps2012child_10-15.dta",replace

*** PART 2. add some information in 2012child from 2010child
*****information includes ethnic,father's education,mother's education
use  "$savedir\cfps2012child_10-15.dta",clear
duplicates report pid 
save  "$workingdir\cfps2012child_10-15.dta",replace

use "$dtadir\ecfps2010child_112014.dta",clear
duplicates report pid
sort pid
bro pid
keep pid fid pid_m pid_f fedu feduy medu meduy wa6code
foreach mm of varlist fid-meduy {
   rename `mm' `mm'_2010
   }

save "$workingdir\ecfps2010child_112014_1.dta",replace


use "$savedir\cfps2012child_10-15.dta",clear
sort pid
bro pid
save "$workingdir\cfps2012child_10-15.dta",replace

use "$workingdir\cfps2012child_10-15.dta", clear
merge pid using "$workingdir\ecfps2010child_112014_1.dta"
tab _merge,m
drop if _merge==2
bro pid fid10 fid12 if _merge==1
save "$savedir\cfps2012child_10-15_merge_2010child.dta",replace


use "$savedir\cfps2012child_10-15_merge_2010child.dta",clear
tab _merge

***PART 3. keep useful var in adult2012
use "$dtadir\cfps2012adultcombined_092015compress.dta", clear
keep pid fid12 fid10 provcd countyid cid urban12 cfps2011_latest_edu ///
jobc1lastdate_a_1 ///
jobc1lastdate_a_2 jobc1lastdate_a_3 jobc1lastdate_a_4 jobc1lastdate_a_5 ///
jobc1lastdate_a_6 jobc1lastdate_a_7 jobc1lastdate_a_8 jobc1lastdate_a_9 ///
jobc1lastdate_a_10 jobc2lastdate_a_1 jobc2lastdate_a_2 jobc2lastdate_a_3 ///
jobc2lastdate_a_4 jobc2lastdate_a_5 jobc2lastdate_a_6 jobc2lastdate_a_7 ///
jobc2lastdate_a_8 jobc2lastdate_a_9 jobc2lastdate_a_10 jobc1cn qg310ccode ///
qg408ccode_a_1 qg408ccode_a_2 qg408ccode_a_3 qg408ccode_a_4 qg408ccode_a_5 ///
qg408ccode_a_6 qg408ccode_a_7 qg408ccode_a_8 qg408ccode_a_9 qg408ccode_a_10 ///
qg508ccode_a_1 qg508dcode_a_1 qg508ccode_a_2 qg508dcode_a_2 qg508ccode_a_3 ///
qg508dcode_a_3 qg508ccode_a_4 qg508dcode_a_4 qg410code_a_1 qg411code_a_1 ///
qg410code_a_2 qg411code_a_2 qg410code_a_3 qg411code_a_3 qg410code_a_4 ///
qg411code_a_4 qg410code_a_5 qg411code_a_5 qg410code_a_6 qg411code_a_6 ///
qg410code_a_7 qg411code_a_7 qg410code_a_8 qg411code_a_8 qg410code_a_9 ///
qg411code_a_9 qg410code_a_10 qg411code_a_10 qg509code_a_1 qg510code_a_1 ///
qg509code_a_2 qg510code_a_2 qg509code_a_3 qg510code_a_3 qg509code_a_4 ///
qg509code_a_4 qg510code_a_4 qg509code_a_5 qg510code_a_5 qg509code_a_6 ///
qg510code_a_6 qg509code_a_7 qg510code_a_7 qg509code_a_8 qg510code_a_8 ///
qg509code_a_9 qg510code_a_9 qg509code_a_10 qg510code_a_10 qg608code_a_1 ///
qg609code_a_1 qg608code_a_2 qg609code_a_2 qg608code_a_3 qg609code_a_3 ///
qg608code_a_4 qg609code_a_4

save  "$savedir\cfps2012adult.dta" ,replace

***PART 4. merge some information on child2012 from adult2012
****merge father's information
use "$savedir\cfps2012adult.dta" ,clear
foreach mm of varlist pid-qg609code_a_4 {
   rename `mm' `mm'_2012adult_f
   } 
rename  pid_2012adult  pid_f   //aim var in 2012child is pid_f
save "$workingdir\cfps2012adult.dta" ,replace

use "$workingdir\cfps2012adult.dta",clear
sort pid_f
duplicates report pid_f
bro pid_f
save "$workingdir\cfps2012adult.dta" ,replace

use "$savedir\cfps2012child_10-15_merge_2010child.dta",clear
sort pid_f
bro pid_f
duplicates report pid_f
rename _merge _merge1
merge m:1 pid_f using "$workingdir\cfps2012adult.dta"
drop if _merge==2 
save "$savedir\cfps2012child_10-15_merge_2010child_2012adult.dta" ,replace

***merge mother's information
use "$savedir\cfps2012adult.dta" ,clear
foreach mm of varlist pid-qg609code_a_4 {
   rename `mm' `mm'_2012adult_m
   } 
rename  pid_2012adult  pid_m   //aim var in 2012child is pid_f

save "$workingdir\cfps2012adult.dta" ,replace

use "$workingdir\cfps2012adult.dta",clear
sort pid_m
duplicates report pid_m
bro pid_m
save "$workingdir\cfps2012adult.dta" ,replace

use "$savedir\cfps2012child_10-15_merge_2010child.dta",clear
sort pid_m
bro pid_m
duplicates report pid_m
rename _merge _merge2
merge m:1 pid_m using "$workingdir\cfps2012adult.dta"
drop if _merge==2 
save "$savedir\cfps2012child_10-15_merge_2010child_2012adult.dta" ,replace

tab _merge

***PART 5. merge some information on chid2012 from famconf2012
use "$dtadir\Ecfps2012famroster_032015compress.dta",clear
keep pid fid12 fid10 tb4_a12_f tb6_a12_f tb4_a12_m tb6_a12_m 
duplicates tag pid ,gen(dup)
list pid if dup==1
bro pid tb4_a12_f  tb4_a12_m if dup==1  
save  "$savedir\Ecfps2012famroster_032015compress.dta" ,replace

use  "$savedir\Ecfps2012famroster_032015compress.dta" ,clear
foreach mm of varlist fid12-dup {
   rename `mm' `mm'_2012famconf
   } 
sort pid
bro pid
save "$workingdir\Ecfps2012famroster_032015compress.dta" ,replace

use "$savedir\cfps2012child_10-15_merge_2010child_2012adult.dta", clear
sort pid
bro pid
rename _merge  _merge3
merge 1:m pid using "$workingdir\Ecfps2012famroster_032015compress.dta" 
drop if _merge==2
save "$workingdir\cfps2012child_10-15_merge_2010child_2012adult_2012famconf.dta",replace

***clear
use "$workingdir\cfps2012child_10-15_merge_2010child_2012adult_2012famconf.dta",clear
duplicates report pid
sort pid
duplicates tag pid ,gen(dup)
bro pid tb4_a12_f tb4_a12_m if dup==1 
bro pid tb4_a12_f tb4_a12_m if dup==2 
list pid if dup==1

gen x=_n if dup==1
replace x=1 if x==.
keep if mod(x,2)
duplicates report pid
bro

save "$savedir\cfps2012child_10-15_merge_2010child_2012adult_2012famconf.dta", replace
save "$workingdir\cfps2012child_10-15_merge_2010child_2012adult_2012famconf.dta", replace
