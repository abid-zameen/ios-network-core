//
//  CacheManager.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 22/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Foundation

enum StorageType {
  case cache
  case file
}

protocol Caching: Sendable {
  func save(_ data: Data, for request: URLRequest, type: StorageType) async
  func fetch(for request: URLRequest, type: StorageType) async -> Data?
  func remove(for urlPath: String) async
  func clearAll() async
}

actor CacheManager {
  static let shared = CacheManager()

  private let diskCacheURL: URL?
  private let fileManager = FileManager.default
  private let defaultExpiry: TimeInterval = 3600 * 24 * 7 // 1 week
  private let memoryCache = NSCache<NSString, CacheEntry>()
  private var memoryCacheKeys = Set<String>()

  private init() {
    let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    diskCacheURL = cacheDir?.appendingPathComponent("BYTNetworkCache")

    if let diskCacheURL, !fileManager.fileExists(atPath: diskCacheURL.path) {
      do {
        try fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
      } catch {
        LogPrinter.debug("⚠️ Failed to create cache directory: \(error)")
      }
    }
  }
}

extension CacheManager: Caching {

  func save(_ data: Data, for request: URLRequest, type: StorageType) async {
    let key = cacheKey(for: request)
    let entry = CacheEntry(data: data, expiryDate: Date().addingTimeInterval(defaultExpiry))

    memoryCache.setObject(entry, forKey: key as NSString)
    memoryCacheKeys.insert(key)

    guard type == .file else { return }

    Task {
      await saveToDisk(entry, forKey: key)
    }
  }

  func fetch(for request: URLRequest, type: StorageType) async -> Data? {
    let key = cacheKey(for: request)

    if let entry = memoryCache.object(forKey: key as NSString), !entry.isExpired {
      return entry.data
    }

    guard type == .file else { return nil }

    if let entry = await fetchFromDisk(forKey: key), !entry.isExpired {
      memoryCache.setObject(entry, forKey: key as NSString)
      memoryCacheKeys.insert(key)
      return entry.data
    }

    return nil
  }

  func clearAll() async {
    memoryCache.removeAllObjects()
    memoryCacheKeys.removeAll()
    clearCacheFolder()
  }
  
  func remove(for urlPath: String) async {
    for key in memoryCacheKeys where key.contains(urlPath) {
      memoryCache.removeObject(forKey: key as NSString)
      memoryCacheKeys.remove(key)
    }

    guard let diskCacheURL else { return }

    let safeURLPath = sanitizeURLPath(urlPath)
    
    do {
      let fileURLs = try fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: nil)
      for url in fileURLs {
        if url.lastPathComponent.contains(safeURLPath) {
          try? fileManager.removeItem(at: url)
        }
      }
    } catch {
      LogPrinter.debug("⚠️ Failed to clean files for key substring \(urlPath): \(error.localizedDescription)")
    }
  }
}

// MARK: - Disk Storage Helpers
private extension CacheManager {

  func clearCacheFolder() {
    guard let diskCacheURL else {
      return
    }
    
    try? fileManager
      .contentsOfDirectory(
        at: diskCacheURL,
        includingPropertiesForKeys: nil,
        options: []
      ).forEach { url in
        try? FileManager.default.removeItem(at: url)
      }
  }
  
  func saveToDisk(_ entry: CacheEntry, forKey key: String) async {
    guard let url = safeCacheFileURL(for: key),
          let data = try? JSONEncoder().encode(entry) else { return }

    do {
      try data.write(to: url, options: .atomic)
    } catch {
      LogPrinter.debug("⚠️ Failed to write cache to disk: \(error.localizedDescription)")
    }
  }

  func fetchFromDisk(forKey key: String) async -> CacheEntry? {
    guard let url = safeCacheFileURL(for: key) else { return nil }

    do {
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode(CacheEntry.self, from: data)
    } catch {
      LogPrinter.debug("⚠️ Failed to read cache: \(error.localizedDescription)")
      return nil
    }
  }

  func safeCacheFileURL(for key: String) -> URL? {
    guard let diskCacheURL else { return nil }
    let safeKey = key.replacingOccurrences(of: "/", with: "_")
    return diskCacheURL.appendingPathComponent(safeKey)
  }
  
  func sanitizeURLPath(_ urlPath: String) -> String {
    return urlPath.replacingOccurrences(of: "/", with: "_")
  }
}

// MARK: - Memory Cleanup
private extension CacheManager {
  func cleanExpiredMemoryEntries() {
    for key in memoryCacheKeys {
      if let entry = memoryCache.object(forKey: key as NSString), entry.isExpired {
        memoryCache.removeObject(forKey: key as NSString)
        memoryCacheKeys.remove(key)
      }
    }
  }
}

// MARK: - Cache Key Generation
private extension CacheManager {
  func cacheKey(for request: URLRequest) -> String {
    guard let url = request.url?.absoluteString else { return "" }

    var key = "\(request.httpMethod ?? "GET")_\(url)"
    if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
      key += "_\(bodyString.hashValue)"
    }

    return key
  }
}

// MARK: - Cache Entry Wrapper
private final class CacheEntry: NSObject, Codable {
  let data: Data
  let expiryDate: Date

  init(data: Data, expiryDate: Date) {
    self.data = data
    self.expiryDate = expiryDate
  }

  var isExpired: Bool {
    return Date() > expiryDate
  }
}
