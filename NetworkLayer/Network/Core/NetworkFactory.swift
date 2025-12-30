//
//  NetworkFactory.swift
//  CoreNetwork
//
//  Created by Abid Hussain on 03/02/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Alamofire

public struct NetworkFactory {
  
  public static func createNetworkManager() -> Networking {
    
    let configs = DependencyContainer.shared.networkConfig
    let session = Session(interceptor: Interceptor(interceptors: [ImpervaInterceptor(), AuthInterceptor()]),
                          eventMonitors: [APIRequestsMonitor()])
    return NetworkManager(session,
                          configs: configs)
  }
}

extension NetworkFactory {
  public static func createUnauthenticatedNetworkManager() -> Networking {
    let configs = DependencyContainer.shared.networkConfig
    let session = Session(interceptor: Interceptor(interceptors: [ImpervaInterceptor()]),
                          eventMonitors: [APIRequestsMonitor()])
    return NetworkManager(session,
                          configs: configs)
  }
}
