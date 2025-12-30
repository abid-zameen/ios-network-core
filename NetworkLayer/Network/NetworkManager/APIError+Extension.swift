//
//  ServiceError+Extension.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 15/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

extension ServiceError: Equatable {
  public static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
    switch (lhs, rhs) {
    case (.invalidURL, .invalidURL):
      return true
    case (.noInternet, .noInternet):
      return true
    case (.invalidToken, .invalidToken):
      return true
    case (.invalidRequest, .invalidRequest):
      return true
    case (.decodingFailed, .decodingFailed):
      return true
    case (.timeout, .timeout):
      return true
    case (.connectionLost, .connectionLost):
      return true
    case (.accessExpired, .accessExpired):
      return true
    case (.refreshExpired, .refreshExpired):
      return true
    case (.unauthorized, .unauthorized):
      return true
    case (.forbidden, .forbidden):
      return true
    case (.notFound, .notFound):
      return true
    case (.serverError, .serverError):
      return true
    case (.unhandled, .unhandled):
      return true
    default:
      return false
      
    }
  }
}
