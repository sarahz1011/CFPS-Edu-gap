/*------------------------------------------------------------------------------				
*	Goal:			To Prepare variabels for analysis the prescribing 
					of antibiotics

*	Input Data:		1) SP_final_dataset_05102016.dta;
					
*	Output Data:	1) antibiotics_preparing.do
					2) SP_final_dataset_05102016_antibiotics.dta
										
*   Author(s):      Yu Bai
*	Created: 		2016-05-02
*   Last Modified: 	2016-05-31 

------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
 Note: primary steps of this do file
 
------------------------------------------------------------------------------*/
clear all
set more off
capture log close
set maxvar 30000


global rawdata "/Users/Bai/Documents/Papers/Bai/SS & HL - Antibiotics/Antibiotics analysis/Raw data"
global cleaneddata "/Users/Bai/Documents/Papers/Bai/SS & HL - Antibiotics/Antibiotics analysis/Cleaned data"
global results "/Users/Bai/Documents/Papers/Bai/SS & HL - Antibiotics/Antibiotics analysis/Results"
*global rawdata "D:\CEEE\论文写作\抗生素\抗生素现状with白钰\数据\Raw data"
*global cleaneddata "D:\CEEE\论文写作\抗生素\抗生素现状with白钰\数据\Cleaned data"
*global results "D:\CEEE\论文写作\抗生素\抗生素现状with白钰\数据\results"

cd "$rawdata" 
/*
unicode analyze SP_final_dataset_05102016.dta
unicode encoding set GB18030
unicode retranslate SP_final_dataset_05102016.dta, transutf8 invalid replace
*/
use "SP_final_dataset_05102016.dta", clear

keep *_f_b_* *_d_b_* *_k_Q8_1 *_k_Q8_2 *_k_Q5_1 ID theta_eap theta_pv1 theta_pv2 ///
	theta_pv3 theta_pv4 theta_pv5 theta_mle theta_mle_se vignette disease level ///
		datainfo datainfo_d datainfo_a datainfo_t doctorid docname citycode cityname ///
		countycode countyname towncode townname villagecode villagename Diarrheaorder ///
		Anginaorder TBorder date month day groupcode MFgrouptype diarrhea_MF SPmale_Diarrhea ///
		SPmale_TB THCorder_first THCorder_second THCorder_third THCordertype THCNoDrug_first ///
		THCNoDrug_second THCNoDrug_third THCNoDrugType THCNoDrugDisease THCNoDrugTime ///
		office_nf desk_nf treatment1 treatment2 treatment3 thcname thc_d_v_id thc_a_v_id ///
		thc_t_v_id thc_d_b_id vc_id clinicname vc_d_v_id vc_a_v_id vc_t_v_id vc_d_b_id ///
		towncode_raw thc_d_b_nobase thc_id patientload VillNoDrug year ///
		thc_d_v_Q9_5 thc_d_v_Q9_6 thc_d_v_Q9_7 thc_d_v_Q9_8 thc_t_v_Q9_5 thc_t_v_Q9_6 ///
		thc_t_v_Q9_7 thc_t_v_Q9_8 thc_a_v_Q9_5 thc_a_v_Q9_6 thc_a_v_Q9_7 thc_a_v_Q9_8 ///
		vc_d_v_Q9_5 vc_d_v_Q9_6 vc_d_v_Q9_7 vc_d_v_Q9_8 vc_a_v_Q9_5 vc_a_v_Q9_6 ///
		vc_a_v_Q9_7 vc_a_v_Q9_8 vc_t_v_Q9_5 vc_t_v_Q9_6 vc_t_v_Q9_7 vc_t_v_Q9_8 ///
		arqe nrqe aeqe corrdiag corrdrug referral tb_m_corr pcorrdrug ///
		thc_d_v_Q2_6 thc_d_v_Q2_6_1 vc_d_v_Q2_6 vc_d_v_Q2_6_1 ch_d_v_Q1_Q2_9 ch_d_v_Q1_Q2_9_1
drop *_f_b_g* *_f_b_h* *_f_b_i* *_f_b_j*
drop vc_f_b_e* vc_f_b_f* 

* merge with the drug data
merge 1:1 ID using "drug_all_docotors.dta"

replace drugpres=0   if drugpres==.
replace numofantib=0 if numofantib==.
replace antibiotic=0 if antibiotic==.

