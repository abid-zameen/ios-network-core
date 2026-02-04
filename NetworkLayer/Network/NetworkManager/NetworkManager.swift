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
  
  public func execute<T: Decodable>(request: APIRequest) async throws -> T {
    
    guard let urlRequest = buildURLRequest(request) else {
      throw ServiceError.invalidRequest
    }
    
    if request.cachePolicy != .none {
      if let cacheData: T = await getCacheData(urlRequest, cache: request.cachePolicy) {
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
    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        throw ServiceError.decodingFailed(error)
    }
    case .failure(let afError):
      throw ServiceError.mapError(afError, response: response.data)
    }
  }
  
  func setCacheDelegate(_ delegate: CacheDelegate) {
    self.cacheDelegate = delegate
  }
  
  // MARK: - Multipart Raw Response Methods
  public func executeMultiPartRaw(
    request: APIRequest,
    progress: @escaping (Double) -> Void
  ) async throws -> Data {
    
    guard let url = getURL(for: request) else {
      throw ServiceError.invalidRequest
    }
    
    do {
      let data = try await session
        .upload(multipartFormData: { $0.append(request.parameters) },
                to: url,
                method: .post,
                headers: HTTPHeaders(request.headers ?? [:]))
        .uploadProgress { uploadProgress in
          DispatchQueue.main.async {
            progress(uploadProgress.fractionCompleted)
          }
        }
        .validate()
        .serializingData()
        .value
      
      return data
    } catch let afError as AFError {
      throw ServiceError.mapError(afError, response: nil)
    } catch {
      throw error
    }
  }
  
  public func executeMultiPartRaw(
    request: APIRequest,
    progress: @escaping (Double) -> Void,
    completion: @escaping (Result<Data, Error>) -> Void
  ) {
    
    guard let url = getURL(for: request) else {
      completion(.failure(ServiceError.invalidRequest))
      return
    }
    
    session
      .upload(multipartFormData: { $0.append(request.parameters) },
              to: url,
              method: .post,
              headers: HTTPHeaders(request.headers ?? [:]))
      .uploadProgress { uploadProgress in
        DispatchQueue.main.async {
          progress(uploadProgress.fractionCompleted)
        }
      }
      .validate()
      .responseData { response in
        switch response.result {
        case .success(let data):
          completion(.success(data))
        case .failure(let afError):
          let responseData = response.data?.convertToReadable()
          completion(.failure(ServiceError.mapError(afError, response: responseData)))
        }
      }
  }
}


extension NetworkManager {
  
  func buildURL(for endpoint: APIRequest) -> URL? {
    // If full URL is provided, use it directly
    if let fullURL = endpoint.fullURL {
      return URL(string: fullURL)
    }
    
    // Otherwise, build from components as before
    var components = URLComponents()
    components.scheme = configs?.httpScheme
    components.path = endpoint.path
    if var host = configs?.baseURL {
        if host.lowercased().hasPrefix("https://") {
            host = String(host.dropFirst(8))
        } else if host.lowercased().hasPrefix("http://") {
            host = String(host.dropFirst(7))
        }
        if host.hasSuffix("/") {
            host = String(host.dropLast())
        }
        components.host = host
    }
    return components.url
  }
  
  private func getURL(for request: APIRequest) -> URL? {
    if let fullURL = request.fullURL {
      return URL(string: fullURL)
    }
    return buildURL(for: request)
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
