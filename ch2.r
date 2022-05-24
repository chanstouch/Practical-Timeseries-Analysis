
a <- 2

a
.libPaths("C:/R_library")
.libPaths()
normalizePath(file.path("C:", "R_Library"))



## zoo: �ð迭
install.packages("rmarkdown")
install.packages("knitr")


install.packages("zoo")
install.packages("data.table")
install.packages("curl")


require(zoo)
require(data.table)
require(curl)

library(zoo)
library(data.table)
library(curl)

unemp <- fread("https://raw.githubusercontent.com/PracticalTimeSeriesAnalysis/BookRepo/master/Ch02/data/UNRATE.csv")
unemp[, DATE := as.Date(DATE)]
setkey(unemp, DATE)

rand.unemp.idx <- sample(1:nrow(unemp), .1*nrow(unemp))
rand.unemp <- unemp[-rand.unemp.idx]

high.unemp.idx <- which(unemp$UNRATE > 8)
num.to.select <- .2 * length(high.unemp.idx)
high.unemp.idx <- sample(high.unemp.idx,)
bias.unemp <- unemp[-high.unemp.idx]

# 43 page
all.dates <- seq(from=unemp$DATE[1], to=tail(unemp$DATE, 1), by="months")
rand.unemp = rand.unemp[J(all.dates), roll=0]
bias.unemp = bias.unemp[J(all.dates), roll=0]
rand.unemp[, rpt := is.na(UNRATE)]

rand.unemp[, impute.ff := na.locf(UNRATE, na.rm=FALSE)]
bias.unemp[, impute.ff := na.locf(UNRATE, na.rm=FALSE)]

unemp[350:400, plot(DATE, UNRATE, col=1, lwd=2, type='b')]
rand.unemp[350:400, lines(DATE, impute.ff, col=2, lwd=2, lty=2)]
rand.unemp[350:400][rpt==TRUE, points(DATE, impute.ff, col=2, pch=6, cex=2)]