save "SP_final_dataset_05102016_antibiotics.dta", replace
use  "SP_final_dataset_05102016_antibiotics.dta", clear

******************
/* variables for doctor characteristics */
	
	// male
	gen male=thc_d_b_gender if level=="Township"
	replace male=vc_d_b_A1_1 if level=="Village"
	label var male "Male (1=yes; 0=no)"

	// age
	gen birthyear=substr(thc_d_b_birthdate,1,4) if level=="Township"
	destring birthyear,replace
	gen age=2016+1-birthyear if level=="Township"
	gen vc_birthyear=substr(vc_d_b_A1_3,1,4) if vc_d_b_A1_3!="" & vc_d_b_A1_3!=".o" & level=="Village"
	destring vc_birthyear,replace
	replace age=2016+1-vc_birthyear if level=="Village"
	label var age "Age (years)"

	// year of being doctor  ---highly corralated with age
*	rename thc_d_b_a1_9 year
*	replace year=vc_d_b_A1_9 if level=="Village"
*	label var year "How long the doctor worked as a physician?"
*	tab year if droptreat==0 & vignette==0,m

	// college
	gen edu=thc_d_b_a2_11 if level=="Township"
	replace edu=vc_d_b_A2_11 if level=="Village"
	gen college=.
	replace college=1 if edu==5 | edu==6
	replace college=0 if edu!=5 & edu!=6 & edu!=.
	label var college "Got junior college education or higher (1=yes; 0=no)"

	// collegemed  ---highly corralated with hiedu
	gen edumed=thc_d_b_a2_12 if level=="Township"
	replace edumed=vc_d_b_A2_12 if level=="Village"
	gen collegemed=.
	replace collegemed= 1 if edumed==2 | edumed==3
	replace collegemed= 0 if edumed!=2 & edumed!=3 & edumed!=.
	label var collegemed "Got medical junior college education or higher (1=yes; 0=no)"

	// certificate
	gen certi=thc_d_b_a3_19 if level=="Township"
	replace certi=vc_d_b_A3_19 if level=="Village"
	gen certificate=.
	replace certificate=1 if certi==6
	replace certificate=0 if certi!=6 & certi!=.
	label var certificate "Is a practicing physician (1=yes; 0=no)"

	// income
	gen income=vc_f_b_d2_14*vc_d_b_E_17/100000 if level=="Village"	
	replace income=thc_d_b_g_1/1000 if level=="Township"
	label var income "Doctor's income in last year (1000 yuan)"

	// title
	gen title=thc_d_b_a3_21 if level=="Township"
	replace title=vc_d_b_A3_20 if level=="Village"
	gen title_dummy=.
	replace title_dummy=1 if title>1 & title<5
	replace title_dummy=0 if title==1
	label var title_dummy "Whether doctor has a formal medical title (1=yes; 0=no)"

	// average time of treating per visit
	gen time=thc_d_b_b_6 if level=="Township"
	replace time=vc_d_b_A3_24 if level=="Village"
	label var time "Average time for diagnosis and treatment per visit (min)"
	
	// visits last week
	gen visitslastweek=thc_d_b_b_5 if level=="Township"  
	replace visitslastweek=vc_f_b_b1_10/4 if level=="Village" // last momths/4=last week
	label var visitslastweek "Total number of visits in last week"
*	tab visitslastweek if droptreat==0 & vignette==0,m //9个空缺值

	// advanced study
	gen advancedstudy=thc_d_b_e_11 if level=="Township" 
	replace advancedstudy=vc_d_b_D_10/4 if level=="Village"
	label var advancedstudy "Had advanced study in last 3 years (1=yes; 0=no)"
*	tab advancedstudy if droptreat==0 & vignette==0,m //12个空缺值

	// otherjob
	gen otherjob=(thc_d_b_b_9==2 | thc_d_b_b_9==4 | thc_d_b_b_9==5) if level=="Township" 
	replace otherjob= vc_d_b_A3_23_1 if level=="Village"
	label var otherjob "Had other jobs (1=yes; 0=no)"
*	tab otherjob if droptreat==0 & vignette==0,m 

	// exam_med (conditional on whether there is an exam for medical service)
	gen exam_med=thc_d_b_f_12 if level=="Township" 
	replace exam_med= vc_d_b_E_8 if level=="Village"
	gen exam_med_d=.
	replace exam_med_d=1 if exam_med==1
	replace exam_med_d=0 if exam_med==2 | exam_med==3
	label var exam_med "Is doctor's medical examination results excellent? (1=yes; 0=no)"
