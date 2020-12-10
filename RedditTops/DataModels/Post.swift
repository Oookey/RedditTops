//
//  Post.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 08.12.2020.
//

import Foundation

extension URL {
  init?(fileURLWithPath path: String?) {
    guard let path = path else { return nil }
    self.init(fileURLWithPath: path)
  }
}

struct Post {
  let id: String
  let title: String
  let author: String
  let created: Date
  var thumbnail: Thumbnail?
  var image: LocalImage?
  let comments: Int
  let ups: Int
  
  init(with post: RedditPost) {
    self.id = post.id ?? ""
    self.title = post.title ?? ""
    self.author = post.author ?? ""
    self.created = post.created
    self.comments = Int(post.comments)
    self.ups = Int(post.ups)
    
    if let thumbnail = post.thumbnail, let url = thumbnail.url {
      let thumbnailStorageUrl = URL(fileURLWithPath: thumbnail.storageUrl)
      self.thumbnail = Thumbnail(url: url, postId: post.id ?? "", storageUrl: thumbnailStorageUrl, content: nil)
    } else {
      self.thumbnail = nil
    }
    
    if let image = post.image {
      let imageStorageUrl = URL(fileURLWithPath: image.storageUrl)
      let imageData = ImageData(url: image.url ?? "", width: Int(image.width), height: Int(image.height))
      let localImage = LocalImage(postId: post.id ?? "", imageData: imageData, storageUrl: imageStorageUrl, content: nil)

      self.image = localImage
    } else {
      self.image = nil
    }
  }
}

struct ImageData: Codable {
  let url: String
  let width: Int
  let height: Int
}

struct LocalImage {
  var postId: String
  var imageData: ImageData
  var storageUrl: URL?
  var content: Data?
}

struct Thumbnail {
  let url: String
  let postId: String
  var storageUrl: URL?
  var content: Data?
}

//MARK: - Api models

struct ApiPost: Codable {
  let id: String
  let title: String
  let author: String
  let thumbnailUrl: String?
  let created: TimeInterval
  let image: Preview?
  let comments: Int
  let ups: Int
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case title = "title"
    case author = "author"
    case thumbnailUrl = "thumbnail"
    case created = "created"
    case image = "preview"
    case comments = "num_comments"
    case ups = "ups"
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.title, forKey: .title)
    try container.encode(self.author, forKey: .author)
    try container.encode(self.thumbnailUrl, forKey: .thumbnailUrl)
    try container.encode(self.created, forKey: .created)
    try container.encode(self.image, forKey: .image)
    try container.encode(self.comments, forKey: .comments)
    try container.encode(self.ups, forKey: .ups)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.title = try container.decode(String.self, forKey: .title)
    self.author = try container.decode(String.self, forKey: .author)
    self.thumbnailUrl = try? container.decode(String?.self, forKey: .thumbnailUrl)
    self.created = try container.decode(TimeInterval.self, forKey: .created)
    self.image = try? container.decode(Preview?.self, forKey: .image)
    self.comments = try container.decode(Int.self, forKey: .comments)
    self.ups = try container.decode(Int.self, forKey: .ups)
  }
}

struct Preview: Codable {
  let images: [ImageContent]
}

struct ImageContent: Codable {
  let source: ImageData
  let resolutions: [ImageData]
  let id: String
}

struct ApiRespoinse: Codable {
  let data: ApiData
}

struct ApiData: Codable {
  let children: [ApiPostData]
  let before: String?
  let after: String?
}

struct ApiPostData: Codable {
  let data: ApiPost
}
