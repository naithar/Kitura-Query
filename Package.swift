import PackageDescription

let package = Package(
    name: "KituraQuery",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1),
        .Package(url: "https://github.com/naithar/Query.git", majorVersion: 0)
    ]
)
