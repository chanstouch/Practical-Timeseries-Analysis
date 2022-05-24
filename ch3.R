# 3.1.1. 도표 그리기

## 데이터 출력
head(EuStockMarkets)

## 그래프 그리기
plot(EuStockMarkets)
# plot함수 만으로도 데이터를 서로 다른 시계열로 자동 분할 가능!

class(EuStockMarkets)
## "mts"    "ts"     "matrix" -> 무슨 의미인지 불명

## frequency(): 데이터 연간 빈도
frequency(EuStockMarkets)
## 260

## start(), end(): 데이터 시작과 끝
start(EuStockMarkets)
end(EuStockMarkets)

## window(): 시간의 한 부분 범위
window(EuStockMarkets, start = 1997, end = 1998)


### 3.1.2 히스토그램
hist(     EuStockMarkets[, "SMI"], 30)  # 원본데이터 히스토그램은 넓게 퍼지고, 정규분포X
hist(diff(EuStockMarkets[, "SMI"], 30)) # 인접 데이터의 차diff를 구하면 정규분포O

## 시계열의 맥락을 고려하는 금융 등에서는 측정치 자체보다 어떤 방식으로 변화했는지 관심
## 앞서 그린 plot은 주가 지수가 상승
## 하지만 hist에서는 개인(SMI)이 주가를 쫓는 평범한 모습을 보여줌


### 3.1.3. 산점도scatter plot
# 산점도로 알 수 있는 것
## 특정 시간에 대한 두 주식의 관계
## 두 주식의 시간에 따른 가격 변동의 연관성

plot(     EuStockMarkets[, "SMI"],       EuStockMarkets[, "DAX"])
plot(diff(EuStockMarkets[, "SMI"]), diff(EuStockMarkets[, "DAX"]))
# 이 차분 그래프는 생각보다 상관관계가 크지 않음

# lag함수 적용: SMI의 1일 전 값(시간을 뒤로 미룸)
plot(lag(diff(EuStockMarkets[, "SMI"]), 1), 
         diff(EuStockMarkets[, "DAX"]))
## lag함수를 사용하니 두 주가의 상관관계가 사라졌다


# 3.2.2. 윈도우 함수 적용

## 롤링 윈도우: 데이터를 압축하거나 평활하기 위한 모든 데이터에 적용 가능
### R의 filter()함수는 이동평균, 계열의 선형함수 관련 계산 가능

### 정규분포를 따르는 난수 100개 추출
x<- rnorm(n=100, mean=0, sd=10) + 1:100

### rep함수로 1/n 값을 n번 반복하는 배열을 만드는 함수
mn<- function(n) rep(1/n, n)

plot(x, type = 'l', lwd = 1)

### R의 filter함수로 롤링 평균 계산. 5, 50개 단위
lines(filter(x, mn( 5)), col = 2, lwd = 3, lty = 2)
lines(filter(x, mn(50)), col = 3, lwd = 3, lty = 3)



## 일차결합하지 않은 함수: zoo패키지의 rollapply()함수
## filter는 데이터의 일차변환linear transformation에 기반

require(zoo)
### x를 zoo 객체로 만들어 각 데이터 인덱싱
### rollapply: 데이터, 윈도우 크기, 적용 함수, 롤링 적용방향, 윈도우 크기만큼 데이터가 없어도 적용할지 등 인수 지정
f1<- rollapply(zoo(x), 20, function(w) min(w), align = "left", partial = TRUE)
f2<- rollapply(zoo(x), 20, function(w) min(w), align = "right", partial = TRUE)

plot(x, lwd=1, type='l')

#### 롤링 윈도우로 계산된 최솟값을 긴 파선(좌측)
#### 짦은 파선(우측)으로 정렬
lines(f1, col=2, lwd=3, lty=2)
lines(f2, col=3, lwd=3, lty=3)

#### lines관련 설명 https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=dic1224&logNo=80208314073



