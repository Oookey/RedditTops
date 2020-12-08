//
//  RedditApi.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

enum RedditApi {
  case top(before: String?, after: String?, limit: Int)
}

extension RedditApi: EndPointType {
  var environmentBaseURL : String {
    switch NetworkManager.environment {
    default: return "https://reddit.com/"
    }
  }
  
  var baseUrl: URL {
    guard let url = URL(string: self.environmentBaseURL)
      else { fatalError("baseURL could not be configured.")}
    return url
  }
  
  var path: String {
    switch self {
    case .top:
      return "top.json"
    }
  }
  
  var httpMethod: HTTPMethod {
    return .get
  }
  
  var task: HTTPTask {
    switch self {
    case .top(let before, let after, let limit):
      var parameters: [Parameter] = []
      
      if let before = before {
        parameters.append(Parameter(key: "before", value: before))
      }
      
      if let after = after {
        parameters.append(Parameter(key: "after", value: after))
      }

      parameters.append(Parameter(key: "limit", value: limit))

      return .requestParameters(bodyParameters: nil,
                                bodyEncoding: .urlEncoding,
                                urlParameters: parameters)
    }
  }
  
  var headers: HTTPHeaders? {
    return nil
  }
}
