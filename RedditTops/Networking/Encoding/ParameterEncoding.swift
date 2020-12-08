//
//  ParameterEncoding.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

struct Parameter {
  let key: String
  let value: Any
}

protocol ParameterEncoder {
  func encode(urlRequest: inout URLRequest, with parameters: [Parameter]) throws
}

enum ParameterEncoding {
  case urlEncoding
  case jsonEncoding
  case urlAndJsonEncoding
  
  func encode(urlRequest: inout URLRequest, bodyParameters: [Parameter]?, urlParameters: [Parameter]?) throws {
    do {
      switch self {
      case .urlEncoding:
        guard let urlParameters = urlParameters else { throw NetworkError.parametersNil }
        try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
        
      case .jsonEncoding:
        guard let bodyParameters = bodyParameters else { throw NetworkError.parametersNil }
        try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
        
      case .urlAndJsonEncoding:
        guard let bodyParameters = bodyParameters,
              let urlParameters = urlParameters else { throw NetworkError.parametersNil }
        try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
        try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
      }
    } catch {
      throw error
    }
  }
}
