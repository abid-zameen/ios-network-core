//
//  NetworkService+Concurrency.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 08/01/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Foundation
import Alamofire

extension NetworkManager {
  
  public func executeMultiPart<T: Decodable>(
    request: APIRequest,
    completion: @escaping (Result<T?, Error>) -> Void
  ) {
    
    guard let url = buildURL(for: request) else {
      completion(.failure(ServiceError.invalidURL))
      return
    }
    
    // Cache Policy does not imply to Multi-Part Query
    session
      .upload(multipartFormData: { $0.append(request.parameters) },
              to: url,
              method: .post,
              headers: HTTPHeaders(request.headers ?? [:]))
      .validate()
      .responseData { response in
        switch response.result {
        case .success(let data):
          let responseData = try? JSONDecoder().decode(T.self, from: data)
          completion(.success(responseData))
        case .failure(let afError):
          let response = response.data?.convertToReadable()
          let error = ServiceError.mapError(afError, response: response)
          completion(.failure(error))
        }
      }
  }
  
  public func execute<T: Decodable>(
    request: APIRequest,
    completion: @escaping (Result<T?, Error>) -> Void
  ) {
    
    guard let urlRequest = buildURLRequest(request) else {
      completion(.failure(ServiceError.invalidRequest))
      return
    }
    
    if request.cachePolicy != .none {
      getCacheData(urlRequest, cache: request.cachePolicy) {[weak self] (data: T?) in
        if let data, request.cachePolicy == .appSession || request.cachePolicy == .userSession {
          completion(.success(data))
          return
        }
        self?.cacheDelegate?.didReceiveCachedData(data)
      }
    }
    
    self.session.request(urlRequest)
      .validate()
      .responseData() { [weak self] response in
        switch response.result {
        case .success(let data):
          if request.cachePolicy != .none {
            self?.cache(data: data, with: urlRequest, for: request.cachePolicy)
          }
          
          let responseData = try? JSONDecoder().decode(T.self, from: data)
          completion(.success(responseData))
        case .failure(let afError):
          let response = response.data?.convertToReadable()
          let error = ServiceError.mapError(afError, response: response)
          completion(.failure(error))
        }
      }
  }
}

private extension NetworkManager {
  func cache(data: Data, with request: URLRequest, for policy: CachePolicy) {
    let type: StorageType = policy == .appSession ? .cache : .file
    Task {
      await cacheManager.save(data, for: request, type: type)
    }
  }
  
  func getCacheData<T: Decodable>(_ request: URLRequest,
                                  cache: CachePolicy,
                                  completion: @escaping (_ data: T?) -> Void) {
    let type: StorageType = cache == .appSession ? .cache : .file
    Task {
      var responseData: T?
      if let cacheData = await cacheManager.fetch(for: request, type: type) {
        responseData = try? JSONDecoder().decode(T.self, from: cacheData)
      }
      completion(responseData)
    }
  }
}
