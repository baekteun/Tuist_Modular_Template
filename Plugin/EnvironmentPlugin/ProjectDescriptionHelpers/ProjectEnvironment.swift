import Foundation
import ProjectDescription

public struct ProjectEnvironment {
    public let name: String
    public let organizationName: String
    public let deploymentTarget: DeploymentTarget
    public let platform: Platform
    public let baseSetting: SettingsDictionary
    public let isCI: Bool
}

public let env = ProjectEnvironment(
    name: "",
    organizationName: "",
    deploymentTarget: .iOS(targetVersion: "16.0", devices: [.iphone, .ipad]),
    platform: .iOS,
    baseSetting: [:],
    isCI: (ProcessInfo.processInfo.environment["TUIST_CI"] ?? "0") == "1" ? true : false
)
