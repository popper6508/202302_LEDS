**** 2023-2학기 노동경제학과 데이터사이언스 기말 프로젝트 코드 ****

cd "C:\Users\Popperkim\OneDrive\바탕 화면\Data Analysis Program\202302_LE_and_Datascience\Final_Assignment"

use WPS_W8_V10, clear

keep if year <= 2011 & year > 2005

*** 필요한 변수만 뽑아서 저장
keep id year ind9 w_age epq1011 epq5028 epq9018 pq1002 epq7014 cpi fpq2002 fpq2006 fpq2008 fpq3004 fpq4009 fpq4010 aq1001 aq1004 aq1005 aq2001 aq2901 aq2005 aq3008 fpq3002 fpq5001 fpq2001 dq2001 dq2002 dq2003 dq2010 epq5038 epq3905 aq3009

rename (id year ind9 w_age epq1011 epq5028 epq9018 pq1002 epq7014 cpi fpq2002 fpq2006 fpq2008 fpq3004 fpq4009 fpq4010 aq1001 aq1004 aq1005 aq2001 aq2901 aq2005 aq3008 fpq3002 fpq5001 fpq2001 dq2001 dq2002 dq2003 dq2010 epq5038 epq3905 aq3009) (id year 산업분류 사업체업력 전체근로자 기간제근로자 파견합계 노동조합조직형태 전체조합원 cpi 당기매출액 급여총액 복리후생비 인건비 연초기계장치 연말기계장치 단독다수사업장 국내사업장수 국외사업장수 조직유형 기업경영체제 외국인지분율 주력제품경쟁강도 퇴직급여 총인건비 매출액 표준화 단순반복 자동화 다기능교육훈련비중 파트타임전체 정규직주요직종 주력제품수요)

tab 산업분류
su 전체근로자, d

tab year

*** 기초 통계 꼼꼼하게 검토하기

bys year : su 자동화

tab 자동화

count if year==2007 & 전체근로자 < 300 & 자동화!=. & 단독다수사업장==1

*** 300인 이상 사업체 및 필수 항목에 응답한 사업체를 골라내는 작업
reshape wide (산업분류 사업체업력 전체근로자 기간제근로자 파견합계 노동조합조직형태 전체조합원 cpi 당기매출액 급여총액 복리후생비 인건비 연초기계장치 연말기계장치 단독다수사업장 국내사업장수 국외사업장수 조직유형 기업경영체제 외국인지분율 주력제품경쟁강도 퇴직급여 총인건비 매출액 표준화 단순반복 자동화 다기능교육훈련비중 파트타임전체 정규직주요직종 주력제품수요), i(id) j(year)

drop if (산업분류2007 == .) | (산업분류2009 == .) | (산업분류2011 == .)

drop if (자동화2007 == .) | (자동화2009 == .) | (자동화2011 == .)

su 전체근로자2007, d

drop if 전체근로자2007 >= 300 & 단독다수사업장2007 == 1

count if 단독다수사업장2007 == 2

su 국내사업장수2007, d

gen 사업장수_2007 = 국내사업장수2007 + 국외사업장수2007

su 사업장수_2007, d

gen 사업장별근로자_2007 = 전체근로자2007/사업장수_2007

drop if 사업장별근로자_2007 >= 300 & 단독다수사업장2007 == 2

tab 단독다수사업장2007

count if 기간제근로자2007 >= 전체근로자2007

gen 보호대상비율2007 = (파견합계2007 + 기간제근로자2007 + 파트타임전체2007)/(전체근로자2007)

su 보호대상비율2007, d

drop 보호대상비율2007

gen 보호대상비율2007 = (파견합계2007 + 기간제근로자2007 + 파트타임전체2007)/(전체근로자2007 + 파견합계2007)

gen 보호대상합계2007 = (파견합계2007 + 기간제근로자2007 + 파트타임전체2007)

su 보호대상비율2007, d

gen 표준화_2007 = 표준화2007
gen 단순반복_2007 = 단순반복2007

save wps_사업체별_조사대상, replace

** 조사 대상 사업체 데이터 분석

tab 노동조합조직형태2007

gen 제조업 = (산업분류2007 >= 10) & (산업분류2007 <= 33)

