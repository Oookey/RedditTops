//
//  CoreDataService.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 08.12.2020.
//

import Foundation
import CoreData

class CoreDataService {
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores { _, error in
      guard let error = error as NSError? else { return }
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }
    return container
  }()
  
//  var fetchResultController: NSFetchedResultsController = {
//    let controller = NSFetchedResultsController(fetchRequest: <#T##NSFetchRequest<_>#>,
//                                                managedObjectContext: <#T##NSManagedObjectContext#>,
//                                                sectionNameKeyPath: <#T##String?#>,
//                                                cacheName: <#T##String?#>)
//  }()
  
  private var context: NSManagedObjectContext {
    return self.persistentContainer.viewContext
  }
  
  private func saveContext() {
    if self.context.hasChanges {
      do {
        try self.context.save()
      } catch(let error) {
        self.context.rollback()
        print(error)
      }
    }
  }
  
  private func post(from response: ApiPost) -> RedditPost {
    let redditPost = RedditPost(context: self.context)
    redditPost.author = response.author
    redditPost.comments = Int32(response.comments)
    redditPost.id = response.id
    redditPost.title = response.title
    redditPost.image = self.postMultimedia(from: response)
    return redditPost
  }
  
  private func postMultimedia(from response: ApiPost) -> Multimedia? {
    guard
      let imageContent = response.image.images.first
    else { return nil }
    
    let image = Multimedia(context: self.context)
    image.height = Int32(imageContent.source.height)
    image.width = Int32(imageContent.source.width)
    image.url = imageContent.source.url

    return image
  }
}
