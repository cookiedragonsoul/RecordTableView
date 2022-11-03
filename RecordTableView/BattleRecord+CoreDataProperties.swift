//
//  BattleRecord+CoreDataProperties.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/10/21.
//
//

import Foundation
import CoreData


extension BattleRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BattleRecord> {
        return NSFetchRequest<BattleRecord>(entityName: "BattleRecord")
    }

    @NSManaged public var commander1: String?
    @NSManaged public var commander2: String?
    @NSManaged public var commander3: String?
    @NSManaged public var commander4: String?
    @NSManaged public var commander5: String?
    @NSManaged public var commander6: String?
    @NSManaged public var commander7: String?
    @NSManaged public var commander8: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var createdDateStr: String?
    @NSManaged public var player1Name: String?
    @NSManaged public var player2Name: String?
    @NSManaged public var player3Name: String?
    @NSManaged public var player4Name: String?
    @NSManaged public var winnerNum: Int16

}

extension BattleRecord : Identifiable {

}
