//
//  EndPointType.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

protocol EndPointType {
  var environmentBaseURL: String { get }
  var baseUrl: URL { get }
  var path: String { get }
  var httpMethod: HTTPMethod { get }
  var task: HTTPTask { get }
  var headers: HTTPHeaders? { get }
}
