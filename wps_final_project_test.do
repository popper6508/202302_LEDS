cd "C:\Users\Popperkim\OneDrive\바탕 화면\Data Analysis Program\202302_LE_and_Datascience\Final_Assignment"

use WPS_W8_V10, clear

br

keep if year <= 2011

keep id year ind9 w_age epq1001 epq5028 epq9018 pq1002 epq7014 cpi fpq2002 fpq2006 fpq2008 fpq3004 fpq4009 fpq4010 aq1001 aq1004 aq1005 aq2001 aq2901 aq2005 aq3008 fpq3002 fpq5001 fpq2001

rename (id year ind9 w_age epq1001 epq5028 epq9018 pq1002 epq7014 cpi fpq2002 fpq2006 fpq2008 fpq3004 fpq4009 fpq4010 aq1001 aq1004 aq1005 aq2001 aq2901 aq2005 aq3008 fpq3002 fpq5001 fpq2001) (id year 산업분류 사업체업력 전체근로자 기간제근로자 파견합계 노동조합조직형태 전체조합원 cpi 당기매출액 급여총액 복리후생비 인건비 연초기계장치 연말기계장치 단독다수사업장 국내사업장수 국외사업장수 조직유형 기업경영체제 외국인지분율 주력제품경쟁강도 퇴직급여 총인건비 매출액)

reshape wide (산업분류 사업체업력 전체근로자 기간제근로자 파견합계 노동조합조직형태 전체조합원 cpi 당기매출액 급여총액 복리후생비 인건비 연초기계장치 연말기계장치 단독다수사업장 국내사업장수 국외사업장수 조직유형 기업경영체제 외국인지분율 주력제품경쟁강도 퇴직급여 총인건비 매출액), i(id) j(year)

gen 보호대상비율2005 = (파견합계2005 + 기간제근로자2005)/전체근로자2005
gen 보호대상합계2005 = (파견합계2005 + 기간제근로자2005)

reshape long 산업분류 사업체업력 전체근로자 기간제근로자 파견합계 노동조합조직형태 전체조합원 cpi 당기매출액 급여총액 복리후생비 인건비 연초기계장치 연말기계장치 단독다수사업장 국내사업장수 국외사업장수 조직유형 기업경영체제 외국인지분율 주력제품경쟁강도 퇴직급여 총인건비 매출액, i(id) j(year)

save wps_data_all, replace

*** 한국은행 GDP 성장률 데이터 전처리'
import delimited "GDP_growth_rate_BOK.csv", clear

rename (변환 원자료) (year gdp_g)

// 전처리 후 저장
save gdp_growth, replace


*** 전국사업체조사 데이터 import
use wps_data_all, clear

gen afterlaw1 = (year!=2005) // 2005년 제외하고는 모두 1 값을 갖는 변수 생성
gen afterlaw2 = (year!=2005)

replace afterlaw2 = 0 if (전체근로자 < 300 & year==2007) | (전체근로자 < 100 & year==2009) | (전체근로자 < 5 & year==2011) // 사업체 규모별 시행 시기에 따라 1 값을 갖는 변수 생성

drop if 총인건비==.

replace 노동조합조직형태 = 0 if 노동조합조직형태==.

gen 기계장치가액 = (연말기계장치+연초기계장치)/2

drop if 기계장치가액==. // 기계 장치 가액 결측치 경우 제거

tab year
tab 주력제품경쟁강도

// gen 자동화지수2 = 기계장치가액/전체근로자
gen 자동화지수2 = 기계장치가액/총인건비 // 자동화지수 및 보호대상비율 변수 생성
// gen 자동화지수2 = 기계장치가액/보호대상합계2005

** 더미변수 처리
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

gen 제조업 = (산업분류 >= 15) & (산업분류 <= 37)

tab 제조업

