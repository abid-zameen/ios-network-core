//
//  APIRequestBuilder.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 04/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

public struct APIRequestBuilder {
  
  private struct APIRequestInfo: APIRequest {
    var path: String
    var method: HTTPMethod
    var encoding: ParametersEncoding
    var parameters: [String: Any]?
    var headers: [String: String]?
    var cachePolicy: CachePolicy
    var shouldHandleCookies: Bool
    var fullURL: String?
  }
  
  public static func create(path: String,
                            type: HTTPMethod,
                            encoding: ParametersEncoding = .json,
                            params: [String: Any]? = nil,
                            headers: [String: String]? = nil,
                            cache: CachePolicy = .none,
                            shouldHandleCookies: Bool = false,
                            fullURL: String? = nil) -> APIRequest {
    
    return APIRequestInfo(path: path,
                          method: type,
                          encoding: encoding,
                          parameters: params,
                          headers: headers,
                          cachePolicy: cache,
                          shouldHandleCookies: shouldHandleCookies,
                          fullURL: fullURL)
  }
}
