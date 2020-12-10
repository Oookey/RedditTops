//
//  ThumbnailInfo+CoreDataProperties.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 09.12.2020.
//
//

import Foundation
import CoreData


extension ThumbnailInfo {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ThumbnailInfo> {
    return NSFetchRequest<ThumbnailInfo>(entityName: "ThumbnailInfo")
  }
  
  @NSManaged public var url: String?
  @NSManaged public var storageUrl: String?
  @NSManaged public var post: RedditPost?
  
}

extension ThumbnailInfo : Identifiable {
  
}
