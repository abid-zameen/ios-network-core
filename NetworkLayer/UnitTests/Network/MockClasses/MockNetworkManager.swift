//
//  MockNetworkManager.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 08/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

@testable import CoreNetwork

final class MockNetworkManager: Networking {
  
  var errorInfo: Error?
  var responseJson: String?
  var requestCount = 0
  
  func shouldFailRequest(_ error: ServiceError) {
    self.errorInfo = error
  }
  
  func shouldSucceedWithResponse(_ response: String?) {
    responseJson = response
  }
  
  func setCacheDelegate(_ delegate: any NetworkLayer.CacheDelegate) {
  }
  
  func execute<T>(request: APIRequest,
                  completion: @escaping (Result<T?, any Error>) -> Void) where T: Decodable {
    if let errorInfo {
      completion(.failure(errorInfo))
    } else {
      if let decodable: T = convert(responseJson) {
        completion(.success(decodable))
      } else {
        completion(.failure(ServiceError.decodingFailed))
      }
    }
  }
  
  func executeMultiPart<T>(request: any DBZNetwork.APIRequest,
                           completion: @escaping (Result<T?, any Error>) -> Void) where T : Decodable {
    if let errorInfo {
      completion(.failure(errorInfo))
    } else {
      if let decodable: T = convert(responseJson) {
        completion(.success(decodable))
      } else {
        completion(.failure(ServiceError.decodingFailed))
      }
    }
  }
  
  func execute<T>(request: APIRequest) async throws -> T? where T: Decodable {
    requestCount += 1
    guard let errorInfo else {
      if let responseJson: T = convert(responseJson) {
        return responseJson
      }
      throw ServiceError.decodingFailed
    }
    throw errorInfo
  }
  
  func executeMultiPart<T>(request: any DBZNetwork.APIRequest) async throws -> T? where T : Decodable {
    requestCount += 1
    guard let errorInfo else {
      if let responseJson: T = convert(responseJson) {
        return responseJson
      }
      throw ServiceError.decodingFailed
    }
    throw errorInfo
  }
  
  private func convert<T: Decodable>(_ response: String?) -> T? {
    guard let data = response?.data(using: .utf8) else {
      return nil
    }
    
    // Handle String type directly
    if T.self == String.self {
        return response as? T
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(T.self, from: data)
    } catch {
      return nil
    }
  }
}
