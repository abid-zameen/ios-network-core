// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "NetworkLayer",
            targets: ["Network", "SearchService"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        .package(url: "https://github.com/algolia/algoliasearch-client-swift.git", from: "9.0.0")
    ],
    targets: [
        .target(
            name: "Network",
            dependencies: [
                "Alamofire"
            ],
            path: "NetworkLayer/Network",
            exclude: ["../UnitTests"]
        ),
        .target(
            name: "SearchService",
            dependencies: [
              .product(name: "Search", package: "algoliasearch-client-swift")
            ],
            path: "NetworkLayer/Search",
            exclude: ["../UnitTests"]
        ),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["Network"],
            path: "NetworkLayer/UnitTests"
        )
    ]
)
