//
//  RedditPost+CoreDataProperties.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 08.12.2020.
//
//

import Foundation
import CoreData

extension RedditPost {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<RedditPost> {
    return NSFetchRequest<RedditPost>(entityName: "RedditPost")
  }
  
  @NSManaged public var id: String?
  @NSManaged public var title: String?
  @NSManaged public var author: String?
  @NSManaged public var comments: Int32
  @NSManaged public var image: Multimedia?
  
}

extension RedditPost : Identifiable {
  
}
