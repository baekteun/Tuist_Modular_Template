import ProjectDescription
import ConfigurationPlugin

let dependencies = Dependencies(
    carthage: nil,
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
    
        ],
        baseSettings: .settings(
            configurations: [
                .debug(name: .dev),
                .debug(name: .stage),
                .release(name: .prod)
            ]
        )
    ),
    platforms: [.iOS]
)
