import Foundation

// swiftlint: disable all
public enum ModulePaths {
    case feature(Feature)
    case domain(Domain)
    case core(Core)
    case shared(Shared)
}

public extension ModulePaths {
    enum Feature: String {
        case BaseFeature

        func targetName(type: MicroTargetType) -> String {
            "\(self.rawValue)\(type.rawValue)"
        }
    }
}

public extension ModulePaths {
    enum Domain: String {
        case BaseDomain

        func targetName(type: MicroTargetType) -> String {
            "\(self.rawValue)\(type.rawValue)"
        }
    }
}

public extension ModulePaths {
    enum Core: String {
        case DesignSystem

        func targetName(type: MicroTargetType) -> String {
            "\(self.rawValue)\(type.rawValue)"
        }
    }
}

public extension ModulePaths {
    enum Shared: String {
        case UtilityModule
        case GlobalThirdPartyLibrary

        func targetName(type: MicroTargetType) -> String {
            "\(self.rawValue)\(type.rawValue)"
        }
    }
}

public enum MicroTargetType: String {
    case interface = "Interface"
    case sources = ""
    case testing = "Testing"
}
