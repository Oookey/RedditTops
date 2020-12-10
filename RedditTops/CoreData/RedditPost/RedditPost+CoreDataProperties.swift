//
//  RedditPost+CoreDataProperties.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 09.12.2020.
//
//

import Foundation
import CoreData


extension RedditPost {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<RedditPost> {
    return NSFetchRequest<RedditPost>(entityName: "RedditPost")
  }
  
  @NSManaged public var author: String?
  @NSManaged public var comments: Int32
  @NSManaged public var ups: Int32
  @NSManaged public var id: String?
  @NSManaged public var title: String?
  @NSManaged public var created: Date
  @NSManaged public var image: Multimedia?
  @NSManaged public var thumbnail: ThumbnailInfo?
  
}

extension RedditPost : Identifiable {
  
}
