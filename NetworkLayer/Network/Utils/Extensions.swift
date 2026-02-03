//
//  Extensions.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 11/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Alamofire
import Foundation

extension Data {
  func convertToReadable() -> Any? {
    do {
      let jsonObject = try JSONSerialization.jsonObject(with: self, options: [.allowFragments])
      if jsonObject is [String: Any] || jsonObject is [Any] {
        return jsonObject
      }
    } catch {
      if let jsonString = String(data: self, encoding: .utf8) {
        return jsonString
      }
      LogPrinter.debug("JSON Parsing Error: \(error)")
    }
    return nil
  }
}

extension MultipartFormData {
  func append(_ parameters: [String: Any]?) {
    guard let parameters = parameters, !parameters.isEmpty else {
      // TODO: - Move to Analytics Error Logger - NetworkError
      LogPrinter.debug("MultipartFormData: Parameters missing or empty")
      return
    }
    
    // Extract non-file parameters and sort them
    let nonFileParameters = parameters.filter { $0.key != "file" }.sorted { $0.key < $1.key }
    
    // Append non-file parameters first
    nonFileParameters.forEach { key, value in
      let multipartValue = createMultipartValue(from: value)
      multipartValue?.append(to: self, with: key)
    }
    
    // Append file parameter last (Required for S3)
    if let fileValue = parameters["file"] {
      let multipartValue = createMultipartValue(from: fileValue)
      multipartValue?.append(to: self, with: "file")
    }
  }
  
  func createMultipartValue(from value: Any) -> MultipartValue? {
    switch value {
      case let jsonDict as [String: Any]:
        return .json(jsonDict)
      case let data as Data:
        return .data(data)
      case let fileURL as URL:
        return .fileURL(fileURL)
      default:
        // TODO: - Move to Analytics Error Logger - NetworkError
        LogPrinter.debug("MultipartFormData: Unsupported value type")
        return nil
    }
  }
}
