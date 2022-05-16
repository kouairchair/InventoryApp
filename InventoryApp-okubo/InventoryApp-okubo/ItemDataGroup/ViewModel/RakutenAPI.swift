//
//  RakutenAPI.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/04/01.
//

import SwiftUI

// MARK: -　クラス
class RakutenAPI {
    
    // MARK: - 構造体
    ///JSONのデータ構造 （楽天市場API）
    private struct IchibaJson: Codable {
        ///JSONのitems内のデータ構造
        struct Items: Codable {
            ///商品名
            let itemName: String
            ///画像URL
            //            let smallImageUrls: [String]
            let mediumImageUrls: [String]
        }
        //データを受け取る変数
        let Items: [Items]
    }
    
    // MARK: - プロパティ
    ///APIで取得した商品名
    var resultItemName = ""
    ///APIで取得した画像データ
    var resultImageData: Data? = nil
    ///APIで取得したデータの配列
    var resultItem: [(name: String, image: Data?)] = []
    //plistの値を受け取る変数
    private var property: Dictionary<String, Any> = [:]
    
    // MARK: - イニシャライザ
    //初期化　変数'property'に'Api.plist'の値を入れる
    init() {
        //Api.plistのパス取得
        let path = Bundle.main.path(forResource: "Api", ofType: "plist")
        //plistをDictionary形式で読み込み
        let configurations = NSDictionary(contentsOfFile: path!)
        if let datasourceDictionary: [String : Any] = configurations as? [String: Any] {
            property = datasourceDictionary
            print("plist:\(property)")
        }
    }
    
    // MARK: - メソッド
    ///楽天市場APIを使用する関数
    func searchItem(itemCode: String, finish: @escaping(_ : SearchResult) -> Void ) {
        //ベースURL
        let baseURL = getProperty(key: "baseURL")
        //アプリケーションID
        let applicationId = getProperty(key: "applicationId")
        //入力パラメータ（読み取った値）
        var requestParams = "&keyword=" + itemCode
        //入力パラメータ（固定の値）
        let params: KeyValuePairs = ["format" : "json",
                                     "formatVersion" : "2",
                                     "hits" : "1",
                                     "imageFlag" : "1",
                                     "sort" : "-updateTimestamp",
                                     "elements" : "itemName,mediumImageUrls"]
        //パラメータをURLの形につなげる
        for (key, value) in params {
            requestParams += "&" + key + "=" + value
        }
        //URL作成
        let requestURL = baseURL + applicationId + requestParams
        print("リクエストURL: \(requestURL)")
        guard let url = URL(string: requestURL) else { return }
        //URLリクエストの生成
        let request = URLRequest(url: url, timeoutInterval: 8.0)
        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            if let itemData = data {
                let decoder = JSONDecoder()
                do {
                    let jsonData = try decoder.decode(IchibaJson.self, from: itemData)
                    //商品名を取得
                    self.resultItemName = jsonData.Items[0].itemName
                    print("商品名" + self.resultItemName)
                    //画像URLを取得
                    let imageURL = jsonData.Items[0].mediumImageUrls[0]
                    print("画像URL:" + imageURL)
                    //取得したURLから画像を読み込む
                    guard let url = URL(string: imageURL) else { return }
                    // TODO: - 非同期処理にasync/awaitを使う
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url)
                        DispatchQueue.main.async {
                            self.resultImageData = data
                            self.resultItem.append((name: self.resultItemName, image: self.resultImageData))
                            //BarcodeReaderViewでアラート起動
                            //クロージャ起動
                            finish(SearchResult.success)
                        }
                    }
                } catch {
                    print("データがありません")
                    DispatchQueue.main.async {
                        //データがなかった場合のアラート
                        //クロージャ起動
                        finish(SearchResult.failure)
                    }
                }
            } else {
                //接続エラー（タイムアウト含む）
                print("接続エラー：\(String(describing: error?.localizedDescription))")
                DispatchQueue.main.async {
                    //接続に失敗した場合のアラート
                    //クロージャ起動
                    finish(SearchResult.error)
                }
            }
        }
        //セッション開始
        session.resume()
    }
    ///plistから文字列を取得する関数
    private func getProperty(key: String) -> String {
        guard let value = property[key] as? String else {
            print("plist: エラー")
            return ""
        }
        print("plist: \(value)")
        return value
    }
}
