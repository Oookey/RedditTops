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
  
  private func createDirectory(name: String) throws -> URL {
    let url = self.documentsDirectory
      .appendingPathComponent(Keys.mainDirectoryName)
      .appendingPathComponent(name)
    
    try self.fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    return url
  }
}

//MARK: - Thumbnail

extension FileManagerService {
  func save(thumbnail: Thumbnail) throws -> URL {
    let folderUrl: URL = try self.createDirectory(name: thumbnail.postId)
    let imageDataUrl = folderUrl.appendingPathComponent(Keys.thumbnail)
    
    guard
      !self.fileManager.fileExists(atPath: imageDataUrl.path),
      self.fileManager.createFile(atPath: imageDataUrl.path,
                                  contents: thumbnail.content,
                                  attributes: nil)
    else { throw FileManagerError.unableToCreateFile }
    return imageDataUrl
  }
  
  func fileExists(post: String, _ type: FileType) -> Bool {
    let fileUrl = self.documentsDirectory
      .appendingPathComponent(Keys.mainDirectoryName)
      .appendingPathComponent(post)
      .appendingPathComponent(type == .thumbnail ? Keys.thumbnail : Keys.image)
    
    return self.fileManager.fileExists(atPath: fileUrl.path)
  }
  
  func getThumbnail(from post: String) throws -> Thumbnail {
    let fileUrl = self.documentsDirectory
      .appendingPathComponent(Keys.mainDirectoryName)
      .appendingPathComponent(post)
      .appendingPathComponent(Keys.thumbnail)

    guard
      let imageData = self.fileManager.contents(atPath: fileUrl.path)
    else { throw FileManagerError.unableToReadFile }
    
    return Thumbnail(url: "", postId: post, storageUrl: fileUrl, content: imageData)
  }
  
  //MARK: - Image
}

extension FileManagerService {
  func save(image: inout LocalImage) throws {
    let encoder = PropertyListEncoder()
    let folderUrl: URL = try self.createDirectory(name: image.postId)

    let imageDataUrl = folderUrl.appendingPathComponent(Keys.image)
    let parametersUrl = folderUrl.appendingPathComponent(Keys.parameters)
        
    self.fileManager.createFile(atPath: parametersUrl.path,
                                contents: try encoder.encode(image.imageData),
                                attributes: nil)
    
    self.fileManager.createFile(atPath: imageDataUrl.path,
                                contents: image.content,
                                attributes: nil)
    
    image.storageUrl = folderUrl
  }
  
  func getImage(from post: String) throws -> LocalImage? {
    let folderUrl = self.documentsDirectory
      .appendingPathComponent(Keys.mainDirectoryName)
      .appendingPathComponent(post)
        
    let imageDataUrl = folderUrl.appendingPathComponent(Keys.image)
    let parametersUrl = folderUrl.appendingPathComponent(Keys.parameters)

    guard
      let imageData = self.fileManager.contents(atPath: imageDataUrl.path),
      let parametersData = self.fileManager.contents(atPath: parametersUrl.path)
    else { throw FileManagerError.unableToReadFile }
    
    let parameters = try PropertyListDecoder().decode(ImageData.self, from: parametersData)
    
    return LocalImage(postId: post, imageData: parameters, storageUrl: folderUrl, content: imageData)
  }
}

//MARK: - Misc

extension FileManagerService {
  private struct Keys {
    static let mainDirectoryName: String = "RedditPosts"
    static let thumbnail: String = "thumbnail"
    static let image: String = "image"
    static let parameters: String = "parameters.plist"
  }
  
  enum FileType {
    case thumbnail, image
  }
}

//MARK: - FileManagerError

enum FileManagerError: String, LocalizedError {
  case directoryExists = "Directory already exists"
  case fileDoesNotExists = "File does not exists"
  case unableToCreateFile = "Unable to create file"
  case unableToReadFile = "Unable to read file"

  var errorDescription: String? {
    return self.rawValue
  }
}
