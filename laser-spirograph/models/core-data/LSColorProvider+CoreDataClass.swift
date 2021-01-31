//
//  LSColorProvider+CoreDataClass.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/31/21.
//
//

import Foundation
import CoreData
import UIKit.UIColor
import os.log

@objc(LSColorProvider)
public class LSColorProvider: NSManagedObject {
    
    // MARK: Properties
    
    private static var defaultPrimaryColor = UIColor.LSColors.Green532Nanometers
    
    // MARK: Initialization
    
    convenience init(context: NSManagedObjectContext, primaryColor: UIColor) {
        self.init(context: context)
        self.primaryColor = primaryColor
    }
    
    static func shared(context: NSManagedObjectContext) -> LSColorProvider {
        let fetchRequest: NSFetchRequest<LSColorProvider> = self.fetchRequest()
        fetchRequest.fetchLimit = 1
        return (try? context.fetch(fetchRequest).first) ?? LSColorProvider(context: context, primaryColor: defaultPrimaryColor)
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
            os_log("Failed to save LSColorProvider with error: %@", error.localizedDescription)
            return error
        }
        
        return nil
    }
}
