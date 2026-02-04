# CoreNetwork

![Swift](https://img.shields.io/badge/Swift-5.10-orange)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-lightgrey)

CoreNetwork is a robust networking library designed for modern iOS and macOS applications, built with Swift's structured concurrency (async/await) and providing seamless integration with Algolia Search.

## Features

- **Async/Await Support**: Built natively with Swift Concurrency.
- **Type-Safe API**: Generic response decoding.
- **Advanced Caching**: Support for App Session, User Session, and File-based caching.
- **Algolia Search**: Specialized wrapper for Algolia InstantSearch.
- **Multipart Uploads**: Easy handling of multipart form data.
- **Request Building**: Fluent `APIRequestBuilder` for constructing requests.

## Installation

### Swift Package Manager

Add `CoreNetwork` to your project via Swift Package Manager:

1. In Xcode, select **File > Add Packages...**
2. Enter the repository URL.
3. Select the version (e.g., `1.0.0` or `main`).
4. Choose the libraries you need: `Network`, `SearchService`.

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/abid-zameen/ios-network-core.git", from: "1.0.0")
]
```

## Usage

### 1. Networking

#### Configuration

Define your network configuration conforming to `NetworkConfigrations` (note the spelling):

```swift
import Network

struct AppConfig: NetworkConfigrations {
    var baseURL: String { "api.example.com" }
    // httpScheme default implementation returns "https"
}
```

#### Initialization

Initialize the `NetworkManager` with your configuration and `Alamofire` session:

```swift
import Alamofire
import Network

let config = AppConfig()
let session = Session.default
let networkManager = NetworkManager(session, configs: config)
```

#### Defining a Request

Use `APIRequestBuilder` to create requests. You can define path, method, headers, and caching policy:

```swift
let userRequest = APIRequestBuilder.create(
    path: "/users/profile",
    type: .get,
    cache: .userSession // Use caching if needed
)
```

#### Executing a Request

Call `execute` to fetch and decode data asynchronously:

```swift
struct UserProfile: Decodable {
    let id: String
    let name: String
}

func fetchProfile() async {
    do {
        let profile: UserProfile? = try await networkManager.execute(request: userRequest)
        if let profile = profile {
            print("User: \(profile.name)")
        }
    } catch {
        print("Network Request Failed: \(error)")
    }
}
```

### 2. Algolia Search

#### Configuration

Configure Algolia credentials before using the client. This is typically done at app launch.

```swift
import SearchService

AlgoliaConfig.setup(
    appID: "YOUR_APP_ID",
    apiKey: "YOUR_API_KEY"
)
```

#### Search

Initialize `AlgoliaClient` and perform searches:

```swift
// Initialize client (optionally pass a PerformanceTracing implementation)
let searchClient = try? AlgoliaClient(nil)

// Create a search request
let request = SearchRequest(
    query: "apartments in dubai",
    hitsPerPage: 20
)

func searchProperties() async {
    guard let client = searchClient else { return }
    
    do {
        let results: SearchResult<Property> = try await client.search(
            query: request,
            in: "properties_index"
        )
        print("Found \(results.hits.count) properties")
    } catch {
        print("Search failed: \(error)")
    }
}
```

## License

Copyright (c) 2025 Bayut.com. All rights reserved.
Explicit permission is required for use. See the LICENSE file for more info.