## 확장 윈도우expanding window
### 롤링 윈도우보다 덜 보편적. 시간에 따른 변동이 크지 않은 요약통계에 유용
### 시계열 최소 크기부터 전체 데이터를 포함할 때까지 확장 가능(많은 내용 표현해야함)
### 시간이 길어질 수록 검정 통계량test statistic 추정치가 확실
### 특정 시계열로 더 깊은 이점을 얻을 수 있음
### 정상 시계열일 때만 확장 윈도우 동작
### 실시간 요약 통계 추정할 때 유용

plot(x, type = 'l', lwd = 1)
lines(cummax(x), col=2, lwd=3, lty=2) # 최대값 단조함수
lines(cumsum(x)/1:length(x), col=3, lwd=3, lty=3) # 평균

## rollapply()를 통한 롤링 윈도우에 사용자 정의 함수 적용
plot(x, type = 'l', lwd = 1)
### seq_along: 1부터 입력 인수에서 끝나는 순서 생성
lines(rollapply(zoo(x), seq_along(x), function(w) max(w),  # max
                partial = TRUE, align="right"),
      col=2, lwd=3, lty=2)
lines(rollapply(zoo(x), seq_along(x), function(w) mean(w), # mean
                partial = TRUE, align="right"),
      col=2, lwd=3, lty=3)

## 사용자 정의 롤링함수: 도메인 지식이 있는 경우에만 적용!


## 3.2.3. 자체상관
### 자체상관: 특정 시점의 값이 다른 시점의 값과 상관관계 존재
### 자체상관은 비공식적 용어
### 일별 평균 온도 데이터에서 5.15온도가 높아질 때, 8.15일 온도도 높아지는 상관관계처럼 보임
### 하지만 상관관계는 0에 가깝다! 5.15의 온도가 영향을 끼쳤다고 하기 어 렵기 때문!
### = 특정 시점에 고정되지 않는 자기상관

### 자기상관autocorrelation: 서로 다른 시점의 데이터 간 선형적 연관성 정도를 시차에 대한 함수로 알 수 있게 해줌
### ACF: autoCorrelation function
x <- 1:100
y = sin(x * pi / 3) 
plot(y, type = 'b')
acf(y)
pacf(y)
### ACF: 원본 데이터의 시차가 0인 지점 사이의 상관 관계는 1, 
###                    시차가 1인 지점 사이의 상관관계는 0.5
###                    시차가 2인 지점 사이의 상관관계는 -0.5
### 노이즈 없는 계절적 데이터에서 T 시점의 ACF 값은 단위 시간마다 동일(불필요한 중복)

y = sin(x * pi / 10)
plot(y, type = 'b')
acf(y)
pacf(y)
### PACF: 시계열의 특정 시차에 대한 편자기상관: 자신에 대한 그 시차의 편상관partial correlation
### PACF는 두 시점 사이에 존재하는 모든 정보 고려
### = 많은 조건부 상관관계 계산, 전체 상관관계로부터 계산된 조건부 상관관계 삭제 필요
### 어떤 데이터가 유용한 정보를 갖고, 단기간의 고조파harmonic인지 보여준다.
### 특정 시차에 대해 ACF처럼 불필요한 중복이 아니라 정말 '유용한' 정보인지 알아낼 수 있다.


### 비정상 시계열 함수
y = sin(x * pi / 4) + sin(x * pi / 10)
plot(y, type = 'b')
acf(y)
pacf(y)
### ACF: 두 주기의 계열 합의 ACF값 = 개별 AFC값의 합
### PACF: 원본 계열보다 계열들의 합에서 유용. 
###       다른 주기의 데이터는 특정 시점 값이 인접한 시점에 의해 덜 결정되는 결과(인접 값의 영향력 하락)
###       두 주기의 사이클 위치 고정x

### 노이즈를 많이 주는 경우
noise1 = rnorm(100, sd = 0.3)
noise2 = rnorm(100, sd = 0.3)

par(mfrow = c(3, 3))

y = sin(x * pi / 4) + noise1
plot(y, type = 'b')
acf(y)
pacf(y)

y = sin(x * pi / 10) + noise2
plot(y, type = 'b')
acf(y)
pacf(y)

