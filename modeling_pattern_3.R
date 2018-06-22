#######################
# 3 変数追加なし欠損値を論理埋め
#######################

# データの取り込み
data <- read.csv("bank_marketing_train.csv",header = T,na.strings=(c("NA", "unknown")))

# duration / campaign / pdays / previous / poutcome / emp.var.rate / cons.price.idx / euribor3m / nr.employed / cons.conf.idx  の変数を削除
data <- data %>% dplyr::select(-duration,-campaign,-pdays,-previous,-poutcome,-emp.var.rate,-cons.price.idx,-nr.employed,-cons.conf.idx,-euribor3m)

# 欠損値の確認
sapply(data,function(x) sum(is.na(x)))

# defaultのunknownをnoで埋める
data$default <- as.character(data$default)
data$default[is.na(data$default)] <- "no"
data$default <- as.factor(data$default)

# 年代カラムを作成
data <- data %>% mutate(decade = round(age-4,digit=-1))

## jobの補完
# 年代毎にjobをみて、最も多い職業を年代毎に補完
# jobがNAではない人のみのデータフレームを作成
# job_not_na <- subset(train,!is.na(train$job))

# 年代毎及びjob毎に人数をカウント
# job_not_na_decade_cnt <- job_not_na %>% group_by(decade,job) %>% summarise(cnt = n())

# jobを年代毎に補完
data$job[is.na(data$job)&data$decade == 20] <- "admin."
data$job[is.na(data$job)&data$decade == 30] <- "admin."
data$job[is.na(data$job)&data$decade == 40] <- "blue-collar"
data$job[is.na(data$job)&data$decade == 50] <- "blue-collar"
data$job[is.na(data$job)&data$decade == 60] <- "retired"
data$job[is.na(data$job)&data$decade == 70] <- "retired"
data$job[is.na(data$job)&data$decade == 80] <- "retired"
data$job[is.na(data$job)&data$decade == 90] <- "retired"

## educationの補完
# education_not_na <- subset(train,!is.na(train$education))
# education_not_na_job_cnt <- education_not_na %>% group_by(job,education) %>% summarise(cnt = n())

# job / educationの両方がNAの行を確認
# subset(train,is.na(train$education)&is.na(train$job))
# 上記の条件に引っかかる行はなし

# educationをjob毎に補完
data$education[is.na(data$education)&data$job=="admin."] <- "university.degree"
data$education[is.na(data$education)&data$job=="blue-collar"] <- "basic.9y"
data$education[is.na(data$education)&data$job=="entrepreneur"] <- "university.degree"
data$education[is.na(data$education)&data$job=="housemaid"] <- "basic.4y"
data$education[is.na(data$education)&data$job=="management"] <- "university.degree"
data$education[is.na(data$education)&data$job=="retired"] <- "basic.4y"
data$education[is.na(data$education)&data$job=="self-employed"] <- "university.degree"
data$education[is.na(data$education)&data$job=="services"] <- "high.school"
data$education[is.na(data$education)&data$job=="student"] <- "high.school"
data$education[is.na(data$education)&data$job=="technician"] <- "professional.course"
data$education[is.na(data$education)&data$job=="unemployed"] <- "university.degree"

# maritalを補完する
#marital_not_na <- subset(train,!is.na(train$marital))
#marital_not_na_age <- marital_not_na %>% group_by(decade,marital) %>% summarise(cnt=n())

# maritalを年代毎に補完
data$marital[is.na(data$marital)&data$decade == 10] <- "single"
data$marital[is.na(data$marital)&data$decade == 20] <- "single"
data$marital[is.na(data$marital)&data$decade == 30] <- "married"
data$marital[is.na(data$marital)&data$decade == 40] <- "married"
data$marital[is.na(data$marital)&data$decade == 50] <- "married"
data$marital[is.na(data$marital)&data$decade == 60] <- "married"
data$marital[is.na(data$marital)&data$decade == 70] <- "married"
data$marital[is.na(data$marital)&data$decade == 80] <- "divorced"
data$marital[is.na(data$marital)&data$decade == 90] <- "divorced"

# housingを補完する
#housing_not_na <- subset(train,!is.na(train$housing))
#housing_not_na_age <- housing_not_na %>% group_by(decade,housing) %>% summarise(cnt=n())
data$housing[is.na(data$housing)] <- 'yes'

# loanを補完する
#loan_not_na <- subset(train,!is.na(train$loan))
#loan_not_na_age <- loan_not_na %>% group_by(decade,loan) %>% summarise(cnt=n())
data$loan[is.na(data$loan)] <- 'no'

# admin / blue-collar / technician /student / retired以外をothersで置き換える
data$job <- as.character(data$job)
others <- c("management","entrepreneur","services","unemployed","self-employed","housemaid","unknown")
data$job[data$job %in% others] <- "others"
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
summary(model) # AIC: 12886
vif(model)

model2 <-step(model)
summary(model2) # AIC:12880

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
# カットオフ値：0.1909091、ROI：113500

y_flag <- ifelse(ypred>0.1909091,1,0)
conf_table <- table(y_flag,test$y)
conf_table
paste("Accuracy:",round((conf_table[1]+conf_table[4])/sum(conf_table)*100,2),"%",sep = "")
#"Accuracy:91.54%"

