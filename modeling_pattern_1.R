#######################
# 1 変数追加なしunknownそのまま
#######################

# データの取り込み
data <- read.csv("bank_marketing_train.csv",header = T)

# duration / campaign / pdays / previous / poutcome / emp.var.rate / cons.price.idx / euribor3m / nr.employed / cons.conf.idx  の変数を削除
data <- data %>% dplyr::select(-duration,-campaign,-pdays,-previous,-poutcome,-emp.var.rate,-cons.price.idx,-nr.employed,-cons.conf.idx,-euribor3m)

# 欠損値の確認
sapply(data,function(x) sum(is.na(x)))

# admin / blue-collar / technician /student / retired以外をothersで置き換える
data$job <- as.character(data$job)
others <- c("management","entrepreneur","services","unemployed","self-employed","housemaid","unknown")
data$job[data$job %in% others] <- "others"
data$job <- as.factor(data$job)

data <- data %>% select(-loan)

#学習データとテストデータに分割
set.seed(1234)
train_idx<-sample(c(1:dim(data)[1]), size = dim(data)[1]*0.7)
train<-data[train_idx, ]
test<- train[-train_idx, ]

# ロジスティック回帰分析の実行
model <- glm(y~.,data=train,family = binomial)
summary(model) # AIC: 12873
vif(model)

# ステップワイズでの変数最適化
model2 <- step(model)
summary(model2) # AIC: 12891

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
# カットオフ値：0.2、ROI：112500

y_flag <- ifelse(ypred>0.2000000,1,0)
conf_table <- table(y_flag,test$y)
conf_table
paste("Accuracy:",round((conf_table[1]+conf_table[4])/sum(conf_table)*100,2),"%",sep = "")
#"Accuracy:91.03%"
