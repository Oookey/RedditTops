//
//  URLParameterEncoder.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

struct URLParameterEncoder: ParameterEncoder {
  func encode(urlRequest: inout URLRequest, with parameters: [Parameter]) throws {
    guard let url = urlRequest.url else { throw NetworkError.missingUrl }
    
    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
      urlComponents.queryItems = [URLQueryItem]()
      
      parameters.forEach {
        let value = "\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let queryItem = URLQueryItem(name: $0.key, value: value)
        urlComponents.queryItems?.append(queryItem)
      }
      urlRequest.url = urlComponents.url
    }
    
    if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
      urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }
  }
}
