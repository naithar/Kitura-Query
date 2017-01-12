import PackageDescription

let package = Package(
    name: "KituraQuery",
    dependencies: [
        .Package(url: "https://github.com/naithar/Query.git", majorVersion: 0, minor: 0)
    ]
)