tab 제조업

reg 자동화2007 제조업

hist 자동화2007, by(제조업)

bys 제조업 : su 자동화2007
ttest 자동화2007, by(제조업) // t-test 시에 제조업인지 아닌지에 따른 차이가 두드러진다. 따라서 통제변수 포함.

// 519개 사업체

** 패널데이터 변환 후 자동화와 비정규직 보호법 간의 관게 분석

reshape long 산업분류 사업체업력 전체근로자 기간제근로자 파견합계 노동조합조직형태 전체조합원 cpi 당기매출액 급여총액 복리후생비 인건비 연초기계장치 연말기계장치 단독다수사업장 국내사업장수 국외사업장수 조직유형 기업경영체제 외국인지분율 주력제품경쟁강도 퇴직급여 총인건비 매출액 표준화 단순반복 자동화 다기능교육훈련비중 파트타임전체 정규직주요직종 주력제품수요, i(id) j(year)

br

save wps_data_all, replace

*** 한국은행 GDP 성장률 데이터 전처리
import delimited "GDP_growth_rate_BOK.csv", clear

// 전처리 후 저장
save gdp_growth, replace

*** 필요한 변수만 변수명 변환하여 저장한 전국사업체조사 데이터 import
use wps_data_all, clear

gen afterlaw1 = (year!=2007)

replace 노동조합조직형태 = 0 if 노동조합조직형태==.

tab year
tab 주력제품경쟁강도

reg 자동화 주력제품경쟁강도

ttest 자동화, by(afterlaw1)

tab 단독다수사업장
tab 조직유형
tab 기업경영체제
tab 노동조합조직형태
tab 정규직주요직종

** 통제에 필요한 더미변수 처리
gen 노동조합원비율 = 전체조합원/전체근로자
gen 단독사업장 = (단독다수사업장==1)
// 다수사업장 = (단독다수사업장==2)
gen 개인사업장 = (조직유형==1)
gen 회사법인 = (조직유형==2)
gen 학교의료법인 = (조직유형==3)
// 회사이외법인 = (조직유형==4)
gen 소유경영체제 = (기업경영체제==1)
gen 소유주중심 = (기업경영체제==2)
gen 주요경영문제결정권소유주 = (기업경영체제==3)
gen 전문경영인 = (기업경영체제==4)
// 기타경영체제 = (기업경영체제==97)
gen 기업별노동조합 = (노동조합조직형태 == 1)
gen 산업별노동조합 = (노동조합조직형태 == 2)
gen 지역별노동조합 = (노동조합조직형태 == 3)
gen 기타노동조합형태 = (노동조합조직형태 == 4)
// 무노조혹은무응답 = (노동조합조직형태 == 5)
gen 정규직_관리직 = (정규직주요직종==1)
gen 정규직_전문직 = (정규직주요직종==2)
gen 정규직_기술직 = (정규직주요직종==3)
gen 정규직_사무직 = (정규직주요직종==4)
gen 정규직_서비스직 = (정규직주요직종==5)
gen 정규직_판매직 = (정규직주요직종==6)
// gen 정규직_농임어엽숙련직 = (정규직주요직종==7)
gen 정규직_생산직 = (정규직주요직종==8)
// gen 정규직_단순직 = (정규직주요직종==9)

** 분석에 필요한 교호항 생성
gen after_treat1 = afterlaw1*보호대상비율2007
gen manu_treat1 = 제조업*보호대상비율2007
gen after_manu1 = 제조업*afterlaw1
gen after_manu_treat1 = 제조업*afterlaw1*보호대상비율2007

gen 단순반복_after_treat = afterlaw1*단순반복_2007*보호대상비율2007
gen 단순반복_after = afterlaw1*단순반복_2007
gen 단순반복_treat = 보호대상비율2007*단순반복_2007

graph bar (mean) 자동화, over(afterlaw1)

** 기초통계 확인
label define afterlaw1_labels 0 "전" 1 "후"
label values afterlaw1 afterlaw1_labels

label define 제조업_label 0 "서비스업" 1 "제조업"
label values 제조업 제조업_label

