//
//  JSONParameterEncoder.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

struct JSONParameterEncoder: ParameterEncoder {
  func encode(urlRequest: inout URLRequest, with parameters: [Parameter]) throws {
    do {
      let parameters = parameters.map { [$0.key: $0.value] }
      let jsonAsData = try JSONSerialization.data(withJSONObject: parameters,
                                                  options: .prettyPrinted)
      urlRequest.httpBody = jsonAsData
      
      if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      }
    } catch {
      throw NetworkError.encodingFailed
    }
  }
}