** 삼중차분법 변수 생성
gen after_treat1 = afterlaw1*보호대상비율2005
gen manu_treat1 = 제조업*보호대상비율2005
gen after_manu1 = 제조업*afterlaw1
gen after_manu_treat1 = 제조업*afterlaw1*보호대상비율2005

// gen after_treat2 = afterlaw2*보호대상비율2005
// gen manu_treat2 = 제조업*보호대상비율2005
// gen after_manu2 = 제조업*afterlaw2
// gen after_manu_treat2 = 제조업*afterlaw2*보호대상비율2005

drop if after_manu_treat1==.
// |after_manu_treat2==.

** 2005년부터 2011년 데이터를 모두 가진 기업 추리기

reshape wide (산업분류 사업체업력 전체근로자 기간제근로자 파견합계 노동조합조직형태 전체조합원 cpi 당기매출액 급여총액 복리후생비 인건비 연초기계장치 연말기계장치 단독다수사업장 국내사업장수 국외사업장수 조직유형 기업경영체제 외국인지분율 주력제품경쟁강도 퇴직급여 총인건비 매출액 보호대상비율2005 보호대상합계2005 afterlaw1 afterlaw2 기계장치가액 자동화지수2 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 제조업 after_treat1 manu_treat1 after_manu1 after_manu_treat1), i(id) j(year)

drop if (산업분류2005 == .) | (산업분류2007 == .) | (산업분류2009 == .) | (산업분류2011 == .)

reshape long 산업분류 사업체업력 전체근로자 기간제근로자 파견합계 노동조합조직형태 전체조합원 cpi 당기매출액 급여총액 복리후생비 인건비 연초기계장치 연말기계장치 단독다수사업장 국내사업장수 국외사업장수 조직유형 기업경영체제 외국인지분율 주력제품경쟁강도 퇴직급여 총인건비 매출액 보호대상비율2005 보호대상합계2005 afterlaw1 afterlaw2 기계장치가액 자동화지수2 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 제조업 after_treat1 manu_treat1 after_manu1 after_manu_treat1, i(id) j(year)

merge n:1 year using "gdp_growth" // GDP 성장률 데이터와 사업체 데이터 병합

drop if year>=2012
drop if year==2004|year==2006|year==2008|year==2010 // 병합 후 잉여 데이터 제거

gen treat_gdp = 보호대상비율2005*gdp_g

tab year

** 삼중차분법에 따른 회귀분석 진행
// regress (자동화지수1) (보호대상비율2005 afterlaw1 제조업 after_treat1 manu_treat1 after_manu1 after_manu_treat1 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 cpi treat_gdp 주력제품경쟁강도)
// regress (자동화지수1) (보호대상비율2005 afterlaw2 제조업 after_treat1 manu_treat2 after_manu2 after_manu_treat2  노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 cpi treat_gdp 주력제품경쟁강도)

regress (자동화지수2) (보호대상비율2005 afterlaw1 제조업 after_treat1 manu_treat1 after_manu1 after_manu_treat1 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 cpi treat_gdp 주력제품경쟁강도)
// regress (자동화지수2) (보호대상비율2005 afterlaw2 제조업 after_treat1 manu_treat2 after_manu2 after_manu_treat2  노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 cpi treat_gdp 주력제품경쟁강도)

// regress (자동화지수3) (보호대상비율2005 afterlaw1 제조업 after_treat1 manu_treat1 after_manu1 after_manu_treat1 노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 cpi treat_gdp 주력제품경쟁강도)
// regress (자동화지수3) (보호대상비율2005 afterlaw2 제조업 after_treat1 manu_treat2 after_manu2 after_manu_treat2  노동조합원비율 단독사업장 개인사업장 회사법인 학교의료법인 소유경영체제 소유주중심 주요경영문제결정권소유주 전문경영인 기업별노동조합 산업별노동조합 지역별노동조합 기타노동조합형태 cpi treat_gdp 주력제품경쟁강도)

tab year

mean(자동화지수2) if 제조업==1
mean(자동화지수2) if 제조업==0