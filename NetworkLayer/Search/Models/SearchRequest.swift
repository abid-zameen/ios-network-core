//
//  SearchRequest.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 30/05/2025.
//  Copyright © 2025 bayut. All rights reserved.

public struct SearchRequest {
  public var page: Int
  public var query: String?
  public var filters: String?
  public var hitsPerPage: Int
  public var facets: [String]?
  public var keywords: [String]?
  public var geoFilter: GeoFilter?
  public var numericFilters: String?
  public var attributesToRetrieve: [String]?
  public var attributesToHighlight: [String]?
  
  public init(query: String? = nil,
              filters: String? = nil,
              page: Int = 0,
              hitsPerPage: Int = 30,
              facets: [String]? = nil,
              keywords: [String]? = nil,
              numericFilters: String? = nil,
              attributesToRetrieve: [String]? = nil,
              attributesToHighlight: [String]? = nil,
              geoFilter: GeoFilter? = nil
  ) {
    self.query = query
    self.keywords = keywords
    self.filters = filters
    self.numericFilters = numericFilters
    self.page = page
    self.hitsPerPage = hitsPerPage
    self.facets = facets
    self.attributesToRetrieve = attributesToRetrieve
    self.attributesToHighlight = attributesToHighlight
    self.geoFilter = geoFilter
  }
}

public struct GeoFilter {
  public let latitude: Double
  public let longitude: Double
  public let radius: Int
}
