//
//  CoreNetworkTests.swift
//  CoreNetworkTests
//
//  Created by Abid Hussain on 08/01/2025.
//  Copyright © 2025 bayut. All rights reserved.

import Testing
@testable import CoreNetwork

struct TestResponse: Decodable {
  var name = ""
}

struct NetworkTests {

  @Test
  func requestReturnsErrorWhenNoTokenInserted() async throws {
    let networkManager = NetworkFactory.createNetworkManager()
    let request = APIRequestBuilder.create(path: "/test/", type: .get)
    await #expect(throws: ServiceError.self, performing: {
      let _: TestResponse? = try await networkManager.execute(request: request)
    })
  }

  @Test
  func executeWithNoResponseDataShouldThrowError() async throws {
    let networkManager = NetworkFactory.createNetworkManager()
    let mockRequest = APIRequestBuilder.create(path: "/test", type: .get)
    
    await #expect(throws: Error.self, performing: {
      let _: TestResponse? = try await networkManager.execute(request: mockRequest)
    })
  }

  @Test
  func executeWhenAPIFailsAndResponseContainsHTMLWithImpervaIncidentID() async {
    let networkManager = MockNetworkManager()
    let mockRequest = APIRequestBuilder.create(path: "/test", type: .get)
    
    let mockedResponse = MockImpervaErrorInHtmlResponse().getMockedResponse()
    networkManager.shouldSucceedWithResponse(mockedResponse)
    
    do {
      let response: String? = try await networkManager.execute(request: mockRequest)
      
      let incidentID = NetworkLogger().extractIncidentIDForImpervaError(from: response ?? "")

      #expect(incidentID == "777000300150113501-81999000270079872")
      
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }
}
