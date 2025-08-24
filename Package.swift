// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SharedData",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "SharedData",
      targets: ["SharedData"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
    .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "20.0.3")),
    .package(path: "../SharedDomain"),
  ],
  targets: [
    .target(
      name: "SharedData",
      dependencies: [
        .product(name: "Alamofire", package: "Alamofire"),
        .product(name: "RealmSwift", package: "realm-swift"),
        .product(name: "SharedDomain", package: "SharedDomain"),
      ]
    ),
    .testTarget(
      name: "SharedDataTests",
      dependencies: ["SharedData"]
    ),
  ]
)
