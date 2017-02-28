import PackageDescription

let package = Package(
    name: "KituraQuery",
    dependencies: [
        .Package(url: "https://naithar@bitbucket.org/naithar/kitura-clone.git", majorVersion: 1),
        .Package(url: "https://github.com/naithar/Query.git", majorVersion: 0)
    ]
)
