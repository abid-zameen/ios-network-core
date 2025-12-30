//
//  MockNetworkFactory.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 15/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Alamofire

@testable import CoreNetwork

final class MockSession: Session, @unchecked Sendable {
  
  var mockRequestHandler: ((URLRequest) async -> DataResponse<Decodable, AFError>)?
  
  func request(_ urlRequest: URLRequestConvertible) async -> MockDataRequest {
    let mockDataRequest = MockDataRequest()
    if let handler = mockRequestHandler,
       let urlRequest = urlRequest as? URLRequest {
      let response = await handler(urlRequest)
      mockDataRequest.response = response
    }
    return mockDataRequest
  }
}

final class MockDataRequest {
  
  var response: DataResponse<Decodable, AFError>?

  func serializingDecodable<T: Decodable>(of type: T.Type, queue: DispatchQueue? = .main, completionHandler: @escaping (DataResponse<T, AFError>) -> Void) -> Self {
    if let response = response as? DataResponse<T, AFError> {
      completionHandler(response)
    }
    return self
  }
}

struct MockNetworkConfigs: NetworkConfigrations {
  var httpScheme: String = "https"
  var baseURL: String = "test.abc.com"
}
