# bank_marketing

## 概要
UCIの[Bank Marketing Data Set](https://archive.ics.uci.edu/ml/datasets/bank+marketing#)を用いたロジスティック回帰分析を行う。
また、以下のパターンからAICが最も低くなるようなモデルを見つける。

## 言語
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
6. ロジスティック回帰分析の実行
7. VIF（多重共線性）の確認
8. AICの確認
9. ステップワイズ法でAICが最小になる変数の選択
10. AICの確認
