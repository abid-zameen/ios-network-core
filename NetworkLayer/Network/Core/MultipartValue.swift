//
//  MultipartValue.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 27/05/2025.
//

import Foundation
import Alamofire

enum MultipartValue {
  case data(Data)
  case fileURL(URL)
  case json([String: Any])
  case string(String)
}

extension MultipartValue {
  func append(to multipartFormData: MultipartFormData, with key: String) {
    switch self {
    case .fileURL(let url):
      multipartFormData.append(url, withName: key)
    case .data(let data):
      multipartFormData.append(data, withName: key)
    case .string(let string):
      if let data = string.data(using: .utf8) {
        multipartFormData.append(data, withName: key)
      }
    case .json(let jsonDict):
      if let data = jsonDict["data"] as? Data {
        let fileName = jsonDict["fileName"] as? String
        let mimeType = jsonDict["mimeType"] as? String
        multipartFormData.append(data, withName: key, fileName: fileName, mimeType: mimeType)
      }
    }
  }
}
