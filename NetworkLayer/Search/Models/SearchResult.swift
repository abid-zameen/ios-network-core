//
//  SearchResponse.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 05/06/2025.
//  Copyright © 2025 bayut. All rights reserved.

import AlgoliaSearchClient

public struct SearchResult<T: Codable> {
  public var page: Int?
  public var nbHits: Int?
  public var nbPages: Int?
  public var hits: [T]?
  
  public init(_ response: SearchResponse<T>) {
    self.page = response.page
    self.nbHits = response.nbHits
    self.nbPages = response.nbPages
    self.hits = response.hits
  }  
}
