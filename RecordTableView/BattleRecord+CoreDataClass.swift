//
//  BattleRecord+CoreDataClass.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/10/21.
//
//

import Foundation
import CoreData

@objc(BattleRecord)
public class BattleRecord: NSManagedObject {
    static func getAll() -> [BattleRecord]{
        return CoreDataRepository.array(whereStr:"", fetchLimit:nil, asc:true)
    }
    static func getAll(whereStr:String) -> [BattleRecord]{
        return CoreDataRepository.array(whereStr:whereStr, fetchLimit:nil, asc:true)
    }
    
    static func getAll(fetchLimit:Int?, asc:Bool) -> [BattleRecord]{
        return CoreDataRepository.array(whereStr:"", fetchLimit:fetchLimit, asc:asc)
    }
    
    static func new(createdDate:Date?,player1Name:String,player2Name:String,player3Name:String,player4Name:String,winnerNum:Int16
                    ,commander1:String,commander2:String,commander3:String,commander4:String,commander5:String
                    ,commander6:String,commander7:String,commander8:String    ) -> BattleRecord{
        let entity: BattleRecord = CoreDataRepository.entity()
        entity.createdDate = createdDate
        entity.createdDateStr = getStrDateForCurrentTimeZone(myDate:createdDate)
        entity.player1Name = player1Name
        entity.player2Name = player2Name
        entity.player3Name = player3Name
        entity.player4Name = player4Name
        entity.winnerNum = winnerNum
        entity.commander1 = commander1
        entity.commander2 = commander2
        entity.commander3 = commander3
        entity.commander4 = commander4
        entity.commander5 = commander5
        entity.commander6 = commander6
        entity.commander7 = commander7
        entity.commander8 = commander8
        return entity
    }
    //引数なし
    static func new() -> BattleRecord{
        return new(createdDate:nil,player1Name:"",player2Name:"",player3Name:"",player4Name:"",winnerNum:0
                   ,commander1:"",commander2:"",commander3:"",commander4:"",commander5:"",commander6:"",commander7:"",commander8:"")
    }
    
    //端末のtimeZone,Localeを考慮した日時をString型で返す
    private static func getStrDateForCurrentTimeZone(myDate: Date?) -> String {
        if(myDate == nil){ return ""}
        let df = DateFormatter()
        df.locale = Locale.current
        df.timeZone = TimeZone.current
        df.dateStyle = .short
        df.timeStyle = .short
        return df.string(from: myDate!)
    }
}
