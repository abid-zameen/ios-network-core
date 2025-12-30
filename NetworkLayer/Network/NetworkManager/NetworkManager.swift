//
//  NetworkService.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 08/01/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Foundation
import Alamofire

final class NetworkManager {
  
  let session: Session
    
  let cacheManager: CacheManager
  private let configs: NetworkConfigrations?

  var cacheDelegate: CacheDelegate?
  
  init(_ session: Session,
       configs: NetworkConfigrations?,
       cacheManager: CacheManager = CacheManager.shared) {
    self.session = session
    self.configs = configs
    self.cacheManager = cacheManager
  }
}

extension NetworkManager: Networking {
  
  public func executeMultiPart<T: Decodable>(request: any APIRequest) async throws -> T? {
    
    guard let url = buildURL(for: request) else {
      throw ServiceError.invalidRequest
    }
    
    // Cache Policy does not imply to Multi-Part Query
    
    let response = await session
      .upload(multipartFormData: { $0.append(request.parameters) },
              to: url,
              method: .post,
              headers: HTTPHeaders(request.headers ?? [:]))
      .validate()
      .serializingData()
      .response
    
    switch response.result {
    case .success(let data):
        
      return try? JSONDecoder().decode(T.self, from: data)
    case .failure(let afError):
      throw ServiceError.mapError(afError, response: response.data)
    }
  }
  
  public func execute<T: Decodable>(request: APIRequest) async throws -> T? {
    
    guard let urlRequest = buildURLRequest(request) else {
      throw ServiceError.invalidRequest
    }
    
    if request.cachePolicy != .none {
      if let cacheData: T? = await getCacheData(urlRequest, cache: request.cachePolicy) {
        // For session based cache policies return data from the cache if available and skip the network call.
        if request.cachePolicy == .appSession || request.cachePolicy == .userSession {
          return cacheData
        }
        cacheDelegate?.didReceiveCachedData(cacheData)
      }
    }
               
    let response = await session.request(urlRequest)
      .validate()
      .serializingData()
      .response
        
    switch response.result {
    case .success(let data):
      
      if request.cachePolicy != .none {
        await cache(data: data,
                    with: urlRequest,
                    for: request.cachePolicy)
      }
      
      return try? JSONDecoder().decode(T.self, from: data)
    case .failure(let afError):
      throw ServiceError.mapError(afError, response: response.data)
    }
  }
  
  func setCacheDelegate(_ delegate: CacheDelegate) {
    self.cacheDelegate = delegate
  }
}

extension NetworkManager {
  
  func buildURL(for endpoint: APIRequest) -> URL? {
    var components = URLComponents()
    components.scheme = configs?.httpScheme
    components.host = configs?.baseURL
    components.path = endpoint.path
    return components.url
  }
  
  func buildURLRequest(_ request: APIRequest) -> URLRequest? {
    guard let url = buildURL(for: request) else {
      return nil
    }
    
    var urlRequst = URLRequest(url: url)
    urlRequst.httpMethod = request.method.rawValue
    urlRequst.allHTTPHeaderFields = request.headers
    urlRequst.httpShouldHandleCookies = request.shouldHandleCookies
    
    do {
      switch request.encoding {
      case .url:
        urlRequst = try URLEncoding.default.encode(urlRequst, with: request.parameters)
      case .json:
        urlRequst = try JSONEncoding.default.encode(urlRequst, with: request.parameters)
      }
    } catch {
      return nil
    }
    return urlRequst
  }
}

extension NetworkManager {
  func cache(data: Data, with request: URLRequest, for policy: CachePolicy) async {
    let type: StorageType = policy == .appSession ? .cache : .file
    await cacheManager.save(data, for: request, type: type)
  }
  
  func getCacheData<T: Decodable>(_ request: URLRequest, cache: CachePolicy) async -> T? {
    let type: StorageType = cache == .appSession ? .cache : .file
    if let cacheData = await cacheManager.fetch(for: request, type: type) {
      return try? JSONDecoder().decode(T.self, from: cacheData)
    }
    return nil
  }
}
