//
//  SearchClient.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 30/05/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Search

public protocol SearchService {
  
  func search<T: Codable>(
    query: SearchRequest,
    in index: String
  ) async throws -> SearchResult<T>
  
  func fetchObjects(
    byIDs ids: [String],
    in index: String
  ) async throws -> GetObjectsResponse<Hit>
}
