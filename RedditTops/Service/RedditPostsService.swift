//
//  RedditPostsService.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 08.12.2020.
//

import Foundation

protocol RedditPostsLocalDataDelegate: class {
  func service(_ service: RedditPostsLocalDataDelegate, didSaveThumbnail thumbnail: Thumbnail)
  func service(_ service: RedditPostsLocalDataDelegate, didSaveImage image: ImageData)
  
  func service(_ service: RedditPostsLocalDataDelegate, didLoadThumbnail thumbnail: Thumbnail)
  func service(_ service: RedditPostsLocalDataDelegate, didLoadImage image: ImageData)
}

class RedditPostsService {
  private lazy var networkManager: NetworkManager = NetworkManager()
  private lazy var fileManager: FileManagerService = FileManagerService()

  private var limit: Int = 25
  private var before: String?
  private var after: String?
  
  weak var localDataDelegate: RedditPostsLocalDataDelegate?
  
  func reloadPosts() {
    self.before = nil
    self.after = nil
    
    self.loadNextPosts()
  }
  
  func loadNextPosts() {
    
  }
  
  private func loadReddintPosts(before: String?, after: String, limit: Int) {
    self.networkManager.getTopPosts(before: before, after: after, limit: limit) { response, error in
      response
    }
  }
  
  func load(thumbnail stringUrl: String, postId: String) {
    let url = URL(string: stringUrl)
    
    self.networkManager.loadImage(from: url) { data, error in
      guard let data = data else { return }
      
      var thumbnail = Thumbnail(url: stringUrl, postId: postId, storageUrl: nil, content: data)
      do {
        try self.fileManager.save(thumbnail: &thumbnail)
      } catch(let error) {
        print(error)
      }
    }
  }
  
  func load(image: ImageData, postId: String) {
    let url = URL(string: image.url)
    
    self.networkManager.loadImage(from: url) { data, error in
      guard let data = data else { return }
      
      var localImage = LocalImage(postId: postId, imageData: image, storageUrl: nil, content: data)
      do {
        try self.fileManager.save(image: &localImage)
      } catch(let error) {
        print(error)
      }
    }
  }
}