graph bar (mean) 자동화, over(afterlaw1) ///
    title("자동화 비중 변화") ///
    ylabel(, format(%9.0g) labsize(vsmall)) ///
    ytitle("자동화 비중 평균") ///
    blabel(bar, position(outside) format(%9.2f) size(medium)) ///
	plotregion(margin(large))

graph bar (mean) 자동화, over(afterlaw1) over(단순반복_2007) ///
    title("2007년 단순반복 업무 비중에 따른 자동화 비중 변화") ///
    ylabel(, format(%9.0g) labsize(vsmall)) ///
    ytitle("자동화 비중 평균") ///
    blabel(bar, position(outside) format(%9.2f) size(medium)) ///
	plotregion(margin(large))

graph bar (mean) 자동화, over(year) ///
    title("연도별 자동화 비중 변화") ///
    ylabel(, format(%9.0g) labsize(vsmall)) ///
    ytitle("자동화 비중 평균") ///
    blabel(bar, position(outside) format(%9.2f) size(medium)) ///
	plotregion(margin(large))
	
graph bar (mean) 자동화, over(afterlaw1) over(제조업) ///
    title("산업별 자동화 비중 변화") ///
    ylabel(, format(%9.0g) labsize(vsmall)) ///
    ytitle("자동화 비중 평균") ///
    blabel(bar, position(outside) format(%9.2f) size(medium)) ///
	plotregion(margin(large))

tab 단순반복_2007

merge n:1 year using "gdp_growth" // GDP 성장률 데이터와 사업체 데이터 병합

drop if year>=2013
drop if year!=2007&year!=2009&year!=2011 // 병합 후 불필요한 데이터 제거

gen treat_gdp = 보호대상비율2007*gdp_g

save wps_need_data, replace

tab year

tab 제조업

** 순서형 종속변수 회귀분석 진행
// reg (자동화) (보호대상비율2007 afterlaw1 제조업 after_treat1 manu_treat1 after_manu1 after_manu_treat1 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 treat_gdp 주력제품경쟁강도 gdp_g 표준화_2007 단순반복_2007 정규직_관리직 정규직_사무직 정규직_생산직 정규직_서비스직 정규직_전문직 정규직_판매직 주력제품수요)
//
// ologit (자동화) (보호대상비율2007 afterlaw1 제조업 after_treat1 manu_treat1 after_manu1 after_manu_treat1 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 treat_gdp 주력제품경쟁강도 gdp_g 표준화_2007 단순반복_2007 정규직_관리직 정규직_사무직 정규직_생산직 정규직_서비스직 정규직_전문직 정규직_판매직 주력제품수요)

regress (자동화) (보호대상비율2007 afterlaw1 after_treat1 제조업 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 treat_gdp 주력제품경쟁강도 gdp_g 표준화_2007 정규직_관리직 정규직_사무직 정규직_생산직 정규직_서비스직 정규직_전문직 정규직_판매직 주력제품수요)

ologit (자동화) (보호대상비율2007 afterlaw1 after_treat1 제조업 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 treat_gdp 주력제품경쟁강도 gdp_g 표준화_2007 단순반복_2007 정규직_관리직 정규직_사무직 정규직_생산직 정규직_서비스직 정규직_전문직 정규직_판매직 주력제품수요)

** Excel로 결과 저장 1
ssc install estout
ssc install outreg2
ssc install xml_tab

outreg2 using table1.xls, replace

reg (자동화) (보호대상비율2007 afterlaw1 after_treat1 단순반복_2007 단순반복_after_treat 단순반복_after 단순반복_treat 제조업 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 treat_gdp 주력제품경쟁강도 gdp_g 정규직_관리직 정규직_사무직 정규직_생산직 정규직_서비스직 정규직_전문직 정규직_판매직 주력제품수요)

ologit (자동화) (보호대상비율2007 afterlaw1 after_treat1 제조업 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 treat_gdp 주력제품경쟁강도 gdp_g 단순반복_2007 단순반복_after_treat 단순반복_after 단순반복_treat 정규직_관리직 정규직_사무직 정규직_생산직 정규직_서비스직 정규직_전문직 정규직_판매직 주력제품수요)

** Excel로 결과 저장 2
eststo m2

outreg2 using table2.xls, replace
