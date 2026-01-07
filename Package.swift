// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NetworkLayer",
            targets: ["NetworkLayer", "SearchService"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        .package(url: "https://github.com/algolia/algoliasearch-client-swift.git", from: "9.0.0")
    ],
    targets: [
        .target(
            name: "NetworkLayer",
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
            dependencies: ["NetworkLayer"],
            path: "NetworkLayer/UnitTests"
        )
    ]
)
