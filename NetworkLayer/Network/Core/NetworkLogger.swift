//
//  NetworkLogger.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 06/05/2025.
//

import Foundation

protocol NetworkLogging {
  func logAPIFailure(errorStatusCode: Int, url: String, responseData: String, errorDescription: String)
}

struct NetworkLogger: NetworkLogging {
  
  private enum Constants {
    static let failedAPIPath: String = "api_path"
    static let failedAPIErrorCode: String = "error_code"
    static let failedAPIErrorDomain: String = "api_failed"
    static let newNetworkLayer: String = "is_new_network_layer"
    static let eventName: String = "API FAILED"
    static let impervaIncidentIDKey: String = "imperva_incident_id"
    static let impervaIncidentIDRegexPattern = #"Incapsula incident ID:\s*(\d+-\d+)"#
  }
  
  private let infoLogger: InfoLogging?
  
  init(infoLogger: InfoLogging? = DependencyContainer.shared.infoLogger) {
    self.infoLogger = infoLogger
  }
  
  public func logAPIFailure(errorStatusCode: Int, url: String, responseData: String, errorDescription: String) {
    let errorCode: String = String(errorStatusCode)
    
    var params: [String: String] = [NSLocalizedDescriptionKey: errorDescription,
                                    Constants.failedAPIPath: url,
                                    Constants.failedAPIErrorCode: errorCode,
                                    Constants.newNetworkLayer: "1"]
    
    if let impervaIncidentID = extractIncidentIDForImpervaError(from: responseData) {
      params[Constants.impervaIncidentIDKey] = impervaIncidentID
    }
    
    let error: NSError = NSError(domain: Constants.failedAPIErrorDomain,
                                 code: 0,
                                 userInfo: params)
    
    log(eventName: Constants.eventName,
        error: error,
        attributes: nil)
  }
}

private extension NetworkLogger {
  
  func log(eventName: String, error: Error?, attributes: [String: Any]?) {
    infoLogger?.log(eventName: eventName, error: error, attributes: attributes)
  }
}

//For checking if error is an imperva error and if so then extracting incident id
//the scenario is: The API responds with a 403 and the response body is an HTML (not JSON) which contains an Imperva Incident ID
extension NetworkLogger {
  func extractIncidentIDForImpervaError(from responseHTML: String) -> String? {
    if let impervaRegex = try? NSRegularExpression(pattern: Constants.impervaIncidentIDRegexPattern, options: [.caseInsensitive]) {
      let range = NSRange(responseHTML.startIndex..<responseHTML.endIndex, in: responseHTML)
      
      guard let match = impervaRegex.firstMatch(in: responseHTML, options: [], range: range),
            let idRange = Range(match.range(at: 1), in: responseHTML) else {
        return nil
      }
      return String(responseHTML[idRange])
    }
    return nil
  }
}