*	tab exam_med if droptreat==0&vignette==0,m //132 no exam，4 missing conditional on exam

	// exam_anti,(conditional on whether there is an exam for antibiotic use)
	gen exam_anti=thc_d_b_f_16 if level=="Township" 
	replace exam_anti= vc_d_b_E_11 if level=="Village"
	label var exam_anti "Has the doctor been examined for their perscription of antibiotic use (1=yes; 0=no)"
	tab exam_anti,m
	replace exam_anti=0 if exam_anti==.
*	tab exam_anti if droptreat==0 & vignette==0,m //90 missing

	//correct diagnose rate
	tab corrdiag,m
	gen diag=1 if vignette!=.
	replace diag=0 if vignette==.
	bysort doctorid:egen diag_num=sum(diag) if vignette!=.
	bysort doctorid:egen corrdiag_num=sum(corrdiag) if vignette!=.
	tab diag_num,m
	*tab corrdiag_num,m
	gen corrdiag_rate=corrdiag_num/diag_num
	*tab corrdiag_rate,m
	label var corrdiag_rate "The correct diagnose rate for a doctor"
	
	//correct treatment
	tab thc_d_v_Q2_6 thc_d_v_Q2_6_1 if level=="Township" & vignette==0 & disease=="D",m
	list ID drugpres referral thc_d_v_Q2_6_1 if level=="Township" & vignette==0 & disease=="D" & thc_d_v_Q2_6==1
	tab vc_d_v_Q2_6 vc_d_v_Q2_6_1 if level=="Village" & vignette==0 & disease=="D",m
	list ID drugpres referral vc_d_v_Q2_6_1 if level=="Village" & vignette==0 & disease=="D" & vc_d_v_Q2_6==1
	tab ch_d_v_Q1_Q2_9 ch_d_v_Q1_Q2_9_1 if level=="County" & vignette==0 & disease=="D",m
	list ID drugpres referral ch_d_v_Q1_Q2_9_1 if level=="County" & vignette==0 & disease=="D" & ch_d_v_Q1_Q2_9==1
	
	gen childcome=1 if thc_d_v_Q2_6_1==1 |thc_d_v_Q2_6_1==2
	replace childcome=1 if vc_d_v_Q2_6_1==1 |vc_d_v_Q2_6_1==2
	replace childcome=1 if ch_d_v_Q1_Q2_9_1==1
	replace childcome=0 if childcome!=1 & vignette==0 & disease=="D"
	tab childcome,m
	label var childcome "Doctor asked the child to come or see local doctors"

	gen corrtreat=corrdrug if disease=="D" & vignette!=.
	replace corrtreat=1 if (corrdrug==1|referral==1) & disease=="A" & vignette!=.
	replace corrtreat=0 if corrtreat!=1 & disease=="A" & vignette!=.
	
	*tab corrdrug referral if disease=="A" 
	*tab corrtreat disease // double check
	*tab corrdrug corrtreat if disease=="D"
	
	gen pcorrtreat=1 if (pcorrdrug==1|childcome==1) & disease=="D"
	replace pcorrtreat=1 if (pcorrdrug==1|referral==1) & disease=="A"
	replace pcorrtreat=0 if pcorrtreat!=1
	
	label var corrtreat  "Correct treatment for Diarrhea/Angina"
	label var pcorrtreat "Correct or partly correct treatment for Diarrhea/Angina"
	
	gen corrtreat_raw=corrtreat
	replace corrtreat=1 if tb_m_corr==1
	replace corrtreat=0 if tb_m_corr==0
	tab corrtreat,m
	label var corrtreat_raw  "Correct treatment for Diarrhea/Angina"
	label var corrtreat  "Correct treatment/management for Diarrhea/Angina/Tuberculosis (1=yes; 0=no)"
	* pcorrtreat don't contain T (Won't use pcorrtreat as an indicator of doctor quality)
	
	bysort doctorid:egen corrtreat_num=sum(corrtreat) if vignette!=.
	*tab corrtreat_num,m
	gen corrtreat_rate=corrtreat_num/diag_num
	*tab corrtreat_rate,m
	label var corrtreat_rate "The correct treatment rate for a doctor"

