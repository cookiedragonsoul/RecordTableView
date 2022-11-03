//
//  BarReportView.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/10/24.
//

import SwiftUI
import Charts


/*struct ToyShape: Identifiable{
    var type:String
    var count: Double
    var id:String{type}
}*/
struct BarReportView: View{
    var body: some View{
        if #available(iOS 16.0, *) {
        //    Chart{
        //        BarMark(
        //            x: .value("aa", 5),
        //            y: .value("bb", 7)
        //        )
        //    }
        } else {
            // Fallback on earlier versions
        }
        
    }
}
