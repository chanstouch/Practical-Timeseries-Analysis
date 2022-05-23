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
#### 짦은 파선(우측)으로 정렬렬
lines(f1, col=2, lwd=3, lty=2)
lines(f2, col=3, lwd=3, lty=3)











