//
//  Router.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import Foundation

typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?)->()

protocol INetworkRouter {
  associatedtype EndPoint: EndPointType
  func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
  func cancel()
}

class NetworkRouter<EndPoint: EndPointType>: INetworkRouter {
  private var task: URLSessionTask?
  
  func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
    let session = URLSession.shared
    do {
      let request = try self.buildRequest(from: route)
      self.task = session.dataTask(with: request) { data, response, error in
        completion(data, response, error)
      }
      self.task?.resume()
    } catch {
      completion(nil, nil, error)
    }
  }
  
  func cancel() {
    self.task?.cancel()
  }
}

extension NetworkRouter {
  func buildRequest(from route: EndPoint) throws -> URLRequest {
    var request = URLRequest(url: route.baseUrl.appendingPathComponent(route.path),
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 10)
    
    request.httpMethod = route.httpMethod.rawValue
    
    do {
      switch route.task {
      case .request:
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      case .requestParameters(let bodyParameters,
                              let bodyEncoding,
                              let urlParameters):
        
        try self.configureParameters(bodyParameters: bodyParameters,
                                bodyEncoding: bodyEncoding,
                                urlParameters: urlParameters,
                                request: &request)
        
      case .requestParametersAndHeaders(let bodyParameters,
                                        let bodyEncoding,
                                        let urlParameters,
                                        let additionalHeaders):
        
        self.addAdditionalHeaders(additionalHeaders, &request)
        try self.configureParameters(bodyParameters: bodyParameters,
                                bodyEncoding: bodyEncoding,
                                urlParameters: urlParameters,
                                request: &request)
      }
      return request
    } catch {
      throw error
    }
  }
}

extension NetworkRouter {
  func configureParameters(bodyParameters: [Parameter]?,
                                       bodyEncoding: ParameterEncoding,
                                       urlParameters: [Parameter]?,
                                       request: inout URLRequest) throws {
    do {
      try bodyEncoding.encode(urlRequest: &request,
                              bodyParameters: bodyParameters, urlParameters: urlParameters)
    } catch {
      throw error
    }
  }
}

extension NetworkRouter {
  func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, _ request: inout URLRequest) {
    guard let headers = additionalHeaders else { return }
    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }
  }
}
