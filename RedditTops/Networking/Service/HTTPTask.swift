//
//  HTTPTask.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

public typealias HTTPHeaders = [String: String]

enum HTTPTask {
  case request
  
  case requestParameters(bodyParameters: [Parameter]?,
                         bodyEncoding: ParameterEncoding,
                         urlParameters: [Parameter]?)
  
  case requestParametersAndHeaders(bodyParameters: [Parameter]?,
                                   bodyEncoding: ParameterEncoding,
                                   urlParameters: [Parameter]?,
                                   additionalHeaders: HTTPHeaders?)
}
