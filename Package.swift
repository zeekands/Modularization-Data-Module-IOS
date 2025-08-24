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
    // Ini adalah dependensi eksternal dari pihak ketiga
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
    .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "20.0.3")),
    .package(name: "SharedDomainPkg",
             url: "https://github.com/zeekands/Modularization-Domain-Module-IOS.git",
             branch: "main"),
  ],
  targets: [
    .target(
      name: "SharedData",
      dependencies: [
        .product(name: "Alamofire", package: "Alamofire"),
        .product(name: "RealmSwift", package: "realm-swift"),
        .product(name: "SharedDomain", package: "SharedDomainPkg"),
      ]
    ),
    .testTarget(
      name: "SharedDataTests",
      dependencies: ["SharedData"]
    ),
  ]
)