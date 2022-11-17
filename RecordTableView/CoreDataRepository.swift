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
    
    static func array<T: NSManagedObject>(whereStr:String) -> [T]{
        do{
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            if(whereStr != ""){
                request.predicate = NSPredicate(format: whereStr)  //where句を設定
            }
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
