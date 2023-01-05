# うちの在庫

## 1.概要
このアプリは家庭の食品や日用品など様々な物を管理するためのアプリです。

賞味期限が近いことを通知したり、買い物リストを作成して必要なものを買い忘れないようにすることができます。

iCloudに対応しているので、同じアカウントでログインしているデバイス間でデータを共有することができます。

## 2.機能
### 登録画面

### フォルダ画面

### 設定画面

## 3.データベースの設計
CoreDataモデル

エンティティFolderとItemのリレーションシップ

- Folder

| 属性 | 型 | 概要 |
----|----|----
| name | String | フォルダ名 |
| id | UUID | フォルダの識別ID |
| icon | String | フォルダのアイコンの名前 |
| isStock | Boolean | true = 在庫リスト, false = 買い物リスト |
| items | Item | フォルダ内のアイテムデータ。 1対多のリレーションシップ |

- Item

| 属性 | 型 | 概要 |
----|----|----
| name | String | 商品名 |
| id | UUID | データの識別ID |
| image | Binary Data | 画像データ |
| numberOfItems | Integer 16 | 個数 |
| registrationDate | Date | 登録・更新された日付 |
| deadLine | Date | 賞味期限・使用期限の日付（在庫リストのみ） |
| notificationDate | Date | 期限が近いことを知らせる通知の日付（在庫リストのみ） |
| status | String | 在庫の状態。"未開封"・"開封済み"・"残りわずか"を選択する（在庫リストのみ） |
| isHurry | Boolean | 買い物の緊急性。"緊急"・"通常"を選択する（買い物リストのみ） |
| folder | Folder | 所属しているフォルダ。 1対1のリレーションシップ |


## 4.開発環境
- Xcode 14.2
- macOS Ventura 13.1
- iOS16.0

## 5.画像素材
[フリーイラスト素材集 ジャパクリップ](https://japaclip.com/)

[かわいいフリー素材集　いらすとや](https://www.irasutoya.com/)
