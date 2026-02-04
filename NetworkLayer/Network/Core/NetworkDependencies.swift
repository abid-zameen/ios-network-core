//
//  NetworkDependencies.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 04/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Foundation

public protocol NetworkDependencies {
  var networkConfig: NetworkConfigrations? { get set }
  var analytics: AnalyticsTracking? { get set }
  var infoLogger: InfoLogging? { get set }
  var cookiesHandler: CookiesHandling? { get set}
}

public final class DependenciesBuilder {
  
  private var networkConfig: NetworkConfigrations?
  private var analytics: AnalyticsTracking?
  private var infoLogger: InfoLogging?
  private var cookiesHandler: CookiesHandling?
  
  public init() {}
  
  public func build() -> NetworkDependencies {
    return Dependencies(
      networkConfig: networkConfig,
      analytics: analytics,
      infoLogger: infoLogger,
      cookiesHandler: cookiesHandler
    )
  }
}

public extension DependenciesBuilder {
  func setNetworkConfig(_ config: NetworkConfigrations) -> Self {
    self.networkConfig = config
    return self
  }
    
  func setAnalytics(_ analytics: AnalyticsTracking) -> Self {
    self.analytics = analytics
    return self
  }
  
  func setInfoLogger(_ logger: InfoLogging) -> Self {
    self.infoLogger = logger
    return self
  }
  
  func setCookiesHandler(_ handler: CookiesHandling) -> Self {
    self.cookiesHandler = handler
    return self
  }
}

private struct Dependencies: NetworkDependencies {
  var networkConfig: NetworkConfigrations?
  var analytics: AnalyticsTracking?
  var infoLogger: InfoLogging?
  var cookiesHandler: CookiesHandling?
}
