//
//  TabBarController.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/11/01.
//

import UIKit
import GoogleMobileAds

@objc protocol TabBarDelegate {
    func didSelectTab(tabBarController: TabBarController)
}

class TabBarController: UITabBarController,UITabBarControllerDelegate {
    public static var commanderNameList:[String] = []  //リーダーの名前をcsvから取得して保持する
    let bannerAdId = "ca-app-pub-3940256099942544/2934735716"
    public static var bannerAdHeight = 0.0  //自動計算されたバナー広告の高さを保持する
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        TabBarController.commanderNameList = getCommanerArr()  //リーダー名の配列を生成
        
        let tabBarY = self.tabBar.frame.minY  //タブバーのY座標を保持
        let bannerView:GADBannerView = GADBannerView()//adSize: GADAdSizeBanner)
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        TabBarController.bannerAdHeight = bannerView.adSize.size.height  //バナーの高さを保持
        if #available(iOS 11.0, *) {
            //ホームボタンがない端末は画面下のホームインジケータ(横棒)の高さを追加 ※このメソッドはiOS11以上のみ対応。ホームボタンがない端末はiOS10以下はないので問題なし
            TabBarController.bannerAdHeight += Double(UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 0.0)
        }
        bannerView.adUnitID = bannerAdId  // バナー広告のテスト用ID
        bannerView.rootViewController = self
        // bannerViewの開始位置=（x=0, y=タブバーのy位置 - バナーの高さ - ホームインジケータの高さ）
        bannerView.frame.origin = CGPointMake(0, tabBarY - TabBarController.bannerAdHeight)  // 座標設定
        
        self.view.addSubview(bannerView)
        bannerView.load(GADRequest())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //タブの切り替えが起こったときに呼ばれる
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //レポートタブが選択された場合に、グラフの再読み込み等の処理を走らせる
        if viewController is ReportViewController{
            let v = viewController as! ReportViewController
            v.didSelectTab(tabBarController: self)
        }
    }
    
    //csvファイルからリーダー名の配列を取得する関数
    func getCommanerArr() -> [String]{
        var resultArr:[String] = []
        let csvBundle = Bundle.main.path(forResource: "commanderNameList", ofType: "csv")!  //csvファイルを取得
        do{
            let csvData = try String(contentsOfFile: csvBundle,encoding: String.Encoding.utf8)  //取得したcsvファイルをエンコード
            resultArr = csvData.components(separatedBy: "\n").filter{$0 != ""}
        }catch let error as NSError{
            debugPrint("Error: \(error), \(error.userInfo)")
        }
        return resultArr
    }
    
}