/* variables for facility characteristics */
	//outpatient load per year
	tab thc_f_b_b03,m
	gen outpatient=thc_f_b_b03 if level=="Township"
	replace outpatient=vc_f_b_b1_10*12 if level=="Village"
	replace outpatient=outpatient/1000
	label var outpatient "No. of Outpatient (1000/year)"
	
	//The num of hospital bed //Village clinics had no bed
	gen hosbed=thc_f_b_b09 if level=="Township"
	tab hosbed,m
	replace hosbed=0 if thc_f_b_b08==2 & level=="Township"
	replace hosbed=0 if level=="Village"
	label var hosbed "The num of hospital bed"
*	tab hosbed if droptreat==0 & vignette==0,m
	
	//The number of staff
	gen staffnum=thc_f_b_e01 if level=="Township"
	tab vc_f_b_a_1,m
	replace staffnum=vc_f_b_a_1 if level=="Village"
	label var staffnum "The number of staff"
*	tab staffnum if droptreat==0 & vignette==0,m
	
	//total value of shebei
*	histogram vc_f_b_d1_3, normal 
	count if vc_f_b_d1_3>45000 & vc_f_b_d1_3!=.
	gen equipment=thc_f_b_f02 if level=="Township" & thc_f_b_f02<=400 
	replace equipment=vc_f_b_d1_3/10000 if level=="Village"
	label var equipment "Total value of equipment (10k RMB)"
*	tab equipment if droptreat==0 & vignette==0,m //12 missing
	
    //facility income peryear
	tab thc_f_b_f04,m
	gen fincome=thc_f_b_f04 if level=="Township"
	replace fincome=vc_f_b_d2_6 if level=="Village"
	label var fincome "facility income peryear"
*	tab fincome if droptreat==0 & vignette==0,m //1 missing

	label var vignette "Vignettes (1=yes; 0=no)"
	label var antibiotic "Did this doctor prescibe antibiotics (1=yes; 0=no)"
	label var doctorid "Doctor id"
	
*   Before analysis, we need to "drop" treatment of NoDrug 
*	tab THCNoDrugType disease,m
	gen droptreat=0
		replace droptreat=1 if (disease=="D" & THCNoDrugType==1) | ///
							   (disease=="D" & THCNoDrugType==2) | ///
							   (disease=="A" & THCNoDrugType==3) | ///
							   (disease=="A" & THCNoDrugType==4) 
		replace droptreat=1 if VillNoDrug=="一开始"
							 * (disease=="" & VillNoDrug=="")
		replace droptreat=1 if vignette==.   // rule
		replace droptreat=1 if level=="County"
	
	tab droptreat,m
	drop if droptreat==1
	
	* match SP visits and vignettes
	bysort doctorid disease: gen X=_N
	count if X==1
	drop if X==1
	drop X
	
	* Deal with missing: replace missing values with means
	global doctor age year college collegemed male certificate income title_dummy
	global facilites outpatient
	replace outpatient=. if outpatient==.o   // unique mv codes:  1    missing .*:  4/1,078
	foreach var of varlist $doctor $facilites {
		egen `var'_mean=mean(`var')
		replace `var'=`var'_mean if `var'==.
	}
save "SP_final_dataset_05102016_antibiotics.dta", replace

* merge with RULE data
use  "SP_final_dataset_05102016.dta", clear
keep if vignette==.
keep doctorid level disease thc_d_i_* vc_d_i_* thc_a_i_* vc_a_i_* thc_t_i_* vc_t_i_*
gen D_num=0
foreach x of numlist 1/11{
gen D`x'=""
gen D`x'a=.
gen thc_t_i_D`x'=thc_t_i_distypeD`x'
gen vc_a_i_D`x'=vc_a_i_distypeD`x'
gen vc_a_i_D`x'a=vc_a_i_distypeD`x'a
replace D`x'=thc_d_i_D`x' if level=="Township" & disease=="D"
replace D`x'=thc_a_i_D`x' if level=="Township" & disease=="A"
tostring thc_t_i_D11,replace
replace D`x'=thc_t_i_D`x' if level=="Township" & disease=="T"
replace D`x'=vc_d_i_D`x' if level=="Village" & disease=="D"
replace D`x'=vc_a_i_D`x' if level=="Village" & disease=="A"
replace D`x'=vc_t_i_D`x' if level=="Village" & disease=="T"
replace D`x'a=thc_d_i_D`x'a if level=="Township" & disease=="D"
replace D`x'a=thc_a_i_D`x'a if level=="Township" & disease=="A"
destring thc_t_i_D11,replace
replace D`x'a=thc_t_i_D`x'a if level=="Township" & disease=="T"
replace D`x'a=vc_d_i_D`x'a if level=="Village" & disease=="D"
replace D`x'a=vc_a_i_D`x'a if level=="Village" & disease=="A"
replace D`x'a=vc_t_i_D`x'a if level=="Village" & disease=="T"
tab D`x',m
replace D_num=D_num+1 if D`x'!=""&D`x'!="."
}
gen D12=""
gen D12a=.
replace D12=thc_a_i_D12 if level=="Township" & disease=="A"
replace D12a=thc_a_i_D12a if level=="Township" & disease=="A"
replace D_num=D_num+1 if D12!=""&D12!="."
tab D_num,m
keep D* doctorid level disease
save "sp_rule.dta",replace

