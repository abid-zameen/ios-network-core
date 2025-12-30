//
//  NetworkCore.swift
//  Alamofire
//
//  Created by Abid Hussain on 03/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Foundation

public protocol NetworkConfigrations {
  var baseURL: String { get }
}

public extension NetworkConfigrations {
  var httpScheme: String {
    "https"
  }
}

public protocol AnalyticsTracking {
  func logEvent(_ name: String, parameters: [String: Any]?)
}

public protocol AuthenticationProvider: Sendable {
  func getAccessToken() async -> String?
  func getImpervaToken(url: URL?) async -> String
}

public protocol CookiesHandling {
  func saveCookies(_ urlResponse: HTTPURLResponse?,
                   request: URLRequest?)
}

public protocol InfoLogging {
  func log(eventName: String, error: Error?, attributes: [String: Any]?)
}


public final class NetworkCore {
  public static func setup(_ dependencies: NetworkDependencies) {
    DependencyContainer.shared.setup(networkConfig: dependencies.networkConfig,
                                     authProvider: dependencies.authProvider,
                                     analytics: dependencies.analytics,
                                     cookiesHandler: dependencies.cookiesHandler,
                                     infoLogger: dependencies.infoLogger)
  }
}

public struct NetworkCacheHelper {
  
  /// Clear all cache.
  public static func clearCache() {
    Task {
      await CacheManager.shared.clearAll()
    }
  }
  
  /// Remove cache for the urls containing the key path mentioned in the parameter.
  /// - Parameter key: The key path to be removed from the cache.
  public static func removeCache(for urlPath: String) {
    Task {
      await CacheManager.shared.remove(for: urlPath)
    }
  }
}
