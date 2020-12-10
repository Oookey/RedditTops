//
//  Multimedia+CoreDataProperties.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 09.12.2020.
//
//

import Foundation
import CoreData


extension Multimedia {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Multimedia> {
    return NSFetchRequest<Multimedia>(entityName: "Multimedia")
  }
  
  @NSManaged public var height: Int32
  @NSManaged public var storageUrl: String?
  @NSManaged public var url: String?
  @NSManaged public var width: Int32
  @NSManaged public var created: Double
  @NSManaged public var post: RedditPost?
  
}

extension Multimedia : Identifiable {
  
}