use  "SP_final_dataset_05102016_antibiotics.dta", clear
drop _merge
merge n:1 doctorid disease using "sp_rule.dta"
drop if _merge==2
rename _merge _merge_rule
recode _merge_rule (1=0)(3=1)
label var _merge_rule "Whether it's a rule data (1=yes; 0=no)"

save "SP_final_dataset_05102016_antibiotics.dta",replace

* Considering muscle needle and intravenous injections (IV)
* Basic idea: if iv_antibiotic=1 then antibiotic=1; if iv=1 then drugpres=1
*			  So does muscle needle

gen musleneedle=.
replace musleneedle=thc_d_v_Q9_5 if vignette==0 & level=="Township" & disease=="D"
replace musleneedle=thc_a_v_Q9_5 if vignette==0 & level=="Township" & disease=="A"
replace musleneedle=thc_t_v_Q9_5 if vignette==0 & level=="Township" & disease=="T"
replace musleneedle=vc_d_v_Q9_5 if vignette==0 & level=="Village" & disease=="D"
replace musleneedle=vc_a_v_Q9_5 if vignette==0 & level=="Village" & disease=="A"
replace musleneedle=vc_t_v_Q9_5 if vignette==0 & level=="Village" & disease=="T"
label var musleneedle "Whether the doctor gave muscle needle"
tab musleneedle if droptreat==0 & vignette==0,m

gen mn_drug=""
tostring thc_d_v_Q9_6,replace
tostring thc_a_v_Q9_6,replace
tostring thc_t_v_Q9_6,replace
tostring vc_d_v_Q9_6,replace
tostring vc_a_v_Q9_6,replace
tostring vc_t_v_Q9_6,replace
replace mn_drug=thc_d_v_Q9_6 if vignette==0 & level=="Township" & disease=="D"
replace mn_drug=thc_a_v_Q9_6 if vignette==0 & level=="Township" & disease=="A"
replace mn_drug=thc_t_v_Q9_6 if vignette==0 & level=="Township" & disease=="T"
replace mn_drug=vc_d_v_Q9_6 if vignette==0 & level=="Village" & disease=="D"
replace mn_drug=vc_a_v_Q9_6 if vignette==0 & level=="Village" & disease=="A"
replace mn_drug=vc_t_v_Q9_6 if vignette==0 & level=="Village" & disease=="T"
label var mn_drug "Drug of muscle needle"
tab mn_drug if droptreat==0 & vignette==0,m

list musleneedle mn_drug if musleneedle==1
gen mn_antibiotic=1 if regexm(mn_drug,"消炎")|regexm(mn_drug,"先锋")|regexm(mn_drug,"素")
replace mn_antibiotic=0 if mn_antibiotic==. & musleneedle==1
list musleneedle mn_drug mn_antibiotic if musleneedle==1

gen iv=.
replace iv=thc_d_v_Q9_7 if vignette==0 & level=="Township" & disease=="D"
replace iv=thc_a_v_Q9_7 if vignette==0 & level=="Township" & disease=="A"
replace iv=thc_t_v_Q9_7 if vignette==0 & level=="Township" & disease=="T"
replace iv=vc_d_v_Q9_7 if vignette==0 & level=="Village" & disease=="D"
replace iv=vc_a_v_Q9_7 if vignette==0 & level=="Village" & disease=="A"
replace iv=vc_t_v_Q9_7 if vignette==0 & level=="Village" & disease=="T"
label var iv "Whether the doctor gave intravenous injections (IV)"
tab iv if droptreat==0 & vignette==0,m

