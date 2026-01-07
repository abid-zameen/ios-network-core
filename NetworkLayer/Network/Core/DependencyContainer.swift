//
//  DependencyContainer.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 02/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

/// DependencyContainer is a class that holds the dependencies for the network module.
final class DependencyContainer: NetworkDependencies {
  var analytics: AnalyticsTracking?
  var networkConfig: NetworkConfigrations?
  var infoLogger: InfoLogging?
  var cookiesHandler: CookiesHandling?
  
  public static let shared = DependencyContainer()
  
  private init() {}
  
  /// Setup the dependencies for the network module.
  /// This method should be called before using any network related classes.
  public func setup(networkConfig: NetworkConfigrations?,
                    analytics: AnalyticsTracking?,
                    cookiesHandler: CookiesHandling?,
                    infoLogger: InfoLogging?) {
    self.analytics = analytics
    self.infoLogger = infoLogger
    self.networkConfig = networkConfig
    self.cookiesHandler = cookiesHandler
  }
}
