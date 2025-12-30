//
//  RequestInfo.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 08/01/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum ParametersEncoding {
    case url
    case json
}


/// Defines the caching policies for API requests.
/// - `none`: No caching is applied.
/// - `appSession`: Cache is checked first, then a network request is made if cache is not available. It's expiry is bound to app session.
/// - `userSession`: Cache is checked first, then a network request is made if cache is not available. It's expiry is bound to user session.
/// - `cacheThenNetwork`: It will return cache data first and then make a network request to return the latest data.
///                      It is useful for showing stale data while fetching the latest data from the server.
public enum CachePolicy {
  case none
  case appSession
  case userSession
  case cacheThenNetwork
}

public protocol APIRequest {
  var path: String { get set }
  var method: HTTPMethod { get set }
  var encoding: ParametersEncoding { get set }
  var headers: [String: String]? { get set }
  var parameters: [String: Any]? { get set }
  var cachePolicy: CachePolicy { get set }
  var shouldHandleCookies: Bool { get set }
}
