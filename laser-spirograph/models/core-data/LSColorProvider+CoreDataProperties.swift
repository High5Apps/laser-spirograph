//
//  LSColorProvider+CoreDataProperties.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/31/21.
//
//

import Foundation
import CoreData
import UIKit.UIColor


extension LSColorProvider {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LSColorProvider> {
        return NSFetchRequest<LSColorProvider>(entityName: "LSColorProvider")
    }
    
    @NSManaged public var primaryColor: UIColor

}

extension LSColorProvider : Identifiable {}
