//
//  NetworkManager.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

struct NetworkManager {
  static let environment: NetworkEnvironment = .production
  let router = NetworkRouter<RedditApi>()
  
  func getTopPosts(before: String?, after: String?, limit: Int, completion: @escaping (_ response: ApiRespoinse?, _ error: Error?)->()) {
    self.router.request(.top(before: before, after: after, limit: limit)) { data, response, error in
      if let error = error {
        completion(nil, error)
        return
      }
      
      guard let response = response as? HTTPURLResponse else {
        completion(nil, NetworkResponse.invalidResponse)
        return
      }
      
      let result = self.handleNetworkResponse(response)
      
      switch result {
      case .failure(let error):
        completion(nil, error)
        
      case .success:
        guard let data = data else { completion(nil, NetworkResponse.noData); return }
        
        do {
          let result = try JSONDecoder().decode(ApiRespoinse.self, from: data)
          completion(result, nil)
        } catch {
          print(error)
          completion(nil, NetworkResponse.unableToDecode)
        }
      }
    }
  }
  
  func loadImage(from url: URL?, completion: @escaping (Data?, Error?) -> ()) {
    DispatchQueue.global(qos: .background).async {
      guard let url = url else { completion(nil, NetworkError.missingUrl); return }
      
      do {
        let data = try Data(contentsOf: url)
        completion(data, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
  
  fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<Error> {
    switch response.statusCode {
    case 200...299: return .success
    case 401...500: return .failure(NetworkResponse.authenticationError)
    case 501...599: return .failure(NetworkResponse.badRequest)
    case 600: return .failure(NetworkResponse.outdated)
    default: return .failure(NetworkResponse.failed)
    }
  }
}

enum NetworkResponse: String, LocalizedError {
  case success
  case authenticationError = "You need to be authenticated first."
  case badRequest = "Bad request"
  case outdated = "The url you requested is outdated."
  case failed = "Network request failed."
  case noData = "Response returned with no data to decode."
  case invalidResponse = "Response returned with unexpected data."
  case unableToDecode = "Unable to decode the response."
  case noInternetConnection = "Please check your network connection."
  
  var errorDescription: String? {
    self.rawValue
  }
}

enum Result<Error>{
  case success
  case failure(Error)
}

enum NetworkEnvironment {
  case development
  case staging
  case production
}
