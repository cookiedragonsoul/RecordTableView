//
//  CoreDataRepository.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/10/21.
//

import UIKit
import CoreData

class CoreDataRepository{
    init(){}

    private static var persistentContainer :NSPersistentContainer! = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    private static var context: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    static func entity<T: NSManagedObject>() -> T{
        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: T.self),in: context)!
        return T(entity: entityDescription, insertInto: nil)
    }
    
    static func array<T: NSManagedObject>(whereStr:String, fetchLimit:Int?, asc:Bool) -> [T]{
        do{
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            //検索条件を指定
            if(whereStr != ""){
                request.predicate = NSPredicate(format: whereStr)
            }
            //取得件数上限を指定
            if let limit = fetchLimit {
                request.fetchLimit = limit
            }
            //取得順序(昇順/降順)を指定
            request.sortDescriptors = [NSSortDescriptor(key:"createdDate", ascending:asc)]
            
            return try context.fetch(request)
        }catch{
            fatalError()
        }
    }
    
    static func insert(_ object: NSManagedObject){
        context.insert(object)
    }
    
    static func delete(_ object: NSManagedObject){
        context.delete(object)
    }
}


extension CoreDataRepository{
    static func save(){
        guard context.hasChanges else{
            return
        }
        do{
            try context.save()
        }catch let error as NSError{
            debugPrint("Error: \(error), \(error.userInfo)")
        }
    }
    
    static func rollback(){
        guard context.hasChanges else{return}
        context.rollback()
    }
    
}
