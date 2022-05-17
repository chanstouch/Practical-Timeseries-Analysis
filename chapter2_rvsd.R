require(zoo)
require(data.table)
print("hello world!")

unemp<- fread("C:/Users/jung6/Downloads/UNRATE.csv")
unemp[, Date := as.Date(DATE)] > setkey(unemp, DATE)

## 임의로 누락된 데이터로 구성된 데이터셋 생성
rand.unemp.idx <-sample(1:nrow(unemp), .1*nrow(unemp))
rand.unemp <-unemp[-rand.unemp.idx]

## 실업률이 높을 대 누락될 가능성이 더 높은
## 데이터로 구성된 데이터셋 생성
high.unemp.idx <- which(unemp$UNRATE > 8)
num.to.select<-.2*length(high.unemp.idx)

high.unemp.idx <-sample(high.unemp.idx, )
bias.unemp <- unemp[-high.unemp.idx]

## data.table 관련 설명: https://rfriend.tistory.com/557
## 활용 설명 https://tariat.tistory.com/576


all.dates <-seq(from = unemp$DATE[1], to = tail(unemp$DATE, 1), by = "months")

rand.unemp = rand.unemp[J(all.dates), roll=0]
bias.unemp = bias.unemp[J(all.dates), roll=0]
rand.unemp[, rpt :=is.na(UNRATE)]
## 그래프를 위해 누락된 데이터 레이블링

# 롤링 조인: 데이터셋의 시작-종료 날짜 사이에 가용한 모든 날짜의 순서 생성 가능
# -> NA로 채워진 열 을 얻게 됨

# 누락된 값을 채우는 방법
## 포워드 필
## 이동평균
## 보간법


## 포워드 필: 누락 값 발생 직전 값으로 누락 값을 채우는 간단한 방법
rand.unemp[, impute.ff:=na.locf(UNRATE, na.rm = FALSE)]
bias.unemp[, impute.ff := na.locf(UNRATE, na.rm = FALSE)]

## 평평한 부분을 보여주는 샘플 그래프
###동그란 선
unemp[350:400, plot (DATE, UNRATE, col=1, lwd=2, type='b')]
### 붉은 점선
rand.unemp[350:400, lines (DATE, impute.ff, col=2, lwd=2, lty=2)]
### 세모
rand.unemp[350:400][rpt==TRUE, points(DATE, impute.ff, col=2, pch=6, cex=2)]


## 이동평균: 롤링 평균 또는 중앙값으로 대체
## 노이즈가 많은 경우, 데이터의 변화량이 큰 경우 포워드필보다 이동평균 사용 -> 노이즈 일부 제거

### 사전관찰이 없는 롤링 평균
rand.unemp[, impute.rm.nolookahead :=rollapply(c(NA, NA, UNRATE), 3,
           function(x){
             if (!is.na(x[3])) x[3] else mean(x, na.rm=TRUE)
           })]

bias.unemp[, impute.rm.nolookahead :=rollapply(c(NA, NA, UNRATE), 3,
           function(x){
            if (!is.na(x[3])) x[3] else mean(x, na.rm=TRUE)
          })]
### 누락 발생 이전 값의 평균으로 누락된 값 대체
### 이동평균이 산술평균일 필요는 없음
### 지수가중이동평균: 최근 데이터에 더 많은 가중치
### 기하평균: 특정 데이터의 상관관계가 존재하고 시간이 지날수록 복합적인 시계열 데이터에 유용

### 사전 관찰이 포함된 롤링 평균
### 사전 관찰이 포함되므로 누락 데이터의 전후 데이터를 고려해 추정
### zoo 패키지의roll apply()기능을 통해 롤링 윈도우 구현
rand.unemp[, complete.rm := rollapply(c(NA, UNRATE, NA), 3,
             function(x){
               if (!is.na(x[2])) x[2]
               else mean(x, na.rm = TRUE)
             })]

## 보간법
### 전체 데이터를 기하학적 행동에 제한하여 누락된 데이터값을 결정하는 방법

## 선 형보간법linear interpolation
### 누락된 데이터가 주변 데이터에 선형적 일관성을 가도록 제한
### 시간에 따라 시스템이 동작하는 방식 미리 알고 적용할 때 유용(선험적)
rand.unemp[, impute.li := na.approx(UNRATE)]
bias.unemp[, impute.li := na.approx(UNRATE)]