y = sin(x * pi / 4) + sin(x * pi / 10) + noise1 + noise2
plot(y, type = 'b')
acf(y)
pacf(y)





### cor(): 상관계수 계산
#### y와 시차 1만큼의 상관관계
require(data.table)
cor(y, shift(y, 1), use="pairwise.complete.obs") 
#pairwise.complete.obs는 계산 대상 변수만 대상으로 누락 값 제거
#### 시차 2만큼의 상관관계
cor(y, shift(y, 2), use="pairwise.complete.obs") 




## 3.2.4 허위상관
### 근본 원인이 아닌 헛된 상관 관계
### 계절성: 여름에 냉면 구매와 익사 사고 증가 - 이 둘은 높은 상관 관계 값을 갖지만 허위
### 시간에 따른 데이터 수준, 경사 이동
### 누적 합계


## 3.3.1 2차원 시각화
install.packages("timevis")
require(timevis)
donations <- fread("C:/Users/jung6/Downloads/donations.csv")
d<- donations[, .(min(timestamp), max(timestamp)), user]
names(d) <- c("content", "start","end")
d<-d[start!=end]
timevis(d[sample(1:nrow(d), 20)])
### 간트차트: 전체 회원 참여가 몰렸던 시기를 알 수 있다.

## 3.3.2 2차원 시각화
t(matrix(AirPassengers, nrow=12, ncol=12))
colors<-c("green", "red", "pink", "blue", "yellow", "lightsalmon", "black", "gray", "cyan", "lightblue", "maroon", "purple")
matplot(matrix(AirPassengers, nrow=12, ncol=12),
        type = 'l', col=colors, lty = 1, lwd=2.5,
        xaxt="n", ylab="Passenger Count")
legend("topleft", legend = 1949:1960, lty=1, lwd=2.5, col=colors)
axis(1, at=1:12, labels =c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"))

### forecast
install.packages("forecast")
require(forecast)
seasonplot(AirPassengers)
### x축은 모든 연도가 공유하는 달을 표시

### 월별 곡선 도표
months <-c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
matplot(t(matrix(AirPassengers, nrow=12, ncol=12)),
        type='l',col=colors, lty=1, lwd=2.5)
legend("left", legend=months, col=colors, lty=1, lwd=2.5)

### monthplot: forecast 패키지
monthplot(AirPassengers)

### 히스토그램
hist2d <- function(data, nbins.y, xlabels) { 
  ## we make ybins evenly spaced to include 
  ## minimum and maximum points
  ymin=min(data)				
  ymax=max(data) * 1.0001
  ## the lazy way out to avoid worrying about inclusion/exclusion
  
  ybins=seq(from=ymin,to=ymax,length.out=nbins.y+1) 
  ## make a zero matrix of the appropriate size
  hist.matrix=matrix(0,nrow=nbins.y,ncol=ncol(data))
  
  ## data comes in matrix form where each row 
  ## represents one data point 
  for(i in 1:nrow(data)) {
    ts = findInterval(data[i, ], ybins)
    for (j in 1:ncol(data)) {
      hist.matrix[ts[j], j] = hist.matrix[ts[j], j] + 1 > hist.matrix
    }
  }
  hist.matrix
}	

h <- hist2d(t(matrix(AirPassengers, nrow = 12, ncol = 12)), 5, months) 
image(1:ncol(h), 1:nrow(h), t(h), col = heat.colors(5), axes = FALSE, xlab = "Time", ylab = "Passenger Count") 


### 로그 변환환
require(data.table)

words <- fread(url.str)
w1 <- words[V1 == 1]
h = hist2d(w1, 25, 1:ncol(w1))					

colors <- gray.colors(20, start = 1, end = .5)
par(mfrow = c(1, 2))
image(1:ncol(h), 1:nrow(h), t(h),
      col = colors, axes = FALSE, xlab = "Time", ylab = "Projection Value") 
image(1:ncol(h), 1:nrow(h), t(log(h)),
      col = colors, axes = FALSE, xlab = "Time", ylab = "Projection Value") 	

