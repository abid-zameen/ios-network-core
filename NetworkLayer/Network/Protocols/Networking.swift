//
//  NetworkClient.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 08/01/2025.
//  Copyright © 2025 bayut. All rights reserved.

public protocol CacheDelegate {
    func didReceiveCachedData<T: Decodable>(_ data: T?)
}

public protocol Networking {
  
  func setCacheDelegate(_ delegate: CacheDelegate)
  
  func execute<T: Decodable>(
    request: APIRequest,
    completion: @escaping (Result<T?, Error>) -> Void
  )
  
  func executeMultiPart<T: Decodable>(
    request: APIRequest,
    completion: @escaping (Result<T?, Error>) -> Void
  )
  
  func executeMultiPart<T: Decodable>(request: APIRequest) async throws -> T?
  func execute<T: Decodable>(request: APIRequest) async throws -> T?
}
