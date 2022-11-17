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
    let bannerAdId = "ca-app-pub-3940256099942544/2934735716"
    public static var bannerAdHeight = 0.0  //自動計算されたバナー広告の高さを保持する
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        let viewWidth = UIScreen.main.bounds.width
        let bannerView:GADBannerView = GADBannerView()//adSize: GADAdSizeBanner)
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        TabBarController.bannerAdHeight = bannerView.adSize.size.height  //バナーの高さを保持
        
        bannerView.adUnitID = bannerAdId  // バナー広告のテスト用ID
        bannerView.rootViewController = self
        // bannerViewの開始位置=（x=0, y=親ビューの高さ（画面高さ） - タブバーの高さ49 - バナーの高さ）
        bannerView.frame.origin = CGPointMake(0, self.view.frame.size.height - 49.0 - TabBarController.bannerAdHeight) // 座標設定
        
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
    
}
