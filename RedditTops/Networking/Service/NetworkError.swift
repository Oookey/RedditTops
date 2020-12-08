//
//  NetworkErrpr.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

enum NetworkError: String, Error {
  case parametersNil = "Parameters were nil."
  case encodingFailed = "Parameters encoding failed."
  case missingUrl = "URL is nil."
}