## 다항식 보간법polynomial interpolation
rand.unemp[, impute.sp := na.spline(UNRATE)]
bias.unemp[, impute.sp := na.spline(UNRATE)]

use.idx = 90:120
unemp[use.idx, plot(DATE, UNRATE, col = 1, type = 'b')]
rand.unemp[use.idx, lines(DATE, impute.li, col = 2, lwd= 2, lty = 2)] #선형 보간법
rand.unemp[use.idx, lines(DATE, impute.sp, col = 3, lwd= 2, lty = 3)] #스플라인 보간법

### 선형linear(or spline) 보간법이 적절한 경우가 많다.
### 연도나 계절에 따른 온도 변화 추세를 이미 알고있을 때 등 -> 이동평균보다 추세를 더 잘 표현
### 강수량의 경우 추세가 적용되지 않을 수 있으므로 보간법으로 추정하면 안됨


# 평균제곱오차MSE 비교를 통한 가장 좋은 대치법 찾기
sort(rand.unemp[ , lapply(.SD, function(x) mean((x - unemp$UNRATE)^2, na.rm = TRUE)),
                 .SDcols = c("impute.ff", "impute.rm.nolookahead", "impute.li", "impute.sp")]) ## "impute.rm.lookahead", 

sort(bias.unemp[ , lapply(.SD, function(x) mean((x - unemp$UNRATE)^2, na.rm = TRUE)),
                 .SDcols = c("impute.ff", "impute.rm.nolookahead", "impute.li", "impute.sp")]) ## "impute.rm.lookahead",


# 주의 사항
## 데이터의 무작위 누락을 증명하기 어려우며, 현실세계의 누락값은 무작위가 아닐 가능성이 높음
## 측정 변수를 통해 누락 발생 확률을 예측할 수 있지만, 그렇지 않을 수 있음
## 누락 데이터 대치 값을 정확하게 만들기 위해서는 데이터를 수집한 사람에게 인사이트를 얻거나 여러 시나리오를 시도해야
## 사전관찰을 막아야하며, 후속 작업의 유효성을 고민해야 함


# 2.4.2. 업샘플링과 다운샘플링

# 다운샘플링: 데이터의 빈도를 줄이는 모든 순간.
## 1) 원본 데이터의 시간 단위가 실용적이지 않은 경우: 자주 -> 덜 자주
## 2) 계절 주기의 특정 부분에 집중하는 경우: 전반적 계절성보다 특정 계절에 초점을 맞추는 경우
unemp[seq.int(from = 2, to = nrow(unemp), by = 12)] # 전체 12개월 중 2월만 뽑음

## 3) 더 낮은 빈도의 데이터에 맞추는 경우
unemp[, mean(UNRATE), by = format(DATE, "%Y")] # 연도별 평균

# 업샘플링: 더 자주 측정하거나 조밀한 시간의 데이터 얻기 -> 더 많은 시간 레이블이 추가되지만, 정보가 추가되지는 않음
## 1) 시게열이 불규칙한 상황 -> 누락 값을 채웠던 롤링 조인 등
all.dates<- seq(from = unemp$DATE[1], to = tail(unemp$DATE, 1), by = "months")
all.dates
rand.unemp = rand.unemp[J(all.dates), roll=0]

## 2) 입력이 서로 다른 빈도로 샘플링된 상황
daily.unemployment = unemp[J(all.dates), roll = 31] # 월별 데이터를 일자별로 각각 입력(48년 1월은 모두 일자 상관 없이 3.4인 등)
daily.unemployment


# 2.4.3. 데이터 평활Smoothing
# 목적: 
# 1) 데이터 준비: 이상치가 너무 큰 경우
# 2) 특징feature 생성: 몇몇 지표로 요약하는 등
# 3) 예측: 평활된 특징을 통해 예측하는 평균회귀
# 4) 시각화: 노이즈 낀 산점도에 신호를 추가할 때

## 지수평활: 시점마다 데이터를 다르게 취급할 때->최근 데이터에 가중치
## 91페이지 수식, 106페이지 논문 참고
# -> 여기서부터 pandas


# 2.5 계절성 데이터
## 계절성seasonal, 추세trend, 나머지remainder
## 잔차는 시계열의 시작과 끝에서 가장 크다!
plot(stl(AirPassengers, "periodic"))

