//
//  RedditPostsService.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 08.12.2020.
//

import Foundation
import CoreData

//MARK: - RedditPostsService

protocol ImageLoadService: class {
  func load(url: URL, postId: String, imageData: ImageData, completion: @escaping (LocalImage?) -> ())
}

class RedditPostsService {
  private lazy var networkManager: NetworkManager = NetworkManager()
  private lazy var fileManager: FileManagerService = FileManagerService()
  private lazy var coreData: CoreDataService = CoreDataService(fetchBatchSize: self.limit)
  
  private var isFetchingNextPage = false
  private var limit: Int = 25
  private var before: String?
  private var after: String?
  
  var fetchResultsController: NSFetchedResultsController<RedditPost> {
    return self.coreData.fetchedResultsController
  }
  
  func getThumbnail(from post: String) -> Thumbnail? {
    do {
      return try self.fileManager.getThumbnail(from: post)
    } catch {
      print(error)
      return nil
    }
  }
  
  //MARK: - Load Posts

  func reloadPosts() {
    self.before = nil
    self.after = nil
    
    self.loadNextPosts()
  }
  
  func loadNextPosts() {
    guard !self.isFetchingNextPage else { return }
    
    self.isFetchingNextPage = true
    self.loadReddintPosts(before: self.before, after: self.after, limit: self.limit)
  }
  
  private func loadReddintPosts(before: String?, after: String?, limit: Int) {
    self.networkManager.getTopPosts(before: before, after: after, limit: limit) { [weak self] response, error in
      guard let self = self else { return }
      
      if let error = error {
        print(error)
        self.isFetchingNextPage = false
        return
      }
      
      guard let response = response?.data else {
        self.isFetchingNextPage = false
        return
      }
      
      self.before = response.before
      self.after = response.after
      let objects = response.children.map { $0.data }
      
      self.coreData.save(posts: objects) { [weak self] in
        objects.forEach { self?.load(thumbnail: $0.thumbnailUrl, postId: $0.id) }
      }
      
      self.isFetchingNextPage = false
    }
  }
  
  //MARK: - Load Images

  func load(thumbnail stringUrl: String?, postId: String) {
    guard
      !self.fileManager.fileExists(post: postId, .thumbnail),
      let stringUrl = stringUrl
    else { return }

    let url = URL(string: stringUrl)
    
    self.networkManager.loadImage(from: url) { [weak self] data, error in
      guard let data = data else { return }
      
      var thumbnail = Thumbnail(url: stringUrl, postId: postId, storageUrl: nil, content: data)
      do {
        thumbnail.storageUrl = try self?.fileManager.save(thumbnail: thumbnail)
        self?.coreData.update(thumbnail: thumbnail)
      } catch {
        print(error)
      }
    }
  }
}

extension RedditPostsService: ImageLoadService {
  func load(url: URL, postId: String, imageData: ImageData, completion: @escaping (LocalImage?) -> ()) {
    guard !self.fileManager.fileExists(post: postId, .image) else {
      let image = try? self.fileManager.getImage(from: postId)
      completion(image)
      return
    }
      
    self.networkManager.loadImage(from: url) { [weak self] data, error in
      guard let data = data else { completion(nil); return }

      var localImage = LocalImage(postId: postId, imageData: imageData, storageUrl: nil, content: data)
      do {
        try self?.fileManager.save(image: &localImage)
        self?.coreData.update(image: localImage)
        completion(localImage)
      } catch {
        print(error)
        completion(nil)
      }
    }
  }
}
