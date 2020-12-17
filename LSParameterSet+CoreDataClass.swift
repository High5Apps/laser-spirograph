//
//  LSParameterSet+CoreDataClass.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/16/20.
//
//

import Foundation
import CoreData

enum LSParameterSetError: Error {
    case managedObjectContextNil
}

@objc(LSParameterSet)
public class LSParameterSet: NSManagedObject {
    
    // MARK: Properties
    
    var rotationsPerSeconds: [Double] {
        set {
            newValue.enumerated().forEach() { (i, phase) in
                setValue(phase, forKey: "rotationsPerSecond\(i)")
            }
        }
        
        get {
            Array(0..<Self.circleCount).map() { self.value(forKey: "rotationsPerSecond\($0)") as! Double }
        }
    }
    
    var phases: [Double] {
        set {
            newValue.enumerated().forEach() { (i, phase) in
                setValue(phase, forKey: "phase\(i)")
            }
        }
        
        get {
            Array(0..<Self.circleCount).map() { self.value(forKey: "phase\($0)") as! Double }
        }
    }
    
    var displayName: String {
        name ?? Self.dateFormatter.string(from: createdAt!)
    }
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private static let circleCount: Int = 4
    
    // MARK: Initialization
    
    convenience init(context: NSManagedObjectContext, startTime: TimeInterval, endTime: TimeInterval, rotationsPerSeconds: [Double], phases: [Double]) {
        self.init(context: context)
        
        self.startTime = startTime
        self.endTime = endTime
        self.rotationsPerSeconds = rotationsPerSeconds
        self.phases = phases
        self.createdAt = Date()
    }
    
    // MARK: Saving
    
    @discardableResult
    func save() -> NSError? {
        guard let managedObjectContext = managedObjectContext else {
            return LSParameterSetError.managedObjectContextNil as NSError
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            return error
        }
        
        return nil
    }
    
    // MARK: Deleting
    
    @discardableResult
    func delete() -> NSError? {
        managedObjectContext?.delete(self)
        return save()
    }
    
    // MARK: Fetching
    
    class func fetchAllByRecency(context: NSManagedObjectContext) -> [LSParameterSet] {
        let fetchRequest: NSFetchRequest<LSParameterSet> = self.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(fetchRequest)) ?? []
    }
}
