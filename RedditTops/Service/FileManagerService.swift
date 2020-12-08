//
//  FileManagerService.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 08.12.2020.
//

import Foundation

class FileManagerService {
  private var fileManager = FileManager.default
  
  private var documentsDirectory: URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  func save(thumbnail: inout Thumbnail) throws {
    let folderUrl = self.documentsDirectory.appendingPathComponent(thumbnail.postId)
    let imageDataUrl = folderUrl.appendingPathComponent(Keys.thumbnail)

    try? self.createDirectory(name: thumbnail.postId)

    self.fileManager.createFile(atPath: imageDataUrl.path,
                                contents: thumbnail.content,
                                attributes: nil)
    
    thumbnail.storageUrl = folderUrl
  }
  
  func getThumbnail(from post: String) throws -> Thumbnail {
    let folderUrl = self.documentsDirectory.appendingPathComponent(post)
    
    guard self.direcrotyExists(at: folderUrl.path) else { throw FileManagerError.fileDoesNotExists }

    let imageDataUrl = folderUrl.appendingPathComponent(Keys.thumbnail)

    guard
      let imageData = self.fileManager.contents(atPath: imageDataUrl.path)
    else { throw FileManagerError.fileDoesNotExists }
    
    return Thumbnail(url: "", postId: post, storageUrl: imageDataUrl, content: imageData)
  }
  
  func save(image: inout LocalImage) throws {
    let encoder = PropertyListEncoder()
    let folderUrl = self.documentsDirectory.appendingPathComponent(image.postId)
    let imageDataUrl = folderUrl.appendingPathComponent(Keys.image)
    let parametersUrl = folderUrl.appendingPathComponent(Keys.parameters)
    
    try? self.createDirectory(name: image.postId)
    
    self.fileManager.createFile(atPath: parametersUrl.path,
                                contents: try encoder.encode(image.imageData),
                                attributes: nil)
    
    self.fileManager.createFile(atPath: imageDataUrl.path,
                                contents: image.content,
                                attributes: nil)
    
    image.storageUrl = folderUrl
  }
  
  func getImage(from post: String) throws -> LocalImage? {
    let folderUrl = self.documentsDirectory.appendingPathComponent(post)
    
    guard self.direcrotyExists(at: folderUrl.path) else { throw FileManagerError.fileDoesNotExists }
    
    let imageDataUrl = folderUrl.appendingPathComponent(Keys.image)
    let parametersUrl = folderUrl.appendingPathComponent(Keys.parameters)

    guard
      let imageData = self.fileManager.contents(atPath: imageDataUrl.path),
      let parametersData = self.fileManager.contents(atPath: parametersUrl.path)
    else { throw FileManagerError.fileDoesNotExists }
    
    let parameters = try PropertyListDecoder().decode(ImageData.self, from: parametersData)
    
    return LocalImage(postId: post, imageData: parameters, storageUrl: folderUrl, content: imageData)
  }
  
  private func createDirectory(name: String) throws {
    let url = self.documentsDirectory
      .appendingPathComponent(Keys.mainDirectoryName)
      .appendingPathComponent(name)
    
    guard !self.direcrotyExists(at: url.path) else { throw FileManagerError.directoryExists }
    
    try self.fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
  }
  
  private func direcrotyExists(at path: String) -> Bool {
    var isDirectory = ObjCBool(true)
    let exists = self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
  }
  
  private struct Keys {
    static let mainDirectoryName: String = "RedditPosts"
    static let thumbnail: String = "thumbnail"
    static let image: String = "image"
    static let parameters: String = "parameters.plist"
  }
}

enum FileManagerError: String, LocalizedError {
  case directoryExists = "Directory already exists"
  case fileDoesNotExists = "File does not exists"
  
  var errorDescription: String? {
    return self.rawValue
  }
}
