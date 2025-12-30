//
//  SearchClientFactory.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 30/06/2025.
//  Copyright © 2025 bayut. All rights reserved.

public struct SearchClientFactory {
  
  public static func createSearchService() -> SearchService? {
    let tracer = AlgoliaDependencyManger.shared.performanceTracer
    return try? AlgoliaClient(tracer)
  }
}
