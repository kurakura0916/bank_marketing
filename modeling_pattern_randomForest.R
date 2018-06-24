#######################
# ランダムフォレストで行った場合
#######################
data <- read.csv("bank_marketing_train.csv",header = T)

#目的変数をyesであれば1, noであれば0にする
data$y<-ifelse(data$y=="yes", 1, 0)

#データを数値に変換（決定木ベースなので）
data$job<-as.numeric(data$job)
data$marital<-as.numeric(data$marital)
data$education<-as.numeric(data$education)
data$default<-as.numeric(data$default)
data$housing<-as.numeric(data$housing)
data$loan<-as.numeric(data$loan)
data$contact<-as.numeric(data$contact)
data$month<-as.numeric(data$month)
data$day_of_week<-as.numeric(data$day_of_week)
data$poutcome<-as.numeric(data$poutcome)
                          
#特徴量の自動生成
all_colnames<-names(data)
exclude_cols<-c("y", "duration", "campaign")
explanatory_cols<-all_colnames[all_colnames%in%exclude_cols==F]

# 隣のカラムとの相関を取得し、相関が0.4の場合は割り算を行い新しくカラムを追加する
for(i in 1:(length(explanatory_cols)-1)){
  for(j in (i+1):length(explanatory_cols)){
    first_colname<-explanatory_cols[i]
    second_colname<-explanatory_cols[j]
    soukan<-cor(data[,c(first_colname, second_colname)], method="spearman")
    # 相関係数の絶対値が0.4が大きい場合
    if(abs(soukan[2])>0.4){
      new_colname<-paste(first_colname, second_colname, sep = "_div_")
      print(new_colname)
      tmp<-data[,c(first_colname)] /(data[,c(second_colname)] + 0.01)
      tmp<-data.frame(tmp)
      colnames(tmp)<-new_colname
      data<-cbind(data, tmp)
    }
  }
}

#学習用とテスト用にデータを分ける
set.seed(1234)  # コードの再現性を保つためseedを固定
num_rows<-dim(data)[1]
idx<-c(1:num_rows)
train_idx<-sample(idx, size = num_rows*0.7 )
train_data<-data[train_idx, ]
validation_data<-data[-train_idx, ]

#特徴量の選択
library(randomForest)
rf<-randomForest(as.factor(y)~.-duration-campaign, 
                 data=train_data, 
                 sampsize=c(1900,1900), 
                 ntree=300,
                 importance=T)
varImpPlot(rf)
# MeanDecreaseAccuracy を説明変数の重要度として採用
imp<-importance(rf)[,3]
# MeanDecreaseAccuracyが0以上の変数を採用する
selected_features<-names(imp[imp>0])
selected_features<-c("y", selected_features)
selected_features

#モデリング
mymodel<-randomForest(as.factor(y)~., 
                      data=train_data[,selected_features], 
                      sampsize=c(1900,1900), 
                      ntree=50,
                      importance=T)

varImpPlot(mymodel)

#作成したモデルを検証用データに適用し、
#マーケティングキャンペーンにリアクションする確率を求めます（[,2]は目的変数が1である確率のみを抽出するため）
score<-predict(mymodel, validation_data, type = "prob")[,2]

cutoff_values<- seq(0.1,1,length=100)
x<-c()
y<-c()

for(i in cutoff_values){
  y_flag <- ifelse(score>i,1,0)
  # 混同行列の作成
  conf_table <- table(y_flag,validation_data$y)
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
# カットオフ値：0.89、ROI：130000

y_flag <- ifelse(score>0.89,1,0)
conf_table <- table(y_flag,validation_data$y)
conf_table
paste("Accuracy:",round((conf_table[1]+conf_table[4])/sum(conf_table)*100,2),"%",sep = "")
#"Accuracy:92.71%"