gen iv_drug=""
tostring thc_d_v_Q9_8,replace
tostring thc_a_v_Q9_8,replace
tostring thc_t_v_Q9_8,replace
tostring vc_d_v_Q9_8,replace
tostring vc_a_v_Q9_8,replace
tostring vc_t_v_Q9_8,replace
replace iv_drug=thc_d_v_Q9_8 if vignette==0 & level=="Township" & disease=="D"
replace iv_drug=thc_a_v_Q9_8 if vignette==0 & level=="Township" & disease=="A"
replace iv_drug=thc_t_v_Q9_8 if vignette==0 & level=="Township" & disease=="T"
replace iv_drug=vc_d_v_Q9_8 if vignette==0 & level=="Village" & disease=="D"
replace iv_drug=vc_a_v_Q9_8 if vignette==0 & level=="Village" & disease=="A"
replace iv_drug=vc_t_v_Q9_8 if vignette==0 & level=="Village" & disease=="T"
label var iv_drug "The drug of iv"
tab iv_drug if droptreat==0 & vignette==0,m

list iv iv_drug if iv==1
gen iv_antibiotic=1 if regexm(iv_drug,"消炎")|regexm(iv_drug,"阿莫西林")|regexm(iv_drug,"素")|regexm(iv_drug,"头孢")
replace iv_antibiotic=0 if iv_antibiotic==. & iv==1
list iv iv_drug iv_antibiotic if iv==1

*list ID antibiotic mn_antibiotic drugpres musleneedle mn_drug  if musleneedle==1
*list ID antibiotic iv_antibiotic drugpres iv iv_drug  if iv==1 
*br ID antibiotic mn_antibiotic drugpres musleneedle mn_drug  if musleneedle==1
*br ID antibiotic iv_antibiotic drugpres iv iv_drug  if iv==1
tab ATC_notclear_num,m //2个属于township,一个vignette，一个visit
replace ATC_notclear_num=0 if ATC_notclear_num==.
list ATC_notclear_num antibiotic if ATC_notclear_num==1
replace ATC_notclear_num=ATC_notclear_num+ATC_J01C_num if ATC_J01C_num!=0 & ATC_J01C_num!=.
replace ATC_notclear_num=ATC_notclear_num+ATC_J01D_num if ATC_J01D_num!=0 & ATC_J01D_num!=.
replace ATC_notclear_num=ATC_notclear_num+1 if regexm(iv_drug,"消炎")| regexm(mn_drug,"消炎")
gen antibiotic_raw = antibiotic
label var antibiotic_raw "whether prescribed any antibiotics (ignore Intravenous injections or muscle needle)"
replace antibiotic=1 if antibiotic==0 & (iv_antibiotic==1 | mn_antibiotic==1)
replace drugpres=1 if drugpres==0 & (iv==1 | musleneedle==1)
list ATC_notclear_num antibiotic if ATC_notclear_num==1
replace numofantib=1 if ATC_notclear_num==1 & antibiotic==0 & numofantib==0
replace antibiotic=1 if ATC_notclear_num==1
gen numofdrug_raw=numofdrug
gen numofantib_raw=numofantib

* 
tab mn_drug,m
split mn_drug,p(" ")
tab mn_drug1,m
replace ATC_J01GB03_num=ATC_J01GB03_num+1 if regexm(mn_drug1,"庆大霉素")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(mn_drug1,"庆大霉素")
replace ATC_J01C_num=ATC_J01C_num+1 if regexm(mn_drug1,"青霉素")
replace ATC_J01DB04_num=ATC_J01DB04_num+1 if regexm(mn_drug1,"先锋五号")
replace narrow_spectrum_num=narrow_spectrum_num+1 if regexm(mn_drug1,"先锋五号")
tab mn_drug2,m
replace ATC_J01GB03_num=ATC_J01GB03_num+1 if regexm(mn_drug2,"庆大霉素")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(mn_drug2,"庆大霉素")
*list ID mn_drug numofdrug numofantib mn_antibiotic if mn_drug!="" & mn_drug!="."
replace numofdrug=numofdrug+1 if mn_drug!="" & mn_drug!="." & ID!="SPV_T2708101"
replace numofdrug=numofdrug+1 if ID=="SPV_D2102101"
replace numofantib=numofantib+1 if mn_antibiotic==1
*list ID mn_drug numofdrug numofantib mn_antibiotic if mn_drug!="" & mn_drug!="."
 
