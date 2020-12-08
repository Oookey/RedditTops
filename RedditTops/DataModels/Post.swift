//
//  Post.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 08.12.2020.
//

import Foundation

struct Post {
  let id: String
  let title: String
  let author: String
  let thumbnail: Thumbnail
  let image: LocalImage
  let comments: Int
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
  var content: Data
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
  let thumbnailUrl: String
  let created: TimeInterval
  let image: Preview
  let comments: Int
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case title = "title"
    case author = "author"
    case thumbnailUrl = "thumbnail"
    case created = "created"
    case image = "preview"
    case comments = "num_comments"
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
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.title = try container.decode(String.self, forKey: .title)
    self.author = try container.decode(String.self, forKey: .author)
    self.thumbnailUrl = try container.decode(String.self, forKey: .thumbnailUrl)
    self.created = try container.decode(TimeInterval.self, forKey: .created)
    self.image = try container.decode(Preview.self, forKey: .image)
    self.comments = try container.decode(Int.self, forKey: .comments)
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
