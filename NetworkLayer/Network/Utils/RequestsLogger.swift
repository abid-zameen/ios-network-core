//
//  RequestsLogger.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 19/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Alamofire
import Foundation

final class APIRequestsMonitor: EventMonitor {
  
  private let networkLogger: NetworkLogging?
  
  init(networkLogger: NetworkLogging? = NetworkLogger()) {
    self.networkLogger = networkLogger
  }
  
  func requestDidResume(_ request: Request) {
#if DEBUG
    logRequest(request)
#endif
  }
  
  func request<Value>(_ request: DataRequest, didParseResponse response: AFDataResponse<Value>) {
    saveCookies(request.request, response: response.response)
#if DEBUG
    logResponse(response, request)
#endif
  }
}

private extension APIRequestsMonitor {
  func saveCookies(_ request: URLRequest?, response: HTTPURLResponse?) {    
    DependencyContainer.shared.cookiesHandler?.saveCookies(response, request: request)
  }
}

private extension APIRequestsMonitor {
  
  // MARK: - Response Received
  func logResponse<Value>(_ response: AFDataResponse<Value>, _ request: DataRequest) {
    let statusCode = response.response?.statusCode ?? -1
    let url = request.request?.url?.absoluteString ?? "Unknown URL"
    let isSuccess = response.error == nil
    let responseData = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "No Data"
    
    let message = """
        ⚡️ ---- API Response Received ---- ⚡️
        🔗 URL: \(url)
        ✅ Status Code: \(statusCode) (\(isSuccess ? "Success" : "Failure"))
        📦 Response: \(responseData.prefix(1000))\(responseData.count > 1000 ? "..." : "")
        📝 Debug Description: \(response.debugDescription)
        -------------------------------------
        """
    LogPrinter.debug(message)
    
    if !isSuccess {
      networkLogger?.logAPIFailure(errorStatusCode: statusCode,
                                   url: url,
                                   responseData: responseData,
                                   errorDescription: response.error?.localizedDescription ?? "")
    }
  }
  
  // MARK: - Request Started
  func logRequest(_ request: Request) {
    let httpMethod = request.request?.httpMethod ?? "Unknown"
    let url = request.request?.url?.absoluteString ?? "Unknown URL"
    let headers = request.request?.allHTTPHeaderFields ?? [:]
    let body = request.request?.httpBody
      .flatMap { String(data: $0, encoding: .utf8) } ?? "None"
    
    let message = """
        ⚡️ ---- API Request Started ---- ⚡️
        🔗 URL: \(url)
        🛑 Method: \(httpMethod)
        📄 Headers: \(headers)
        📥 Body: \(body.prefix(500))\(body.count > 500 ? "..." : "")
        🖥 CURL: \(request.cURLDescription())
        ------------------------------------
        """
    LogPrinter.debug(message)
  }
}
