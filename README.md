# bank_marketing

## 概要
UCIの[Bank Marketing Data Set](https://archive.ics.uci.edu/ml/datasets/bank+marketing#)を用いたロジスティック回帰分析を行う。
また、以下のパターンからAICが最も低くなるようなモデルを見つける。

## データセット説明
ポルトガルの銀行で行なった定期預金（term deposit）に申し込んでもらうためのキャンペーン結果及びその顧客の情報を表したデータセット。
各カラムの情報は以下の通り。

|カラム名 | データ型| 説明 |
|:---|:---|:---|
|age |numeric |年齢 |
|job |categorical |職業 |
|marital |categorical |婚姻状況 |
|education |categorical |学歴 |
|default |categorical |過去に債務不履行を起こしたかどうか |
|housing |categorical |家のローンを抱えているかどうか |
|loan |categorical |個人でローンを抱えているかどうか |
|contact |categorical |顧客との連絡手段 |
|month |categorical |最後に顧客と連絡を取った月 |
|day_of_week |categorical |最後に顧客と連絡を取った曜日 |
|duration |numeric |最後に顧客と連絡を取った際の会話時間（秒） |
|campaign |numeric |キャンペーン期間中に顧客と連絡を取った回数|
|pdays |numeric |最後に顧客と連絡を取ってからの経過日数 |
|previous |numeric |今回のキャンペーン前に顧客と連絡を取った回数 |
|poutcome |categorical |前回のキャンペーン結果|
|emp.var.rate |numeric |就労率 |
|cons.price.idx |numeric |消費者物価指数 |
|cons.conf.idx |numeric |消費者信頼指数 |
|euribor3m |numeric |3カ月物EURIBOR |
|nr.employed |numeric |従業員数 |

## 備考
モデル作成の際は、新規顧客（前回のキャンペーンなどの情報がない、今までの連絡ログがない方）にも当てはまるようにしたいため以下のカラムは使用しない。また、経済指標も使用しない。

## 環境
R言語（version.string R version 3.4.1 (2017-06-30)）

## モデルのパターン
以下の欠損値（unknown）の扱い方×変数の追加有無のパターン（計6つ）でモデルを作成
- 欠損値の扱い方
  1. 欠損値（unknown）をそのまま使う
  2. 論理的に欠損値を埋める
  3. 欠損値（unknown）を含む全ての行を削除する

- パターン
  1. 変数追加無し&欠損値（unknown）をそのまま使う
  2. 変数追加有り&欠損値（unknown）をそのまま使う
  3. 変数追加無し&論理埋め
  4. 変数追加有り&論理埋め
  5. 変数追加無し&欠損値（unknown）を含む全ての行を削除する
  6. 変数追加有り&欠損値（unknown）を含む全ての行を削除する

## 作業手順
1. データの取り込み
2. データ探索
3. 変数の選択
4. 3で選択した変数からさらに変数を作成
5. 欠損値の処理
6. 訓練データとテストデータに分割
6. ロジスティック回帰分析の実行
7. VIF（多重共線性）の確認
8. AICの確認
9. ステップワイズ法でAICが最小になる変数の選択
10. AICの確認
11. 作成したモデルをテストデータに当てはめ確率を求める
12. 混同行列の作成
13. 正解率、適合率、再現率、F値を求める
