//
//  DataManager.swift
//  MemoApp
//
//  Created by jung on 2021/07/12.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    private init(){
        //Singleton(싱글톤)
    }
    // 공유 인스턴스를 저장할 타입 프로퍼티
    var sections : [String] = []
    
    func reloadSection(){
        sections.removeAll()
        if(pinMemoList.count > 0) {
            sections.append("Pin Memo")
        } else if(memoList.count > 0) {
            sections.append("Memo")
        }
    }
    
    var mainContext : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var memoList = [Memo]()
    var pinMemoList = [PinMemo]()
    
    func fetchMemo(){
        let request : NSFetchRequest<Memo> = Memo.fetchRequest() // 코어 데이터가 리턴해주는 데이터는 정렬이안되있음
        
        let requestForPin : NSFetchRequest<PinMemo> = PinMemo.fetchRequest()
        
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        requestForPin.sortDescriptors = [sortByDateDesc]
        
        do{
           memoList = try mainContext.fetch(request) // 데이터를 가져옴
            pinMemoList = try mainContext.fetch(requestForPin)
        // 날짜를 기준으로 정렬한 결과가 메모리스트에 저장됨
        } catch{
            print(error)
        }
    } // 데이터 베이스에서 데이터를 읽어옴
    
    func addNewMemo(_ memo : String?) {
        let newMemo = Memo(context: mainContext)
        newMemo.content = memo
        newMemo.insertDate = Date() // 새로운 메모 형셩
        
        memoList.insert(newMemo, at: 0) // 1번째 에 삽입
        
        saveContext() // DB에 저장
    }
    
    func deleteMemo (_ memo : Memo?){
        if let memo = memo {
            mainContext.delete(memo)
            saveContext()
        }
    }
    
    func addPinMemo(_ memo : Memo?){ // pin메모 추가
        let newPinMemo = PinMemo(context: mainContext)
        newPinMemo.content = memo?.content
        newPinMemo.insertDate = memo?.insertDate
        
        pinMemoList.append(newPinMemo)
        
        saveContext()
    }
    
    
    func removePin (_ pinmemo : PinMemo?){
        let newMemo = Memo(context: mainContext)
        newMemo.content = pinmemo?.content
        newMemo.insertDate = pinmemo?.insertDate
        
        memoList.append(newMemo)
        saveContext()
    }
    
    func deletePinMemo (_ memo : PinMemo?){
        if let memo = memo {
            mainContext.delete(memo)
            saveContext()
        }
    }
    
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
    
        let container = NSPersistentContainer(name: "MemoApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer
        if context.viewContext.hasChanges {
            do {
                try context.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

