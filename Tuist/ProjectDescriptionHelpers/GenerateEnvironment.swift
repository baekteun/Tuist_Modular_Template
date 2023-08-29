import ConfigurationPlugin
import Foundation
import ProjectDescription

public enum GenerateEnvironment: String {
    case ci = "CI"
    case cd = "CD"
    case dev = "DEV"
}

let environment = ProcessInfo.processInfo.environment["TUIST_ENV"] ?? ""
public let generateEnvironment = GenerateEnvironment(rawValue: environment) ?? .dev

public extension GenerateEnvironment {
    var scripts: [TargetScript] {
        switch self {
        case .ci, .cd:
            return []

        case .dev:
            return [.swiftLint]
        }
    }
}
