#######################
データの可視化
#######################
# ライブラリーの読み込み
library(dplyr)
library(ggplot2)
library(scales)

# データの読み込み
data <- read.csv("bank_marketing_train.csv",header = T)

#######################
年代毎に成約数/率を集計
#######################
# 年代のカラムを作成
data <- data %>% mutate(decade = round(age-4,digit=-1))

data_age <- data %>% group_by(decade,y) %>% summarise(cnt=n())
g <- ggplot(data_age,aes(x=decade,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
# 30代の成約数が多い

# 100%積み上げ棒グラフ
g <- ggplot(data_age,aes(x=decade,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# 20代以下 / 50代以降から成約率が高くなる
# 職業に依存している？

#######################
職業毎に成約数/率を集計
#######################
data_job <- data %>% group_by(job,y) %>% summarise(cnt=n())
g <- ggplot(data_job,aes(x=job,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
# admin / blue_color / technicianの成約数が多いがそもそもの人数が多いからだと思われる

# 100%積み上げ棒グラフ
g <- ggplot(data_job,aes(x=job,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# 成約率で見ると、student / retiredが高い
# ライフステージが変わるタイミングで成約する傾向にある？

#######################
婚姻状況毎に成約数/率を集計
#######################
# marital毎に成約数を集計
data_marital <- data %>% group_by(marital,y) %>% summarise(cnt=n())
g <- ggplot(data_marital,aes(x=marital,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
## 婚約（married）している方が成約数が多い

# 100%積み上げ棒グラフ
g <- ggplot(data_marital,aes(x=marital,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# 成約率で見ると大きな差があるようには思えない

#######################
学歴毎に成約数/率を集計
#######################
# education毎に成約数を集計
data_education <- data %>% group_by(education,y) %>% summarise(cnt=n())
g <- ggplot(data_education,aes(x=education,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
# 大卒 / 高卒の方が成約数が多い

# 100%積み上げ棒グラフ
g <- ggplot(data_education,aes(x=education,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# 成約率で見るとilliterateが高いが、そもそも人数が少ないので要注意

#######################
家のローン有無毎に成約数/率を集計
#######################
# housing毎の成約数を集計
data_housing <- data %>% group_by(housing,y) %>% summarise(cnt=n())
g <- ggplot(data_housing,aes(x=housing,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
# housingはあまり成約数に関係なさそう

# 100%積み上げ棒グラフ
g <- ggplot(data_housing,aes(x=housing,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# housingはあまり成約数に関係なさそう

#######################
個人のローン有無毎に成約数/率を集計
#######################
# loan毎の成約数を集計
data_loan <- data %>% group_by(loan,y) %>% summarise(cnt=n())
g <- ggplot(data_loan,aes(x=loan,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
# 個人でローンを抱えてない方が成約数が多い

# 100%積み上げ棒グラフ
g <- ggplot(data_loan,aes(x=loan,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# 成約率で見るとそこまで大きな差はなさそう

#######################
連絡手段毎に成約数/率を集計
#######################
# contact毎の成約数を集計
data_contact <- data %>% group_by(contact,y) %>% summarise(cnt=n())
g <- ggplot(data_contact,aes(x=contact,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
# cellularの方が成約数が多い

# 100%積み上げ棒グラフ
g <- ggplot(data_contact,aes(x=contact,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# 成約率で見てもcellularの方が高い

#######################
最終連絡月毎に成約数/率を集計
#######################
## month毎の成約数を集計
data_month <- data %>% group_by(month,y) %>% summarise(cnt=n())
g <- ggplot(data_month,aes(x=month,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
# may（5月）での連絡回数圧倒的に多い（なぜ？今回のキャンペーン開始月？

# 100%積み上げ棒グラフ
g <- ggplot(data_month,aes(x=month,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# oct（10月）/mar（3月）の成約率が高いが、連絡している人数が少ない

# octとmarに電話をかけている相手は？
data_oct_mar <- subset(data,month=="oct"|month=="mar")
prop.table(table(data_oct_mar$job,data_oct_mar$y),1)
# octとmarで成約率が高い職業はservices


#######################
最後に顧客と連絡を取った曜日毎に成約数/率を集計
#######################
# day_of_week毎の成約数を集計
data_day_of_week <- data %>% group_by(day_of_week,y) %>% summarise(cnt=n())
g <- ggplot(data_day_of_week,aes(x=day_of_week,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity")
plot(g)
# 曜日によって成約数はあまり変わらないかも

# 100%積み上げ棒グラフ
g <- ggplot(data_day_of_week,aes(x=day_of_week,y=cnt,fill=y))
g <- g+geom_bar(stat = "identity",position = "fill")+scale_y_continuous(label=percent)
plot(g)
# 成約率で見ても曜日によって成約率はあまり変わらないかも

#######################
年齢毎に職業を集計
#######################
g <- ggplot(data = data, aes(x=age, fill=job)) 
g<- g+geom_histogram(alpha=0.8,binwidth = 5,position = "stack")
plot(g)

#######################
学歴毎の職業を集計
#######################
data_edu_job <- data %>% group_by(education,job) %>% summarise(cnt=n())
g <- ggplot(data_edu_job,aes(x=education,y=cnt,fill=job))
g <- g+geom_bar(stat = "identity")
plot(g)
# managementも大卒が多い
# 大卒は成約数が多くなる傾向だが、managementは成約率が低いのはなぜか

#######################
職業毎の学歴を集計
#######################
g <- ggplot(data_edu_job,aes(x=job,y=cnt,fill=education))
g <- g+geom_bar(stat = "identity")
plot(g)
# studentの成約率が高く、学生の学歴を見ると大学生や大学院生が多く含まれている。学生を学歴で細分化する必要がある。

