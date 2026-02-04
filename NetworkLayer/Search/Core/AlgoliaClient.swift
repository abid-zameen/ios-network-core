//
//  AlgoliaService.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 30/05/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Search
import Core

final class AlgoliaClient {
  
  private let searchClient: SearchClient
  private let tracing: PerformanceTracing?
  
  init(_ tracing: PerformanceTracing?) throws {
    guard let appID = AlgoliaConfig.applicationID,
          let apiKey = AlgoliaConfig.applicatioKey else {
      throw AlgoliaError.invalidCredentials("Please setup algolia with valid credentials")
    }
    
    self.searchClient = try SearchClient(
      appID: appID,
      apiKey: apiKey
    )
    self.tracing = tracing
  }
}

extension AlgoliaClient: SearchService {
  public func search<T: Codable>(
    query: SearchRequest,
    in indexName: String
  ) async throws -> SearchResult<T> {
    
    let traceSession = self.tracing?.start(name: indexName)
    
    let searchParamsObject = constructSearchParams(query)
    let response: SearchResponse<T> = try await searchClient.searchSingleIndex(indexName: indexName,
                                                    searchParams: .searchSearchParamsObject(searchParamsObject))

    defer { traceSession?.stop() }
    
    return SearchResult(response)
  }
  
  public func fetchObjects(
    byIDs ids: [String],
    in index: String
  ) async throws -> GetObjectsResponse<Hit> {
    
    let traceSession = self.tracing?.start(name: index)
    
    let params = GetObjectsParams(
      requests: ids.map {
        GetObjectsRequest(
          objectID: $0,
          indexName: index
        )
      }
    )
    
    defer { traceSession?.stop() }
    
    return try await searchClient.getObjects(getObjectsParams: params)
  }
}


private extension AlgoliaClient {
  func constructSearchParams(_ search: SearchRequest) -> SearchSearchParamsObject {
    return SearchSearchParamsObject(
      query: search.query,
      filters: search.filters,
      facets: search.facets,
      page: search.page,
      attributesToRetrieve: search.attributesToRetrieve,
      attributesToHighlight: search.attributesToHighlight,
      hitsPerPage: search.hitsPerPage
    )
  }
}