tab iv_drug,m
*list ID iv_drug if iv_drug!=""
split iv_drug,p(",")
tab iv_drug1,m
replace ATC_J01FA10_num=ATC_J01FA10_num+1 if regexm(iv_drug,"阿奇霉素")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"阿奇霉素")
replace ATC_J01CA04_num=ATC_J01CA04_num+1 if strmatch(iv_drug1,"*阿莫西林")
replace broad_spectrum_num=broad_spectrum_num+1 if strmatch(iv_drug1,"*阿莫西林")
replace ATC_J01FA01_num=ATC_J01FA01_num+1 if regexm(iv_drug,"红霉素")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"红霉素")
replace ATC_J01C_num=ATC_J01C_num+1 if regexm(iv_drug,"青霉素")
replace ATC_J01CA10_num=ATC_J01CA10_num+1 if regexm(iv_drug,"美洛西林")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"美洛西林")
replace ATC_J01FF01_num=ATC_J01FF01_num+1 if regexm(iv_drug,"克林霉素")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"克林霉素")
replace ATC_J01DD04_num=ATC_J01DD04_num+1 if regexm(iv_drug,"头孢曲松")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"头孢曲松")
replace ATC_J01D_num=ATC_J01D_num+1 if strmatch(iv_drug1,"头孢")
replace ATC_J01D_num=ATC_J01D_num+1 if strmatch(iv_drug1,"头孢消炎的*")
replace ATC_J01GB06_num=ATC_J01GB06_num+1 if regexm(iv_drug,"阿米卡")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"阿米卡")

 list ID iv_drug1 numofdrug numofantib iv_antibiotic if iv_drug1!="" & ///
 iv_drug1!="." & iv_drug1!=".n" & iv_drug1!="999"
 count if iv_drug1!="" & iv_drug1!="." & iv_drug1!=".n" & iv_drug1!="999"
 replace numofdrug=numofdrug+1 if iv_drug1!="" & iv_drug1!="." & iv_drug1!=".n" & ///
  iv_drug1!="999" & numofdrug!=. & ID!="SPV_T230405" & ID!="SPV_T250306" & ID!="SPV_T250910" & ///
  ID!="SPV_T260502" & ID!="SPV_D260201" & ID!="SPV_T311001" & ID!="SPV_D320901" & ///
  ID!="SPV_T2302201" & ID!="SPV_T2309201" & ID!="SPV_T2708101"
 replace numofdrug=1 if iv_drug1!="" & iv_drug1!="." & iv_drug1!=".n" & ///
  iv_drug1!="999" & numofdrug==. & ID!="SPV_T230405" & ID!="SPV_T250306" & ID!="SPV_T250910" & ///
  ID!="SPV_T260502" & ID!="SPV_D260201" & ID!="SPV_T311001" & ID!="SPV_D320901" & ///
  ID!="SPV_T2302201" & ID!="SPV_T2309201" & ID!="SPV_T2708101"
 replace numofdrug=numofdrug+4 if ID=="SPV_T230405" 
 replace numofdrug=numofdrug+2 if ID=="SPV_T250306" 
 replace numofdrug=numofdrug+2 if ID=="SPV_T250910"
 replace numofdrug=numofdrug+0 if ID=="SPV_T260502"
 replace numofdrug=numofdrug+0 if ID=="SPV_D260201"
 replace numofdrug=numofdrug+0 if ID=="SPV_T311001"
 replace numofdrug=numofdrug+2 if ID=="SPV_D320901" 
 replace numofdrug=numofdrug+6 if ID=="SPV_T2302201"
 replace numofdrug=numofdrug+2 if ID=="SPV_T2309201"
 replace numofdrug=3 if ID=="SPV_T2708101"

 replace numofantib=numofantib+1 if iv_drug1!="" & iv_drug1!="." & iv_drug1!=".n" & ///
  iv_drug1!="999" & ID!="SPV_T230405" & ID!="SPV_T250306" & ID!="SPV_T250910" & ///
  ID!="SPV_T260502" & ID!="SPV_D260201" & ID!="SPV_T311001" & ID!="SPV_D320901" & ///
  ID!="SPV_T2302201" & ID!="SPV_T2309201" & ID!="SPV_T2708101" & ///
  (regexm(iv_drug1,"消炎")|regexm(iv_drug1,"阿莫西林")|regexm(iv_drug1,"素")|regexm(iv_drug1,"头孢")|regexm(iv_drug,"阿米卡"))
 replace numofantib=numofantib+1 if ID=="SPV_T230405"
 replace numofantib=numofantib+1 if ID=="SPV_T250910"
 replace numofantib=numofantib+1 if ID=="SPV_D320901" 
 replace numofantib=numofantib+4 if ID=="SPV_T2302201"
 replace numofantib=numofantib+2 if ID=="SPV_T2309201"
 replace numofantib=numofantib+2 if ID=="SPV_T2708101"
