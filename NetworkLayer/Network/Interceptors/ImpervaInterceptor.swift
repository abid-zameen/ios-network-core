//
//  ImpervaInterceptor.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 02/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Alamofire
import Foundation

final class ImpervaInterceptor: RequestInterceptor {
  
  private enum Constants {
    static let impervaTokenHeaderKey = "X-D-Token"
  }
  
  func adapt(_ urlRequest: URLRequest,
             for session: Session,
             completion: @escaping (Result<URLRequest, any Error>) -> Void) {
    Task {
      let token = await  DependencyContainer.shared.authProvider?.getImpervaToken(url: urlRequest.url)
      var adaptedRequest = urlRequest
      LogPrinter.debug("*** Imperva token inserted \(String(describing: token))")
      adaptedRequest.setValue(token, forHTTPHeaderField: Constants.impervaTokenHeaderKey)
      completion(.success(adaptedRequest))
    }
  }
}
