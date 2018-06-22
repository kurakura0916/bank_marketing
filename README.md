# bank_marketing

## 概要
UCIの[Bank Marketing Data Set](https://archive.ics.uci.edu/ml/datasets/bank+marketing#)を用いたロジスティック回帰分析を行う。
また、以下のテーマに従いROIを最大化させるアルゴリズムを作成する。

## テーマ
予測モデルを用いてROIを最大化させるためのアタックリストを出力する。なお、キャンペーンを実施するにあたり1人の顧客に架電するコストは500円かかります。一方、1件獲得したときの平均LTVは一律2000円です。

```math
ROI = (獲得人数×2000円) - (電話を掛けた回数×500)
```

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
  1. 変数追加無し&欠損値（unknown）をそのまま使う（modeling_pattern_1.R）
  2. 変数追加有り&欠損値（unknown）をそのまま使う（modeling_pattern_2.R）
  3. 変数追加無し&論理埋め（modeling_pattern_3.R）
  4. 変数追加有り&論理埋め（modeling_pattern_4.R）
  5. 変数追加無し&欠損値（unknown）を含む全ての行を削除する（modeling_pattern_5.R）
  6. 変数追加有り&欠損値（unknown）を含む全ての行を削除する（modeling_pattern_6.R）

## 作業手順
1. データの取り込み
2. データ探索
3. 欠損値の処理
4. 変数の作成
5. 訓練データとテストデータに分割
6. ロジスティック回帰分析の実行
7. VIF（多重共線性）の確認
8. AICの確認
9. ステップワイズ法でAICが最小になる変数の選択
10. AICの確認
11. 作成したモデルをテストデータに当てはめ確率を求める
12. ROIが最大するカットオフ値を探索
13. 混同行列の作成
14. ROIの計算
