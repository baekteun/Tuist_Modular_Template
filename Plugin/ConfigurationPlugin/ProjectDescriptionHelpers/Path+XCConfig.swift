import ProjectDescription

public extension ProjectDescription.Path {
    static func relativeToXCConfig(type: ProjectDeployTarget, name: String) -> Self {
        return .relativeToRoot("XCConfig/\(name)/\(type.rawValue).xcconfig")
    }
    static var shared: Self {
        return .relativeToRoot("XCConfig/Shared.xcconfig")
    }
}
