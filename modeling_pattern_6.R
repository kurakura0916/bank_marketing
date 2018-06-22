#######################
# 6 変数追加ありNAを含む全ての行を削除
#######################

# データの取り込み
data <- read.csv("bank_marketing_train.csv",header = T,na.strings=(c("NA", "unknown")))

# NAを含む行を削除
data <- na.omit(data) # 元の行数：37068、削除後の行数：26872

# duration / campaign / pdays / previous / poutcome / emp.var.rate / cons.price.idx / euribor3m / nr.employed / cons.conf.idx  の変数を削除
data <- data %>% dplyr::select(-duration,-campaign,-pdays,-previous,-poutcome,-emp.var.rate,-cons.price.idx,-nr.employed,-cons.conf.idx,-euribor3m)

# 欠損値の確認
sapply(data,function(x) sum(is.na(x)))

data <- data %>% select(-loan)

# 年代カラムを作成
data <- data %>% mutate(decade = round(age-4,digit=-1))

# 30代以下の場合1を立てるunder_30カラムを作成
data <- data %>% mutate(under_30 = ifelse(data$decade<=30,1,0))

# 60代以上の場合1を立てるover_60カラムを作成
data <- data %>% mutate(over_60 = ifelse(data$decade>=60,1,0))

# studentの細分化
data$job <- as.character(data$job)
data$job[data$job=="student"&data$education=="university.degree"] <- "master-student"
data$job[data$job=="student"&data$education=="high.school"] <- "university-student"
data$job[data$job=="student"&data$education=="professional.course"] <- "master-student"
data$job[data$job=="student"&data$education=="basic.4y"] <- "basic-student"
data$job[data$job=="student"&data$education=="basic.6y"] <- "basic-student"
data$job[data$job=="student"&data$education=="basic.9y"] <- "highschool-student"
data$job <- as.factor(data$job)

# decadeの変数を除く
data <- data %>% dplyr::select(-decade)

#学習データとテストデータに分割
set.seed(1234)
train_idx<-sample(c(1:dim(data)[1]), size = dim(data)[1]*0.7)
train<-data[train_idx, ]
test<- train[-train_idx, ]

# ロジスティック回帰分析の実行
model <- glm(y~.,data=train,family = binomial)
summary(model) # AIC: 9698.1
vif(model)

model2 <-step(model)
summary(model2) # AIC:9682.2

# 予想を行う
ypred <- predict(model2,newdata = test,type = "response")

cutoff_values<- seq(0.1,1,length=100)
x<-c()
y<-c()

for(i in cutoff_values){
  y_flag <- ifelse(ypred>i,1,0)
  # 混同行列の作成
  conf_table <- table(y_flag,test$y)
  # 成約と予想して実際に成約した人数
  subscribed <-conf_table[4]
  # 成約すると予想して電話をかけた人数
  tel_num <- conf_table[2]+conf_table[4]
  x <- append(x,i)
  y <- append(y,subscribed*2000-tel_num*500)
}
plot(x,y,ylab="ROI",xlab="cutoff_values")
res <- data.frame(x,y)
# ROIが最大になっているカットオフ値を出力
res[res$y == max(res$y,na.rm = T),]
# カットオフ値：0.2181818、ROI：76500

y_flag <- ifelse(ypred>0.2181818,1,0)
conf_table <- table(y_flag,test$y)
conf_table
paste("Accuracy:",round((conf_table[1]+conf_table[4])/sum(conf_table)*100,2),"%",sep = "")
#"Accuracy:90.6%"

