//
//  CoreNetworkTests.swift
//  CoreNetworkTests
//
//  Created by Abid Hussain on 08/03/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Testing
@testable import CoreNetwork

/**
 Added .serialized trait to run test serially (by default they run in parallel) as they are writing/reading to a shared resources aka CacheManager
 */
@Suite(.serialized)
struct CacheManagerTests {
  let cacheManager: Caching
  
  init(cacheManager: Caching = CacheManager.shared) {
    self.cacheManager = cacheManager
  }

  @Test("Check Cache Persisted For Different Storage Types", arguments: [StorageType.cache, StorageType.file])
  func saveAndFetch(from type: StorageType) async {
    let data = getTestData()
    let urlRequest = getURLRequest("https://www.testurl.com")
    
    await cacheManager.save(data, for: urlRequest, type: type)
    let fetchedData = await cacheManager.fetch(for: urlRequest, type: type)
    
    #expect(fetchedData != nil)
    #expect(fetchedData == data)
  }

  @Test
  func fetchNonExistentKey() async {
    let urlRequest = getURLRequest("www.notsavedurl")
    let fetchedData = await cacheManager.fetch(for: urlRequest, type: .cache)
    #expect(fetchedData == nil)
  }
  
  @Test("Check Cache Cleared For Different Storage Types", arguments: [StorageType.cache, StorageType.file])
  func clearCache(for type: StorageType) async {
    let data = getTestData()
    let urlRequest = getURLRequest("https://www.testurl.com")
    
    await cacheManager.save(data, for: urlRequest, type: type)
    
    await cacheManager.clearAll()
    let fetchedData = await cacheManager.fetch(for: urlRequest, type: type)
    
    #expect(fetchedData == nil)
  }
}

private extension CacheManagerTests {
  func getURLRequest(_ url: String) -> URLRequest {
    let url = URL(string: url)!
    return URLRequest(url: url)
  }
  
  func getTestData() -> Data {
    return "TestData".data(using: .utf8)!
  }
}
