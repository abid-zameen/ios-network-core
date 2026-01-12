//
//  NetworkError.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 08/01/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Foundation
import Alamofire

public enum ServiceError: Error {
  case invalidURL
  case noInternet
  case invalidToken
  case invalidRequest
  case encodingFailed
  case decodingFailed(_ error: Error)
  case timeout(_ response: Response?)
  case connectionLost(_ response: Response?)
  case accessExpired(_ response: Response?)
  case refreshExpired(_ response: Response?)
  case unauthorized(_ response: Response?)
  case forbidden(_ response: Response?)
  case notFound(_ response: Response?)
  case serverError(_ response: Response?)
  case unhandled(_ response: Response?)
}

extension ServiceError {
  
  public struct Response {
    public var statusCode: Int?
    public var body: Any?
    
    init(statusCode: Int? = nil,
         body: Any? = nil) {
      self.statusCode = statusCode
      self.body = body
    }
  }
  
  static func mapError(_ error: AFError, response: Any?) -> ServiceError {
    
    var errorResponse = Response(statusCode: error.responseCode, body: response)
    
    if let adaptationError = error.underlyingError as? ServiceError {
      return adaptationError
    }
    
    if let urlError = error.underlyingError as? URLError {
      errorResponse.statusCode = urlError.errorCode
      switch urlError.code {
      case .notConnectedToInternet:
        return .noInternet
      case .networkConnectionLost:
        return .connectionLost(errorResponse)
      case .timedOut:
        return .timeout(errorResponse)
      default:
        break
      }
    }
    
    if let statusCode = error.responseCode {
      switch statusCode {
      case 401: return .accessExpired(errorResponse)
      case 403: return .refreshExpired(errorResponse)
      case 404: return .notFound(errorResponse)
      case 500...599: return .serverError(errorResponse)
      default: return .unhandled(errorResponse)
      }
    }
    
    return .unhandled(errorResponse)
  }
}

public extension ServiceError {
  var response: Response? {
    switch self {
    case .timeout(let response),
        .connectionLost(let response),
        .accessExpired(let response),
        .refreshExpired(let response),
        .unauthorized(let response),
        .forbidden(let response),
        .notFound(let response),
        .serverError(let response),
        .unhandled(let response):
      return response
    default:
      return nil
    }
  }
  
  var statusCode: Int? {
    response?.statusCode
  }
}
