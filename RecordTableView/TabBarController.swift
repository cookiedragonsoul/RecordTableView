//
//  TabBarController.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/11/01.
//

import UIKit

@objc protocol TabBarDelegate {
    func didSelectTab(tabBarController: TabBarController)
}

class TabBarController: UITabBarController,UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is ReportViewController{
            let v = viewController as! ReportViewController
            v.didSelectTab(tabBarController: self)
        }
    }
    
}
