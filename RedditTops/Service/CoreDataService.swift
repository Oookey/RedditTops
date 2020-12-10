//
//  CoreDataService.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 08.12.2020.
//

import Foundation
import CoreData

class CoreDataService {
  var fetchBatchSize: Int = 0
  
  init(fetchBatchSize: Int = 0) {
    self.fetchBatchSize = fetchBatchSize
  }
  
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores { _, error in
      guard let error = error as NSError? else { return }
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }
    return container
  }()
  
  lazy var fetchedResultsController: NSFetchedResultsController<RedditPost> = {
    let request: NSFetchRequest<RedditPost> = RedditPost.fetchRequest()
    let sort = NSSortDescriptor(key: "ups", ascending: false)
    request.sortDescriptors = [sort]
    request.fetchBatchSize = self.fetchBatchSize
    
    return NSFetchedResultsController(fetchRequest: request,
                                      managedObjectContext: self.context,
                                      sectionNameKeyPath: nil,
                                      cacheName: nil)
  }()
    
  private var context: NSManagedObjectContext {
    return self.persistentContainer.viewContext
  }
  
  private func saveContext() {
    if self.context.hasChanges {
      do {
        try self.context.save()
      } catch {
        self.context.rollback()
        print(error)
      }
    }
  }
  
  private func fetchPost(with id: String) -> RedditPost? {
    do {
      let posts: [RedditPost] = try self.context.fetch(RedditPost.fetchRequest())
      return posts.first { $0.id == id }
    } catch {
      print(error)
      return nil
    }
  }
}

//MARK: - Core data actions

extension CoreDataService {
  func save(posts: [ApiPost], completion: @escaping () -> ()) {
    self.context.perform {
      posts.forEach { self.post(from: $0) }
      self.saveContext()
      completion()
    }
  }
  
  func update(thumbnail: Thumbnail) {
    self.context.perform {
      let post = self.fetchPost(with: thumbnail.postId)
      post?.thumbnail?.storageUrl = thumbnail.storageUrl?.path
      self.saveContext()
    }
  }
  
  func update(image: LocalImage) {
    self.context.perform {
      let post = self.fetchPost(with: image.postId)
      post?.image?.storageUrl = image.storageUrl?.path
      self.saveContext()
    }
  }
}

//MARK: - Object creation

extension CoreDataService {
  @discardableResult
  private func post(from response: ApiPost) -> RedditPost {
    let redditPost = self.fetchPost(with: response.id) ?? RedditPost(context: self.context)
    redditPost.author = response.author
    redditPost.comments = Int32(response.comments)
    redditPost.id = response.id
    redditPost.title = response.title
    redditPost.ups = Int32(response.ups)
    redditPost.created = Date(timeIntervalSince1970: response.created)
    redditPost.thumbnail = self.postThumbnail(from: response, thumbnail: redditPost.thumbnail)
    redditPost.image = self.postMultimedia(from: response, image: redditPost.image)
    return redditPost
  }
  
  private func postThumbnail(from response: ApiPost, thumbnail: ThumbnailInfo?) -> ThumbnailInfo? {
    let thumbnail = thumbnail ?? ThumbnailInfo(context: self.context)
    thumbnail.url = response.thumbnailUrl
    return thumbnail
  }
  
  private func postMultimedia(from response: ApiPost, image: Multimedia?) -> Multimedia? {
    guard
      let imageContent = response.image?.images.first
    else { return nil }
    
    let image = image ?? Multimedia(context: self.context)
    image.height = Int32(imageContent.source.height)
    image.width = Int32(imageContent.source.width)
    image.url = imageContent.source.url
    
    return image
  }
}