tab iv_drug2,m
replace ATC_J01CG01_num=ATC_J01CG01_num+1 if regexm(iv_drug,"舒巴坦")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"舒巴坦")
replace ATC_J01D_num=ATC_J01D_num+1 if strmatch(iv_drug2,"头孢")
replace ATC_J01DD51_num=ATC_J01DD51_num+1 if regexm(iv_drug,"噻肟")
replace  broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"噻肟")
 list ID iv_drug2 numofdrug numofantib iv_antibiotic if iv_drug2!="" & ///
 iv_drug2!="." & iv_drug2!=".n" & iv_drug2!="999"
 count if iv_drug2!="" & iv_drug2!="." & iv_drug2!=".n" & iv_drug2!="999"
 replace numofdrug=numofdrug+1 if iv_drug2!="" & iv_drug2!="." & iv_drug2!=".n" ///
 & iv_drug2!="999" & ID!="SPV_A240902" & ID!="SPV_T260502"
 replace numofdrug=numofdrug+4 if ID=="SPV_A240902"
 replace numofdrug=numofdrug+0 if ID=="SPV_T260502"
 replace numofantib=numofantib+1 if iv_drug2!="" & iv_drug2!="." & iv_drug2!=".n" ///
 & iv_drug2!="999"  & (regexm(iv_drug2,"舒巴坦")|strmatch(iv_drug2,"头孢")|regexm(iv_drug2,"噻肟")|regexm(iv_drug2,"素"))
 

tab iv_drug3,m
replace ATC_J01DD52_num=ATC_J01DD52_num+1 if regexm(iv_drug,"头孢他")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"头孢他")
replace ATC_J01DC02_num=ATC_J01DC02_num+1 if regexm(iv_drug,"呋辛")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"呋辛")
tab iv_drug4,m
replace ATC_J01CR02_num=ATC_J01CR02_num+1 if regexm(iv_drug,"阿莫西林钠克拉")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"阿莫西林钠克拉")
tab iv_drug5,m
tab iv_drug6,m
gen ATC_J01XD03_num=.
replace ATC_J01XD03_num=1 if regexm(iv_drug,"奥硝")
replace broad_spectrum_num=broad_spectrum_num+1 if regexm(iv_drug,"奥硝")

list ID iv_drug3 numofdrug numofantib iv_antibiotic if iv_drug3!=""
 replace numofdrug=numofdrug+1 if iv_drug3!="" & ID!="SPV_T260502"
 replace numofantib=numofantib+1 if regexm(iv_drug3,"奥硝") | regexm(iv_drug3,"头孢") | regexm(iv_drug,"呋辛")
 list ID iv_drug4 numofdrug numofantib iv_antibiotic if iv_drug4!=""
 replace numofdrug=numofdrug+1 if iv_drug4!=""
 replace numofantib=numofantib+1 if regexm(iv_drug4,"阿莫西林")
 list ID iv_drug5 numofdrug numofantib iv_antibiotic if iv_drug5!=""
 replace numofdrug=numofdrug+1 if iv_drug5!=""
 replace numofantib=numofantib+1 if regexm(iv_drug5,"阿奇霉素")
 list ID iv_drug6 numofdrug numofantib iv_antibiotic if iv_drug6!=""
 replace numofdrug=numofdrug+1 if iv_drug6!=""
 replace numofantib=numofantib+1 if regexm(iv_drug6,"奥硝")
 

save "SP_final_dataset_05102016_antibiotics.dta",replace

* The End *

