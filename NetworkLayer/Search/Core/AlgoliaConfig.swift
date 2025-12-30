//
//  AlgoliaService.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 02/06/2025.
//  Copyright © 2025 bayut. All rights reserved.

public struct AlgoliaConfig {
  private(set) static var applicationID: String?
  private(set) static var applicatioKey: String?
  
  public static func setup(
    appID: String,
    apiKey: String,
    performanceTracer: PerformanceTracing? = nil
  ) {
    applicationID = appID
    applicatioKey = apiKey
    AlgoliaDependencyManger.shared.setPerformanceTracing(performanceTracer)
  }
}

public protocol PerformanceTracing {
  func start(
    name: String,
    attributes: [String: String]?
  ) -> TraceSession
}

public extension PerformanceTracing {
  func start(name: String) -> TraceSession {
    return start(name: name, attributes: nil)
  }
}

public protocol TraceSession {
  func stop()
}

final class AlgoliaDependencyManger {
  static let shared = AlgoliaDependencyManger()
  
  var performanceTracer: PerformanceTracing?
  
  func setPerformanceTracing(_ tracing: PerformanceTracing?) {
    self.performanceTracer = tracing
  }
}
