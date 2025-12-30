//
//  AuthInterceptor.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 23/01/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Alamofire
import Foundation

final class AuthInterceptor: RequestInterceptor {
  
  private enum Constants {
    static let jwtTokenHeaderKey = "x-access-token"
  }
  
  private let maxRetryCount = 1
  private let tokenManager: AuthenticationProvider?
  
  init(tokenManager: AuthenticationProvider? = DependencyContainer.shared.authProvider) {
    self.tokenManager = tokenManager
  }
  
  func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    Task {
      var adaptedRequest = urlRequest
      
      LogPrinter.debug("*** Requesting JWT token for \(urlRequest.url?.absoluteString ?? "")")
      // Preemptively fetch a valid token
      guard let token = await tokenManager?.getAccessToken() else {
        completion(.failure(ServiceError.invalidToken))
        return
      }
      
      LogPrinter.debug("*** Inserting JWT token for \(urlRequest.url?.absoluteString ?? "")")
      adaptedRequest.setValue(token, forHTTPHeaderField: Constants.jwtTokenHeaderKey)
      completion(.success(adaptedRequest))
    }
  }
  
  func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
      completion(.doNotRetry)
      return
    }
    
    let retryCount = request.retryCount
    guard retryCount < maxRetryCount else {
      completion(.doNotRetry)
      return
    }
    
    Task {
      if await tokenManager?.getAccessToken() != nil {
        LogPrinter.debug("*** Performing retry \(retryCount)")
        completion(.retry)
      } else {
        completion(.doNotRetry)
      }
    }
  }
}
